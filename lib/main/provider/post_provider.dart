import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:campcon/main/models/post_model.dart';

enum UploadStatus {
  idle,
  uploading,
  processing,
  success,
  cancelled,
  failed,
}

class PostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService(
    keyId: '0050fae555030410000000003',
    applicationKey: 'K005wG+vROJBYZFRpo0HVDn+Q4V3+zw',
    bucketId: 'f0ef2ace6525c59093a00411',
    bucketName: 'Campcon-Media',
  );

  bool _isLoading = false;
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Silent upload properties
  UploadStatus _uploadStatus = UploadStatus.idle;
  String _uploadMessage = '';
  bool _showUploadBar = false;
  Function? _cancelCallback;

  bool get isLoading => _isLoading;
  bool get isUploadingImages => _isUploadingImages;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  UploadStatus get uploadStatus => _uploadStatus;
  String get uploadMessage => _uploadMessage;
  bool get showUploadBar => _showUploadBar;

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

  // Start silent upload
  void startSilentUpload({Function? onCancel}) {
    _uploadStatus = UploadStatus.uploading;
    _uploadProgress = 0.0;
    _uploadMessage = 'Uploading media...';
    _showUploadBar = true;
    _cancelCallback = onCancel;
    notifyListeners();
  }

  // Update silent upload progress
  void updateSilentUploadProgress(double progress, {String? message}) {
    _uploadProgress = progress;
    if (message != null) {
      _uploadMessage = message;
    }
    notifyListeners();
  }

  // Set processing status
  void setProcessing(String message) {
    _uploadStatus = UploadStatus.processing;
    _uploadMessage = message;
    notifyListeners();
  }

  // Set upload success
  void setUploadSuccess() {
    _uploadStatus = UploadStatus.success;
    _uploadMessage = 'Post published!';
    _uploadProgress = 1.0;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hideUploadBar();
    });
  }

  // Set upload failed
  void setUploadFailed(String error) {
    _uploadStatus = UploadStatus.failed;
    _uploadMessage = 'Upload failed: $error';
    notifyListeners();

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      hideUploadBar();
    });
  }

  // Cancel upload
  void cancelUpload() {
    _uploadStatus = UploadStatus.cancelled;
    _uploadMessage = 'Upload cancelled';

    if (_cancelCallback != null) {
      _cancelCallback!();
    }

    notifyListeners();

    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      hideUploadBar();
    });
  }

  // Hide upload bar
  void hideUploadBar() {
    _showUploadBar = false;
    _uploadStatus = UploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _cancelCallback = null;
    notifyListeners();
  }

  // Reset upload state
  void resetUpload() {
    _uploadStatus = UploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _showUploadBar = false;
    _cancelCallback = null;
    notifyListeners();
  }

  // Create a new post with silent upload
  Future<bool> createPostSilently({
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

    startSilentUpload();
    clearError();

    try {
      List<String> imageUrls = [];

      // Upload images if any
      if (images != null && images.isNotEmpty) {
        updateSilentUploadProgress(0.0, message: 'Preparing images...');

        for (int i = 0; i < images.length; i++) {
          try {
            debugPrint('📸 Uploading image ${i + 1} of ${images.length}...');

            // Compress image
            File compressedImage =
                await _backblazeService.compressImage(images[i]);

            updateSilentUploadProgress(
              (i / images.length) * 0.8,
              message: 'Uploading image ${i + 1} of ${images.length}...',
            );

            // Upload to Backblaze
            String imageUrl =
                await _backblazeService.uploadFile(compressedImage);
            imageUrls.add(imageUrl);

            // Update progress
            updateSilentUploadProgress(
              ((i + 1) / images.length) * 0.8,
              message: 'Uploaded ${i + 1} of ${images.length} images',
            );

            debugPrint('✅ Image ${i + 1} uploaded successfully');

            // Clean up compressed file
            if (compressedImage.path != images[i].path) {
              try {
                await compressedImage.delete();
              } catch (e) {
                debugPrint('Warning: Could not delete temp file: $e');
              }
            }
          } catch (e) {
            debugPrint('❌ Error uploading image ${i + 1}: $e');
            setUploadFailed('Failed to upload image ${i + 1}');
            return false;
          }
        }
      }

      // Create post document
      setProcessing('Publishing post...');
      updateSilentUploadProgress(0.9, message: 'Publishing post...');

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

      setUploadSuccess();
      debugPrint('✅ Post created successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      setUploadFailed('Failed to create post. Please try again.');
      return false;
    }
  }

  // Original create post method (kept for backward compatibility)
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
