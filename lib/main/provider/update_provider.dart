// import 'package:flutter/material.dart';

// enum UploadStatus {
//   idle,
//   uploading,
//   processing,
//   success,
//   cancelled,
//   failed,
// }

// class UpdateProvider with ChangeNotifier {
//   int _currentIndex = 0;
//   String _searchQuery = '';

//   // Upload status properties
//   UploadStatus _uploadStatus = UploadStatus.idle;
//   double _uploadProgress = 0.0;
//   String _uploadMessage = '';
//   bool _showUploadBar = false;
//   Function? _cancelCallback;

//   int get currentIndex => _currentIndex;
//   String get searchQuery => _searchQuery;
//   UploadStatus get uploadStatus => _uploadStatus;
//   double get uploadProgress => _uploadProgress;
//   String get uploadMessage => _uploadMessage;
//   bool get showUploadBar => _showUploadBar;

//   void setIndex(int index) {
//     _currentIndex = index;
//     notifyListeners();
//   }

//   void setSearchQuery(String query) {
//     _searchQuery = query.toLowerCase();
//     notifyListeners();
//   }

//   // Start upload process
//   void startUpload({Function? onCancel}) {
//     _uploadStatus = UploadStatus.uploading;
//     _uploadProgress = 0.0;
//     _uploadMessage = 'Uploading media...';
//     _showUploadBar = true;
//     _cancelCallback = onCancel;
//     notifyListeners();
//   }

//   // Update upload progress
//   void updateUploadProgress(double progress, {String? message}) {
//     _uploadProgress = progress;
//     if (message != null) {
//       _uploadMessage = message;
//     }
//     notifyListeners();
//   }

//   // Set processing status
//   void setProcessing(String message) {
//     _uploadStatus = UploadStatus.processing;
//     _uploadMessage = message;
//     notifyListeners();
//   }

//   // Set success status
//   void setUploadSuccess() {
//     _uploadStatus = UploadStatus.success;
//     _uploadMessage = 'Post published!';
//     _uploadProgress = 1.0;
//     notifyListeners();

//     // Auto-hide after 3 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       hideUploadBar();
//     });
//   }

//   // Set failed status
//   void setUploadFailed(String error) {
//     _uploadStatus = UploadStatus.failed;
//     _uploadMessage = 'Upload failed: $error';
//     notifyListeners();

//     // Auto-hide after 5 seconds
//     Future.delayed(const Duration(seconds: 5), () {
//       hideUploadBar();
//     });
//   }

//   // Cancel upload
//   void cancelUpload() {
//     _uploadStatus = UploadStatus.cancelled;
//     _uploadMessage = 'Upload cancelled';

//     // Execute cancel callback if provided
//     if (_cancelCallback != null) {
//       _cancelCallback!();
//     }

//     notifyListeners();

//     // Hide after 2 seconds
//     Future.delayed(const Duration(seconds: 2), () {
//       hideUploadBar();
//     });
//   }

//   // Hide upload bar
//   void hideUploadBar() {
//     _showUploadBar = false;
//     _uploadStatus = UploadStatus.idle;
//     _uploadProgress = 0.0;
//     _uploadMessage = '';
//     _cancelCallback = null;
//     notifyListeners();
//   }

//   // Reset upload state
//   void resetUpload() {
//     _uploadStatus = UploadStatus.idle;
//     _uploadProgress = 0.0;
//     _uploadMessage = '';
//     _showUploadBar = false;
//     _cancelCallback = null;
//     notifyListeners();
//   }
// }
