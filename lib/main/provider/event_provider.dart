import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/services/backblaze.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

enum EventUploadStatus {
  idle,
  uploading,
  processing,
  success,
  cancelled,
  failed,
}

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackblazeService _backblazeService = BackblazeService(
    keyId: '0050fae555030410000000003',
    applicationKey: 'K005wG+vROJBYZFRpo0HVDn+Q4V3+zw',
    bucketId: 'f0ef2ace6525c59093a00411',
    bucketName: 'Campcon-Media',
  );

  String sortBy = 'Upcoming';
  String selectedCategory = 'All';

  // Loading states
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  // Silent upload properties
  EventUploadStatus _uploadStatus = EventUploadStatus.idle;
  String _uploadMessage = '';
  bool _showUploadBar = false;
  double _uploadProgress = 0.0;
  Function? _cancelCallback;

  // ✅ Form state management
  File? _selectedImage;
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFree = true;

  // Subscription
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  // Sort options
  final List<String> sortOptions = [
    'Upcoming',
    'This Week',
    'This Month',
    'Price: Low to High',
    'Price: High to Low',
    'Most Popular',
  ];

  // Event categories
  final List<String> eventCategories = [
    'All',
    'Music',
    'Sports',
    'Academic',
    'Social',
    'Workshop',
    'Party',
    'Competition',
    'Other',
  ];

  // Cache for events
  List<EventModel> _allEvents = [];

  // User interactions
  Set<String> _interestedEvents = {};
  Set<String> _attendingEvents = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  List<EventModel> get allEvents => _allEvents;
  EventUploadStatus get uploadStatus => _uploadStatus;
  String get uploadMessage => _uploadMessage;
  bool get showUploadBar => _showUploadBar;
  double get uploadProgress => _uploadProgress;

  // ✅ Form getters
  File? get selectedImage => _selectedImage;
  String? get selectedCategoryForForm => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  bool get isFree => _isFree;

  // Check if user is interested/attending
  bool isInterested(String eventId) => _interestedEvents.contains(eventId);
  bool isAttending(String eventId) => _attendingEvents.contains(eventId);

  // Get filtered and sorted list
  List<EventModel> get filteredEvents {
    List<EventModel> list = List.from(_allEvents);

    // Filter by category
    if (selectedCategory != 'All') {
      list = list.where((e) => e.category == selectedCategory).toList();
    }

    // Sort
    switch (sortBy) {
      case 'Upcoming':
        list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        break;
      case 'This Week':
        final now = DateTime.now();
        final weekEnd = now.add(const Duration(days: 7));
        list = list.where((e) => e.eventDate.isBefore(weekEnd)).toList();
        list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        break;
      case 'This Month':
        final now = DateTime.now();
        list = list
            .where((e) =>
                e.eventDate.month == now.month && e.eventDate.year == now.year)
            .toList();
        list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => (a.ticketPrice ?? 0).compareTo(b.ticketPrice ?? 0));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => (b.ticketPrice ?? 0).compareTo(a.ticketPrice ?? 0));
        break;
      case 'Most Popular':
        list.sort((a, b) => b.interestedCount.compareTo(a.interestedCount));
        break;
    }

    return list;
  }

  // ✅ Form methods
  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

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
    notifyListeners();
  }

  void clearForm() {
    _selectedImage = null;
    _selectedCategory = null;
    _selectedDate = null;
    _selectedTime = null;
    _isFree = true;
    notifyListeners();
  }

  // Start silent upload
  void startSilentUpload({Function? onCancel}) {
    _uploadStatus = EventUploadStatus.uploading;
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
    _uploadStatus = EventUploadStatus.processing;
    _uploadMessage = message;
    notifyListeners();
  }

  // Set upload success
  void setUploadSuccess() {
    _uploadStatus = EventUploadStatus.success;
    _uploadMessage = 'Event created successfully!';
    _uploadProgress = 1.0;
    notifyListeners();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      hideUploadBar();
    });
  }

  // Set upload failed
  void setUploadFailed(String error) {
    _uploadStatus = EventUploadStatus.failed;
    _uploadMessage = 'Upload failed: $error';
    notifyListeners();

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      hideUploadBar();
    });
  }

  // Cancel upload
  void cancelUpload() {
    _uploadStatus = EventUploadStatus.cancelled;
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
    _uploadStatus = EventUploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _cancelCallback = null;
    notifyListeners();
  }

  // Reset upload state
  void resetUpload() {
    _uploadStatus = EventUploadStatus.idle;
    _uploadProgress = 0.0;
    _uploadMessage = '';
    _showUploadBar = false;
    _cancelCallback = null;
    notifyListeners();
  }

  // Create event silently
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
    File? image,
  }) async {
    if (title.trim().isEmpty ||
        description.trim().isEmpty ||
        location.trim().isEmpty) {
      _error = 'Please fill all required fields';
      return false;
    }

    if (!isFree && (ticketPrice == null || ticketPrice <= 0)) {
      _error = 'Please enter a valid ticket price';
      return false;
    }

    startSilentUpload();
    _error = null;

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

      setProcessing('Creating event...');
      updateSilentUploadProgress(0.9, message: 'Creating event...');

      final eventRef = _firestore.collection('events').doc();
      final event = EventModel(
        id: eventRef.id,
        title: title.trim(),
        description: description.trim(),
        location: location.trim(),
        eventDate: eventDate,
        eventTime: eventTime,
        imageUrl: imageUrl,
        category: category,
        organizerId: organizerId,
        organizerName: organizerName,
        ticketLink: ticketLink?.trim(),
        ticketPrice: ticketPrice,
        isFree: isFree,
        createdAt: DateTime.now(),
        school: school,
      );

      await eventRef.set(event.toJson());

      // Add to local list
      addEvent(event);

      setUploadSuccess();
      debugPrint('✅ Event created successfully for $school');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating event: $e');
      setUploadFailed('Failed to create event. Please try again.');
      return false;
    }
  }

  // Load events for specific school
  Future<void> loadEvents(String school) async {
    if (_hasLoaded || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventsSubscription?.cancel();

      final snapshot = await _firestore
          .collection('events')
          .orderBy('eventDate', descending: false)
          .get();

      _allEvents = snapshot.docs
          .map((doc) {
            try {
              return EventModel.fromJson(doc.data());
            } catch (e) {
              debugPrint('Error parsing event: $e');
              return null;
            }
          })
          .whereType<EventModel>()
          .toList();

      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();

      _eventsSubscription = _firestore
          .collection('events')
          .orderBy('eventDate', descending: false)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              try {
                final event = EventModel.fromJson(change.doc.data()!);
                if (!_allEvents.any((e) => e.id == event.id)) {
                  _allEvents.insert(0, event);
                  notifyListeners();
                }
              } catch (e) {
                debugPrint('Error adding new event: $e');
              }
            }
          }
        }
      });

      debugPrint('✅ Loaded ${_allEvents.length} events from $school');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load events';
      notifyListeners();
      debugPrint('❌ Error loading events: $e');
    }
  }

  Future<void> loadUserInteractions(String userId) async {
    try {
      final interestedSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('interested_events')
          .get();

      _interestedEvents = interestedSnapshot.docs.map((doc) => doc.id).toSet();

      final attendingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attending_events')
          .get();

      _attendingEvents = attendingSnapshot.docs.map((doc) => doc.id).toSet();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user interactions: $e');
    }
  }

  Future<void> toggleInterested(String eventId, String userId) async {
    try {
      final isCurrentlyInterested = _interestedEvents.contains(eventId);

      if (isCurrentlyInterested) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('interested_events')
            .doc(eventId)
            .delete();

        _interestedEvents.remove(eventId);

        await _firestore.collection('events').doc(eventId).update({
          'interestedCount': FieldValue.increment(-1),
        });
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('interested_events')
            .doc(eventId)
            .set({'timestamp': FieldValue.serverTimestamp()});

        _interestedEvents.add(eventId);

        await _firestore.collection('events').doc(eventId).update({
          'interestedCount': FieldValue.increment(1),
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling interested: $e');
    }
  }

  Future<void> toggleAttending(String eventId, String userId) async {
    try {
      final isCurrentlyAttending = _attendingEvents.contains(eventId);

      if (isCurrentlyAttending) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attending_events')
            .doc(eventId)
            .delete();

        _attendingEvents.remove(eventId);

        await _firestore.collection('events').doc(eventId).update({
          'attendingCount': FieldValue.increment(-1),
        });
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attending_events')
            .doc(eventId)
            .set({'timestamp': FieldValue.serverTimestamp()});

        _attendingEvents.add(eventId);

        await _firestore.collection('events').doc(eventId).update({
          'attendingCount': FieldValue.increment(1),
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling attending: $e');
    }
  }

  void changeSortBy(String newSortBy) {
    sortBy = newSortBy;
    notifyListeners();
  }

  void changeCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addEvent(EventModel event) {
    _allEvents.removeWhere((e) => e.id == event.id);
    _allEvents.insert(0, event);
    notifyListeners();
  }

  void removeEvent(String eventId) {
    _allEvents.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  Future<void> refreshEvents(String school) async {
    _hasLoaded = false;
    _allEvents.clear();
    await loadEvents(school);
  }

  void clearCache() {
    _allEvents.clear();
    _interestedEvents.clear();
    _attendingEvents.clear();
    _hasLoaded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
