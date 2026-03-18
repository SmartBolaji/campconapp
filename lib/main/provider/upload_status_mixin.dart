import 'package:flutter/material.dart';

/// Shared upload-bar state management.
///
/// Apply this mixin to any [ChangeNotifier] that needs a background-upload
/// progress bar with status transitions (idle → uploading → processing →
/// success/failed/cancelled → idle).
///
/// Applied to: [PostProvider], [MarketPostProvider], [EventProvider],
/// [EventCreateProvider], [ResourcePostProvider].
///
/// Usage:
/// ```dart
/// class MyProvider extends ChangeNotifier with UploadStatusMixin { … }
/// ```

enum UploadStatus {
  idle,
  uploading,
  processing,
  success,
  cancelled,
  failed,
}

mixin UploadStatusMixin on ChangeNotifier {
  UploadStatus _uploadStatus = UploadStatus.idle;
  double _uploadProgress = 0.0;
  String _uploadMessage = '';
  bool _showUploadBar = false;
  Function? _cancelCallback;

  UploadStatus get uploadStatus => _uploadStatus;
  double get uploadProgress => _uploadProgress;
  String get uploadMessage => _uploadMessage;
  bool get showUploadBar => _showUploadBar;

  /// Start a silent background upload and show the upload bar.
  void startSilentUpload({Function? onCancel}) {
    _uploadStatus = UploadStatus.uploading;
    _uploadProgress = 0.0;
    _uploadMessage = 'Uploading media...';
    _showUploadBar = true;
    _cancelCallback = onCancel;
    notifyListeners();
  }

  /// Update progress (0.0–1.0) and optionally change the displayed message.
  void updateSilentUploadProgress(double progress, {String? message}) {
    _uploadProgress = progress;
    if (message != null) _uploadMessage = message;
    notifyListeners();
  }

  /// Move to the processing state with a custom message.
  void setProcessing(String message) {
    _uploadStatus = UploadStatus.processing;
    _uploadMessage = message;
    notifyListeners();
  }

  /// Mark upload as successful. Auto-hides the bar after 3 seconds.
  void setUploadSuccess({String message = 'Upload successful!'}) {
    _uploadStatus = UploadStatus.success;
    _uploadMessage = message;
    _uploadProgress = 1.0;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), hideUploadBar);
  }

  /// Mark upload as failed. Auto-hides the bar after 5 seconds.
  void setUploadFailed(String error) {
    _uploadStatus = UploadStatus.failed;
    _uploadMessage = 'Upload failed: $error';
    notifyListeners();
    Future.delayed(const Duration(seconds: 5), hideUploadBar);
  }

  /// Cancel the upload, invoke the cancel callback, then auto-hide.
  void cancelUpload() {
    _uploadStatus = UploadStatus.cancelled;
    _uploadMessage = 'Upload cancelled';
    _cancelCallback?.call();
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), hideUploadBar);
  }

  /// Immediately hide the upload bar and reset state to idle.
  void hideUploadBar() {
    _showUploadBar = false;
    _uploadStatus = UploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _cancelCallback = null;
    notifyListeners();
  }

  /// Reset all upload state without any delays.
  void resetUpload() {
    _uploadStatus = UploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _showUploadBar = false;
    _cancelCallback = null;
    notifyListeners();
  }
}
