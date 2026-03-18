import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:campcon/main/services/backblaze.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/poll_model.dart';
import 'package:campcon/main/services/post_tagging_service.dart';

// UploadStatus enum is now defined in upload_status_mixin.dart
// Re-export it for backward compat with any UI that imports it from here.
export 'package:campcon/main/provider/upload_status_mixin.dart'
    show UploadStatus;

class PostProvider extends ChangeNotifier with UploadStatusMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService.instance;

  bool _isLoading = false;
  bool _isUploadingImages = false;
  double _rawUploadProgress = 0.0;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isUploadingImages => _isUploadingImages;
  double get rawUploadProgress => _rawUploadProgress;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUploadingImages(bool uploading) {
    _isUploadingImages = uploading;
    notifyListeners();
  }

  void setRawUploadProgress(double progress) {
    _rawUploadProgress = progress;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create a new post with silent background upload
  Future<bool> createPostSilently({
    required String userId,
    required String username,
    required String userProfileImage,
    required String content,
    required String campus,
    List<File>? images,
    PollModel? poll,
  }) async {
    if (content.trim().isEmpty &&
        (images == null || images.isEmpty) &&
        poll == null) {
      setError('Post content, images, or poll are required');
      return false;
    }

    startSilentUpload();
    clearError();

    try {
      List<String> imageUrls = [];

      if (images != null && images.isNotEmpty) {
        updateSilentUploadProgress(0.0, message: 'Preparing images...');

        for (int i = 0; i < images.length; i++) {
          try {
            debugPrint(' Uploading image ${i + 1} of ${images.length}...');
            File compressedImage =
                await _backblazeService.compressImage(images[i]);
            updateSilentUploadProgress(
              (i / images.length) * 0.8,
              message: 'Uploading image ${i + 1} of ${images.length}...',
            );
            String imageUrl =
                await _backblazeService.uploadImageToCloud(compressedImage);
            imageUrls.add(imageUrl);
            updateSilentUploadProgress(
              ((i + 1) / images.length) * 0.8,
              message: 'Uploaded ${i + 1} of ${images.length} images',
            );
            if (compressedImage.path != images[i].path) {
              try {
                await compressedImage.delete();
              } catch (e) {
                debugPrint('Warning: Could not delete temp file: $e');
              }
            }
          } catch (e) {
            debugPrint(' Error uploading image ${i + 1}: $e');
            setUploadFailed('Failed to upload image ${i + 1}');
            return false;
          }
        }
      }

      setProcessing('Publishing post...');
      updateSilentUploadProgress(0.9, message: 'Publishing post...');

      final postRef = _firestore.collection('posts').doc();

      // Set poll creator if poll exists
      PollModel? finalPoll;
      if (poll != null) {
        finalPoll = poll.copyWith(createdBy: userId);
      }

      final post = PostModel(
        postId: postRef.id,
        userId: userId,
        username: username,
        userProfileImage: userProfileImage,
        content: content.trim(),
        imageUrls: imageUrls,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        campus: campus,
        tags: PostTaggingService.extractTags(content),
        poll: finalPoll,
      );

      await postRef.set(post.toMap());
      setUploadSuccess(message: 'Post published!');
      debugPrint(' Post created successfully with campus: $campus');
      return true;
    } catch (e) {
      debugPrint(' Error creating post: $e');
      setUploadFailed('Failed to create post. Please try again.');
      return false;
    }
  }

  // Original blocking create-post method (kept for backward compatibility)
  Future<bool> createPost({
    required String userId,
    required String username,
    required String userProfileImage,
    required String content,
    required String campus,
    List<File>? images,
    PollModel? poll,
  }) async {
    if (content.trim().isEmpty &&
        (images == null || images.isEmpty) &&
        poll == null) {
      setError('Post content, images, or poll are required');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      List<String> imageUrls = [];

      if (images != null && images.isNotEmpty) {
        setUploadingImages(true);
        for (int i = 0; i < images.length; i++) {
          try {
            File compressedImage =
                await _backblazeService.compressImage(images[i]);
            String imageUrl =
                await _backblazeService.uploadImageToCloud(compressedImage);
            imageUrls.add(imageUrl);
            setRawUploadProgress((i + 1) / images.length);
            if (compressedImage.path != images[i].path) {
              try {
                await compressedImage.delete();
              } catch (e) {
                debugPrint('Warning: Could not delete temp file: $e');
              }
            }
          } catch (e) {
            setError('Failed to upload image ${i + 1}');
            setUploadingImages(false);
            setLoading(false);
            return false;
          }
        }
        setUploadingImages(false);
        setRawUploadProgress(0.0);
      }

      final postRef = _firestore.collection('posts').doc();

      // Set poll creator if poll exists
      PollModel? finalPoll;
      if (poll != null) {
        finalPoll = poll.copyWith(createdBy: userId);
      }

      final post = PostModel(
        postId: postRef.id,
        userId: userId,
        username: username,
        userProfileImage: userProfileImage,
        content: content.trim(),
        imageUrls: imageUrls,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        campus: campus,
        tags: PostTaggingService.extractTags(content),
        poll: finalPoll,
      );

      await postRef.set(post.toMap());
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError('Failed to create post. Please try again.');
      return false;
    }
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Stream<List<PostModel>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Future<bool> deletePost(String postId, List<String> imageUrls) async {
    setLoading(true);
    clearError();
    try {
      debugPrint(
          '🔥 PostProvider.deletePost: Starting Firestore deletion for postId=$postId');
      await _firestore.collection('posts').doc(postId).delete();
      debugPrint(
          '✅ PostProvider.deletePost: Firestore deletion successful for postId=$postId');
      setLoading(false);
      return true;
    } catch (e) {
      debugPrint(
          '❌ PostProvider.deletePost: Firestore deletion failed for postId=$postId: $e');
      setLoading(false);
      setError('Failed to delete post');
      return false;
    }
  }
}
