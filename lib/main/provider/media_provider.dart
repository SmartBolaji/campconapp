import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaSelectionProvider extends ChangeNotifier {
  final List<AssetEntity> _selectedImages = [];
  final Map<String, File> _imageFiles = {};
  final List<File> _capturedImages = [];

  List<AssetEntity> get selectedImages => _selectedImages;
  List<File> get selectedFiles {
    // Combine captured images and selected images
    return [..._capturedImages, ..._imageFiles.values.toList()];
  }

  List<File> get capturedImages => _capturedImages;

  bool isSelected(AssetEntity asset) {
    return _selectedImages.contains(asset);
  }

  Future<void> toggleSelection(AssetEntity asset) async {
    if (_selectedImages.contains(asset)) {
      _selectedImages.remove(asset);
      _imageFiles.remove(asset.id);
    } else {
      // Limit to 10 images total (including captured)
      if (_selectedImages.length + _capturedImages.length >= 10) {
        return;
      }
      _selectedImages.add(asset);

      // Load file immediately when selected
      final file = await asset.file;
      if (file != null) {
        _imageFiles[asset.id] = file;
      }
    }
    notifyListeners();
  }

  Future<void> addCapturedImage(File image) async {
    // Limit to 10 images total
    if (_selectedImages.length + _capturedImages.length >= 10) {
      return;
    }
    _capturedImages.add(image);
    notifyListeners();
  }

  void clearSelection() {
    _selectedImages.clear();
    _imageFiles.clear();
    _capturedImages.clear();
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < _selectedImages.length) {
      final asset = _selectedImages[index];
      _selectedImages.removeAt(index);
      _imageFiles.remove(asset.id);
      notifyListeners();
    }
  }

  void removeCapturedAt(int index) {
    if (index < _capturedImages.length) {
      _capturedImages.removeAt(index);
      notifyListeners();
    }
  }
}
