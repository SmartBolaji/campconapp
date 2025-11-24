import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:campcon/main/models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService(
    keyId: '005da9d457a27920000000001',
    applicationKey: 'K005VF/M8FucVqi2132OpxhuZETl31k',
    bucketId: '1ddac98d04f5375a92470912',
    bucketName: 'Campcon-Gallary',
  );

  bool _isLoading = false;
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isUploadingImages => _isUploadingImages;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUploadingImages(bool uploading) {
    _isUploadingImages = uploading;
    notifyListeners();
  }

  void setUploadProgress(double progress) {
    _uploadProgress = progress;
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

  // Create a new post
  Future<bool> createPost({
    required String userId,
    required String username,
    required String userProfileImage,
    required String content,
    List<File>? images,
  }) async {
    if (content.trim().isEmpty && (images == null || images.isEmpty)) {
      setError('Post content or images are required');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      List<String> imageUrls = [];

      // Upload images if any
      if (images != null && images.isNotEmpty) {
        setUploadingImages(true);

        for (int i = 0; i < images.length; i++) {
          try {
            debugPrint('📸 Uploading image ${i + 1} of ${images.length}...');

            // Compress image
            File compressedImage =
                await _backblazeService.compressImage(images[i]);

            // Upload to Backblaze
            String imageUrl =
                await _backblazeService.uploadFile(compressedImage);
            imageUrls.add(imageUrl);

            // Update progress
            setUploadProgress((i + 1) / images.length);

            debugPrint('✅ Image ${i + 1} uploaded successfully');

            // Clean up compressed file if different from original
            if (compressedImage.path != images[i].path) {
              try {
                await compressedImage.delete();
              } catch (e) {
                debugPrint('Warning: Could not delete temp file: $e');
              }
            }
          } catch (e) {
            debugPrint('❌ Error uploading image ${i + 1}: $e');
            setError('Failed to upload image ${i + 1}');
            setUploadingImages(false);
            setLoading(false);
            return false;
          }
        }

        setUploadingImages(false);
        setUploadProgress(0.0);
      }

      // Create post document
      final postRef = _firestore.collection('posts').doc();
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
      );

      await postRef.set(post.toMap());

      setLoading(false);
      debugPrint('✅ Post created successfully');
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('❌ Error creating post: $e');
      setError('Failed to create post. Please try again.');
      return false;
    }
  }

  // Get user's posts
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  // Get all posts (for feed)
  Stream<List<PostModel>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  // Delete a post
  Future<bool> deletePost(String postId, List<String> imageUrls) async {
    setLoading(true);
    clearError();

    try {
      // Delete post document
      await _firestore.collection('posts').doc(postId).delete();

      // TODO: Delete images from Backblaze if needed
      // This would require implementing a delete method in BackblazeService

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('Error deleting post: $e');
      setError('Failed to delete post');
      return false;
    }
  }
}
