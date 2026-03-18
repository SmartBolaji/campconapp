import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:campcon/main/services/backblaze.dart';
import 'package:campcon/main/models/product_model.dart';

class MarketPostProvider extends ChangeNotifier with UploadStatusMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
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

  // Provider-specific wrapper to preserve old call sites.
  void setUploadSuccessForType(String type) {
    super.setUploadSuccess(message: '$type posted successfully!');
  }

  // Helper method to upload multiple images
  Future<List<String>> _uploadImages(List<File> images, String userId) async {
    List<String> imageUrls = [];
    int totalImages = images.length;

    for (int i = 0; i < images.length; i++) {
      try {
        updateSilentUploadProgress(
          (i / totalImages) * 0.7,
          message: 'Compressing image ${i + 1} of $totalImages...',
        );

        File compressedImage = await _backblazeService.compressImage(images[i]);

        updateSilentUploadProgress(
          ((i + 0.5) / totalImages) * 0.7,
          message: 'Uploading image ${i + 1} of $totalImages...',
        );

        String url =
            await _backblazeService.uploadImageToCloud(compressedImage);
        imageUrls.add(url);

        debugPrint('✓ Image ${i + 1} uploaded successfully');

        if (compressedImage.path != images[i].path) {
          try {
            await compressedImage.delete();
          } catch (e) {
            debugPrint('Warning: Could not delete temp file: $e');
          }
        }
      } catch (e) {
        debugPrint('❌ Error uploading image ${i + 1}: $e');
      }
    }

    return imageUrls;
  }

  // Post item silently with multiple images
  Future<bool> postItemSilently({
    required String userId,
    required String name,
    required String location,
    required String description,
    required String category,
    required double price,
    int? stock,
    double? discount,
    List<File>? images,
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
      List<String> imageUrls = [];

      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadImages(images, userId);

        if (imageUrls.isEmpty && images.isNotEmpty) {
          setUploadFailed('Failed to upload images. Please try again.');
          return false;
        }
      }

      setProcessing('Publishing item...');
      updateSilentUploadProgress(0.9, message: 'Publishing item...');

      final productRef = _firestore.collection('marketplace').doc();

      double? discountedPrice;
      if (discount != null && discount > 0) {
        discountedPrice = price - (price * discount / 100);
      }

      final product = Product(
        id: productRef.id,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
        imageUrls: imageUrls,
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

      setUploadSuccessForType('Item');
      debugPrint('✓ Item posted with ${imageUrls.length} image(s)');
      return true;
    } catch (e) {
      debugPrint('❌ Error posting item: $e');
      setUploadFailed('Failed to post item. Please try again.');
      return false;
    }
  }

  // Post service silently with multiple images
  Future<bool> postServiceSilently({
    required String userId,
    required String location,
    required String description,
    required String category,
    required double price,
    required String wageType,
    List<File>? images,
  }) async {
    if (location.trim().isEmpty || description.trim().isEmpty) {
      setError('Please fill all required fields');
      return false;
    }

    startSilentUpload();
    clearError();

    try {
      List<String> imageUrls = [];

      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadImages(images, userId);

        if (imageUrls.isEmpty && images.isNotEmpty) {
          setUploadFailed('Failed to upload images. Please try again.');
          return false;
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
        imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
        imageUrls: imageUrls,
        category: category,
        isItem: false,
        sellerId: userId,
        location: location,
        createdAt: DateTime.now(),
        wageType: wageType,
      );

      await serviceRef.set(service.toJson());

      setUploadSuccessForType('Service');
      debugPrint('✓ Service posted with ${imageUrls.length} image(s)');
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

  // Update marketplace item
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data, {
    List<File>? newImages,
    String? userId,
  }) async {
    setLoading(true);
    clearError();

    try {
      // Upload new images if provided
      if (newImages != null && newImages.isNotEmpty && userId != null) {
        final imageUrls = await _uploadImages(newImages, userId);
        if (imageUrls.isNotEmpty) {
          // Merge with existing URLs if data already has some
          final existing = List<String>.from(data['imageUrls'] ?? []);
          existing.addAll(imageUrls);
          data['imageUrls'] = existing;
          data['imageUrl'] = existing.first;
        }
      }

      await _firestore.collection('marketplace').doc(productId).update(data);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('Error updating product: $e');
      setError('Failed to update listing');
      return false;
    }
  }
}
