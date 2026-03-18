import 'dart:io';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:campcon/main/services/backblaze.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventCreateProvider extends ChangeNotifier with UploadStatusMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService.instance;

  // Form state
  List<File> _selectedImages = [];
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFree = true;
  bool _sellOnCampcon = false;
  bool _hasMultipleTiers = false;
  List<TicketTier> _ticketTiers = [];

  // Getters - Form
  List<File> get selectedImages => _selectedImages;
  File? get primaryImage =>
      _selectedImages.isNotEmpty ? _selectedImages.first : null;
  List<File> get additionalImages =>
      _selectedImages.length > 1 ? _selectedImages.sublist(1) : [];
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  bool get isFree => _isFree;
  bool get sellOnCampcon => _sellOnCampcon;
  bool get hasMultipleTiers => _hasMultipleTiers;
  List<TicketTier> get ticketTiers => _ticketTiers;
  bool get hasImages => _selectedImages.isNotEmpty;
  int get imageCount => _selectedImages.length;

  // Image management
  void addImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void addImages(List<File> images) {
    _selectedImages.addAll(images);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void removeImageByFile(File image) {
    _selectedImages.remove(image);
    notifyListeners();
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final image = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, image);
    notifyListeners();
  }

  // Form setters
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay? time) {
    _selectedTime = time;
    notifyListeners();
  }

  void toggleIsFree(bool value) {
    _isFree = value;
    if (value) {
      _sellOnCampcon = false;
      _hasMultipleTiers = false;
      _ticketTiers.clear();
    }
    notifyListeners();
  }

  void toggleSellOnCampcon(bool value) {
    _sellOnCampcon = value;
    if (!value) {
      _hasMultipleTiers = false;
      _ticketTiers.clear();
    }
    notifyListeners();
  }

  void toggleMultipleTiers(bool value) {
    _hasMultipleTiers = value;
    if (value && _ticketTiers.isEmpty) {
      // Add default tier
      _ticketTiers.add(TicketTier(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'General Admission',
        description: 'Standard entry ticket',
        price: 0,
        stock: 0,
      ));
    } else if (!value) {
      _ticketTiers.clear();
    }
    notifyListeners();
  }

  // Ticket tier management
  void addTicketTier() {
    _ticketTiers.add(TicketTier(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      description: '',
      price: 0,
      stock: 0,
    ));
    notifyListeners();
  }

  void updateTicketTier(int index, TicketTier tier) {
    if (index >= 0 && index < _ticketTiers.length) {
      _ticketTiers[index] = tier;
      notifyListeners();
    }
  }

  void removeTicketTier(int index) {
    if (index >= 0 && index < _ticketTiers.length) {
      _ticketTiers.removeAt(index);
      notifyListeners();
    }
  }

  // Clear form
  void clearForm() {
    _selectedImages.clear();
    _selectedCategory = null;
    _selectedDate = null;
    _selectedTime = null;
    _isFree = true;
    _sellOnCampcon = false;
    _hasMultipleTiers = false;
    _ticketTiers.clear();
    notifyListeners();
  }

  // Keep provider-specific default message while matching mixin signature.
  @override
  void setUploadSuccess({String message = 'Event created successfully!'}) {
    super.setUploadSuccess(message: message);
  }

  // Create event
  Future<bool> createEventSilently({
    required String organizerId,
    required String organizerName,
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    required DateTime eventTime,
    required String category,
    required String school,
    required bool isFree,
    double? ticketPrice,
    String? ticketLink,
    List<File>? images,
    bool sellOnCampcon = false,
    int? ticketStock,
    List<TicketTier>? ticketTiers,
    bool hasMultipleTiers = false,
  }) async {
    if (title.trim().isEmpty ||
        description.trim().isEmpty ||
        location.trim().isEmpty ||
        category.isEmpty) {
      setUploadFailed('Missing required fields');
      return false;
    }

    if (!isFree &&
        !hasMultipleTiers &&
        (ticketPrice == null || ticketPrice <= 0)) {
      setUploadFailed('Invalid ticket price');
      return false;
    }

    if (sellOnCampcon && !isFree && !hasMultipleTiers) {
      if (ticketStock == null || ticketStock <= 0) {
        setUploadFailed('Invalid ticket stock');
        return false;
      }
    }

    if (hasMultipleTiers && (ticketTiers == null || ticketTiers.isEmpty)) {
      setUploadFailed('At least one ticket tier is required');
      return false;
    }

    startSilentUpload();

    try {
      // Upload images with compression
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        int totalImages = images.length;

        for (int i = 0; i < images.length; i++) {
          try {
            updateSilentUploadProgress(
              (i / totalImages) * 0.8,
              message: 'Compressing image ${i + 1} of $totalImages...',
            );

            // Compress image before upload
            final compressedImage =
                await _backblazeService.compressImage(images[i]);

            updateSilentUploadProgress(
              ((i + 0.5) / totalImages) * 0.8,
              message: 'Uploading image ${i + 1} of $totalImages...',
            );

            // Upload compressed image via Cloud Function
            final url =
                await _backblazeService.uploadImageToCloud(compressedImage);
            imageUrls.add(url);

            debugPrint('✓ Image ${i + 1} uploaded successfully');

            // Clean up compressed file if it's different from original
            if (compressedImage.path != images[i].path) {
              try {
                await compressedImage.delete();
              } catch (e) {
                debugPrint('Warning: Could not delete temp file: $e');
              }
            }
          } catch (e) {
            debugPrint('❌ Error uploading image ${i + 1}: $e');
            // Continue with other images instead of failing completely
          }
        }

        // Check if at least one image uploaded successfully
        if (imageUrls.isEmpty && images.isNotEmpty) {
          setUploadFailed(
              'Failed to upload any images. Please check your connection and try again.');
          return false;
        }

        if (imageUrls.length < images.length) {
          debugPrint(
              '⚠️ Warning: Only ${imageUrls.length} of ${images.length} images uploaded successfully');
        }
      }

      setProcessing('Creating event...');

      // Create event document
      final eventRef = _firestore.collection('events').doc();

      // Store all image URLs properly
      final eventData = {
        'id': eventRef.id,
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate.toIso8601String(),
        'eventTime': eventTime.toIso8601String(),
        'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        'imageUrls': imageUrls, // Store ALL image URLs including the first one
        'category': category,
        'organizerId': organizerId,
        'organizerName': organizerName,
        'ticketLink': ticketLink,
        'ticketPrice': ticketPrice,
        'isFree': isFree,
        'createdAt': DateTime.now().toIso8601String(),
        'interestedCount': 0,
        'attendingCount': 0,
        'school': school,
        'sellOnCampcon': sellOnCampcon,
        'ticketStock': ticketStock,
        'soldTickets': 0,
        'ticketTiers': ticketTiers?.map((t) => t.toJson()).toList() ?? [],
        'hasMultipleTiers': hasMultipleTiers,
      };

      await eventRef.set(eventData);

      setUploadSuccess();
      debugPrint(
          '✓ Event created successfully with ${imageUrls.length} image(s)');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating event: $e');
      setUploadFailed(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
