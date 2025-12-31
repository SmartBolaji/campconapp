import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/services/backblaze.dart';
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

  //  Form state management
  File? _selectedImage;
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFree = true;

  //  Form state - Add ticket stock fields
  bool _sellOnCampcon = false;

  //  Ticket purchase state
  int _ticketQuantity = 1;
  String? _selectedPaymentMethod;
  bool _isProcessingPurchase = false;

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
  Set<String> _attendingEvents = {};

  // Current user ID for prioritizing their events
  String? _currentUserId;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  List<EventModel> get allEvents => _allEvents;
  EventUploadStatus get uploadStatus => _uploadStatus;
  String get uploadMessage => _uploadMessage;
  bool get showUploadBar => _showUploadBar;
  double get uploadProgress => _uploadProgress;

  //  Form getters
  File? get selectedImage => _selectedImage;
  String? get selectedCategoryForForm => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  bool get isFree => _isFree;

  //  Form getters - Add new getter
  bool get sellOnCampcon => _sellOnCampcon;

  //  Ticket purchase getters
  int get ticketQuantity => _ticketQuantity;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isProcessingPurchase => _isProcessingPurchase;
  bool get canPurchase => _selectedPaymentMethod != null;

  // Check if user is attending
  bool isAttending(String eventId) => _attendingEvents.contains(eventId);

  // Set current user ID (call this from UI on init)
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Get current user's events
  List<EventModel> get myEvents {
    if (_currentUserId == null) return [];
    return filteredEvents
        .where((e) => e.organizerId == _currentUserId)
        .toList();
  }

  // Get other users' events
  List<EventModel> get otherEvents {
    if (_currentUserId == null) return filteredEvents;
    return filteredEvents
        .where((e) => e.organizerId != _currentUserId)
        .toList();
  }

  // Check if current user has any events
  bool get hasMyEvents {
    if (_currentUserId == null) return false;
    return _allEvents.any((e) => e.organizerId == _currentUserId);
  }

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
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        list = list.where((e) => e.eventDate.isBefore(monthEnd)).toList();
        list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        break;
      case 'Price: Low to High':
        list.sort((a, b) => (a.ticketPrice ?? 0).compareTo(b.ticketPrice ?? 0));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => (b.ticketPrice ?? 0).compareTo(a.ticketPrice ?? 0));
        break;
      case 'Most Popular':
        list.sort((a, b) => b.attendingCount.compareTo(a.attendingCount));
        break;
    }

    return list;
  }

  // Get filtered list separated into sections
  Map<String, List<EventModel>> get filteredEventsSectioned {
    List<EventModel> list = List.from(_allEvents);

    // Filter by category
    if (selectedCategory != 'All') {
      list = list.where((e) => e.category == selectedCategory).toList();
    }

    // Sort function based on sortBy
    int Function(EventModel, EventModel) sortFunction;
    switch (sortBy) {
      case 'Upcoming':
        sortFunction = (a, b) => a.eventDate.compareTo(b.eventDate);
        break;
      case 'This Week':
        final weekEnd = DateTime.now().add(const Duration(days: 7));
        list = list.where((e) => e.eventDate.isBefore(weekEnd)).toList();
        sortFunction = (a, b) => a.eventDate.compareTo(b.eventDate);
        break;
      case 'This Month':
        final now = DateTime.now();
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        list = list.where((e) => e.eventDate.isBefore(monthEnd)).toList();
        sortFunction = (a, b) => a.eventDate.compareTo(b.eventDate);
        break;
      case 'Price: Low to High':
        sortFunction =
            (a, b) => (a.ticketPrice ?? 0).compareTo(b.ticketPrice ?? 0);
        break;
      case 'Price: High to Low':
        sortFunction =
            (a, b) => (b.ticketPrice ?? 0).compareTo(a.ticketPrice ?? 0);
        break;
      case 'Most Popular':
        sortFunction = (a, b) => b.attendingCount.compareTo(a.attendingCount);
        break;
      default:
        sortFunction = (a, b) => a.eventDate.compareTo(b.eventDate);
    }

    if (_currentUserId != null) {
      final myItems = list
          .where((e) => e.organizerId == _currentUserId)
          .toList()
        ..sort(sortFunction);
      final otherItems = list
          .where((e) => e.organizerId != _currentUserId)
          .toList()
        ..sort(sortFunction);

      return {
        'my': myItems,
        'other': otherItems,
      };
    }

    list.sort(sortFunction);
    return {
      'my': [],
      'other': list,
    };
  }

  //  Ticket purchase methods
  void setTicketQuantity(int quantity) {
    _ticketQuantity = quantity;
    notifyListeners();
  }

  void incrementTicketQuantity(int maxQuantity) {
    if (_ticketQuantity < maxQuantity) {
      _ticketQuantity++;
      notifyListeners();
    }
  }

  void decrementTicketQuantity() {
    if (_ticketQuantity > 1) {
      _ticketQuantity--;
      notifyListeners();
    }
  }

  void setPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void resetTicketPurchase() {
    _ticketQuantity = 1;
    _selectedPaymentMethod = null;
    _isProcessingPurchase = false;
    notifyListeners();
  }

  double calculateTotalPrice(double unitPrice) {
    return unitPrice * _ticketQuantity;
  }

  //  Form methods
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

  //  Form methods - Add new method
  void toggleSellOnCampcon(bool value) {
    _sellOnCampcon = value;
    notifyListeners();
  }

  void clearForm() {
    _selectedImage = null;
    _selectedCategory = null;
    _selectedDate = null;
    _selectedTime = null;
    _isFree = true;
    _sellOnCampcon = false;
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
    bool sellOnCampcon = false,
    int? ticketStock,
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

    // Validate ticket stock if selling on CampCon
    if (sellOnCampcon && !isFree) {
      if (ticketStock == null || ticketStock <= 0) {
        _error = 'Please enter valid ticket quantity';
        return false;
      }
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
        debugPrint(' Image uploaded successfully');

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
        sellOnCampcon: sellOnCampcon,
        ticketStock: ticketStock,
        soldTickets: 0,
      );

      await eventRef.set(event.toJson());

      // Add to local list
      addEvent(event);

      setUploadSuccess();
      debugPrint(' Event created successfully for $school');
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

      debugPrint(' Loaded ${_allEvents.length} events from $school');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load events';
      notifyListeners();
      debugPrint('❌ Error loading events: $e');
    }
  }

  Future<void> loadUserInteractions(String userId) async {
    try {
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

  // Toggle attending status and save to event subcollection
  Future<void> toggleAttending(
      String eventId, String userId, String userName) async {
    try {
      final isCurrentlyAttending = _attendingEvents.contains(eventId);
      final eventRef = _firestore.collection('events').doc(eventId);
      final userAttendingRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('attending_events')
          .doc(eventId);
      final eventAttendeesRef = eventRef.collection('attendees').doc(userId);

      if (isCurrentlyAttending) {
        // Remove from attending
        await Future.wait([
          userAttendingRef.delete(),
          eventAttendeesRef.delete(),
          eventRef.update({
            'attendingCount': FieldValue.increment(-1),
          }),
        ]);

        _attendingEvents.remove(eventId);

        // Update local event count
        final eventIndex = _allEvents.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = _allEvents[eventIndex];
          _allEvents[eventIndex] = EventModel(
            id: event.id,
            title: event.title,
            description: event.description,
            location: event.location,
            eventDate: event.eventDate,
            eventTime: event.eventTime,
            imageUrl: event.imageUrl,
            imageFile: event.imageFile,
            category: event.category,
            organizerId: event.organizerId,
            organizerName: event.organizerName,
            ticketLink: event.ticketLink,
            ticketPrice: event.ticketPrice,
            isFree: event.isFree,
            createdAt: event.createdAt,
            interestedCount: event.interestedCount,
            attendingCount: (event.attendingCount - 1).clamp(0, 999999),
            school: event.school,
            sellOnCampcon: event.sellOnCampcon,
            ticketStock: event.ticketStock,
            soldTickets: event.soldTickets,
          );
        }
      } else {
        // Add to attending
        final attendeeData = {
          'userId': userId,
          'userName': userName,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await Future.wait([
          userAttendingRef.set({'timestamp': FieldValue.serverTimestamp()}),
          eventAttendeesRef.set(attendeeData),
          eventRef.update({
            'attendingCount': FieldValue.increment(1),
          }),
        ]);

        _attendingEvents.add(eventId);

        // Update local event count
        final eventIndex = _allEvents.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = _allEvents[eventIndex];
          _allEvents[eventIndex] = EventModel(
            id: event.id,
            title: event.title,
            description: event.description,
            location: event.location,
            eventDate: event.eventDate,
            eventTime: event.eventTime,
            imageUrl: event.imageUrl,
            imageFile: event.imageFile,
            category: event.category,
            organizerId: event.organizerId,
            organizerName: event.organizerName,
            ticketLink: event.ticketLink,
            ticketPrice: event.ticketPrice,
            isFree: event.isFree,
            createdAt: event.createdAt,
            interestedCount: event.interestedCount,
            attendingCount: event.attendingCount + 1,
            school: event.school,
            sellOnCampcon: event.sellOnCampcon,
            ticketStock: event.ticketStock,
            soldTickets: event.soldTickets,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling attending: $e');
    }
  }

  // Process ticket purchase
  Future<bool> processPurchase({
    required String eventId,
    required String userId,
    required String userName,
    required double totalPrice,
  }) async {
    _isProcessingPurchase = true;
    notifyListeners();

    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final ticketRef = eventRef.collection('tickets').doc();

      // Create ticket record
      await ticketRef.set({
        'ticketId': ticketRef.id,
        'eventId': eventId,
        'userId': userId,
        'userName': userName,
        'quantity': _ticketQuantity,
        'paymentMethod': _selectedPaymentMethod,
        'totalPrice': totalPrice,
        'purchasedAt': FieldValue.serverTimestamp(),
        'status': 'confirmed',
      });

      // Update sold tickets count
      await eventRef.update({
        'soldTickets': FieldValue.increment(_ticketQuantity),
      });

      // Also add to attending
      await toggleAttending(eventId, userId, userName);

      // Reset purchase state
      resetTicketPurchase();

      return true;
    } catch (e) {
      debugPrint('Error processing purchase: $e');
      _isProcessingPurchase = false;
      notifyListeners();
      return false;
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
