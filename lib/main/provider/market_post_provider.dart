import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:campcon/services/backblaze.dart';
import 'package:campcon/main/models/product_model.dart';

enum MarketUploadStatus {
  idle,
  uploading,
  processing,
  success,
  cancelled,
  failed,
}

class MarketPostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService(
    keyId: '0050fae555030410000000003',
    applicationKey: 'K005wG+vROJBYZFRpo0HVDn+Q4V3+zw',
    bucketId: 'f0ef2ace6525c59093a00411',
    bucketName: 'Campcon-Media',
  );

  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Silent upload properties
  MarketUploadStatus _uploadStatus = MarketUploadStatus.idle;
  String _uploadMessage = '';
  bool _showUploadBar = false;
  Function? _cancelCallback;

  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  MarketUploadStatus get uploadStatus => _uploadStatus;
  String get uploadMessage => _uploadMessage;
  bool get showUploadBar => _showUploadBar;

  void setLoading(bool loading) {
    _isLoading = loading;
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
    _uploadStatus = MarketUploadStatus.uploading;
    _uploadProgress = 0.0;
    _uploadMessage = 'Uploading image...';
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
    _uploadStatus = MarketUploadStatus.processing;
    _uploadMessage = message;
    notifyListeners();
  }

  // Set upload success
  void setUploadSuccess(String type) {
    _uploadStatus = MarketUploadStatus.success;
    _uploadMessage = '$type posted successfully!';
    _uploadProgress = 1.0;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hideUploadBar();
    });
  }

  // Set upload failed
  void setUploadFailed(String error) {
    _uploadStatus = MarketUploadStatus.failed;
    _uploadMessage = 'Upload failed: $error';
    notifyListeners();

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      hideUploadBar();
    });
  }

  // Cancel upload
  void cancelUpload() {
    _uploadStatus = MarketUploadStatus.cancelled;
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
    _uploadStatus = MarketUploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _cancelCallback = null;
    notifyListeners();
  }

  // Reset upload state
  void resetUpload() {
    _uploadStatus = MarketUploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _showUploadBar = false;
    _cancelCallback = null;
    notifyListeners();
  }

// Post item silently with stock and discount
  Future<bool> postItemSilently({
    required String userId,
    required String name,
    required String location,
    required String description,
    required String category,
    required double price,
    int? stock,
    double? discount,
    File? image,
  }) async {
    if (name.trim().isEmpty ||
        location.trim().isEmpty ||
        description.trim().isEmpty) {
      setError('Please fill all required fields');
      return false;
    }

    startSilentUpload();
    clearError();

    try {
      String? imageUrl;

      if (image != null) {
        updateSilentUploadProgress(0.0, message: 'Compressing image...');
        File compressedImage = await _backblazeService.compressImage(image);

        updateSilentUploadProgress(0.3, message: 'Uploading image...');
        imageUrl = await _backblazeService.uploadFile(compressedImage);

        updateSilentUploadProgress(0.7, message: 'Image uploaded...');
        debugPrint('✅ Image uploaded successfully');

        if (compressedImage.path != image.path) {
          try {
            await compressedImage.delete();
          } catch (e) {
            debugPrint('Warning: Could not delete temp file: $e');
          }
        }
      }

      setProcessing('Publishing item...');
      updateSilentUploadProgress(0.9, message: 'Publishing item...');

      final productRef = _firestore.collection('marketplace').doc();

      // Calculate discounted price if discount is provided
      double? discountedPrice;
      if (discount != null && discount > 0) {
        discountedPrice = price - (price * discount / 100);
      }

      final product = Product(
        id: productRef.id,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isItem: true,
        sellerId: userId,
        location: location,
        createdAt: DateTime.now(),
        stock: stock,
        discount: discount,
        discountedPrice: discountedPrice,
      );

      await productRef.set(product.toJson());

      setUploadSuccess('Item');
      debugPrint('✅ Item posted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error posting item: $e');
      setUploadFailed('Failed to post item. Please try again.');
      return false;
    }
  }

// Post service silently with wage type
  Future<bool> postServiceSilently({
    required String userId,
    required String location,
    required String description,
    required String category,
    required double price,
    required String wageType,
    File? image,
  }) async {
    if (location.trim().isEmpty || description.trim().isEmpty) {
      setError('Please fill all required fields');
      return false;
    }

    startSilentUpload();
    clearError();

    try {
      String? imageUrl;

      if (image != null) {
        updateSilentUploadProgress(0.0, message: 'Compressing image...');
        File compressedImage = await _backblazeService.compressImage(image);

        updateSilentUploadProgress(0.3, message: 'Uploading image...');
        imageUrl = await _backblazeService.uploadFile(compressedImage);

        updateSilentUploadProgress(0.7, message: 'Image uploaded...');
        debugPrint('✅ Image uploaded successfully');

        if (compressedImage.path != image.path) {
          try {
            await compressedImage.delete();
          } catch (e) {
            debugPrint('Warning: Could not delete temp file: $e');
          }
        }
      }

      setProcessing('Publishing service...');
      updateSilentUploadProgress(0.9, message: 'Publishing service...');

      final serviceRef = _firestore.collection('marketplace').doc();
      final service = Product(
        id: serviceRef.id,
        name: category,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isItem: false,
        sellerId: userId,
        location: location,
        createdAt: DateTime.now(),
        wageType: wageType,
      );

      await serviceRef.set(service.toJson());

      setUploadSuccess('Service');
      debugPrint('✅ Service posted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error posting service: $e');
      setUploadFailed('Failed to post service. Please try again.');
      return false;
    }
  }

  // Get marketplace items
  Stream<List<Product>> getMarketplaceItems({bool itemsOnly = true}) {
    return _firestore
        .collection('marketplace')
        .where('isItem', isEqualTo: itemsOnly)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
  }

  // Delete marketplace item
  Future<bool> deleteMarketplaceItem(String productId) async {
    setLoading(true);
    clearError();

    try {
      await _firestore.collection('marketplace').doc(productId).delete();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('Error deleting item: $e');
      setError('Failed to delete item');
      return false;
    }
  }
}
