import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class EventProvider extends ChangeNotifier with UploadStatusMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String sortBy = 'Upcoming';
  String selectedCategory = 'All';

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoaded = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastEventDoc;
  String? _error;

  static const int _initialPageSize = 15;
  static const int _pageSize = 10;

  //  Form state management
  File? _selectedImage;
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isFree = true;

  // Selected tier index for ticket selling (new)
  int? _selectedTierIndex;

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

  // Related events
  List<EventModel> _relatedEvents = [];
  bool _isLoadingRelated = false;

  // User interactions
  Set<String> _attendingEvents = {};

  // Current user ID for prioritizing their events
  String? _currentUserId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasLoaded => _hasLoaded;
  bool get hasMore => _hasMore;
  String? get error => _error;
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get relatedEvents => _relatedEvents;
  bool get isLoadingRelated => _isLoadingRelated;
  int? get selectedTierIndex => _selectedTierIndex;

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

  // Select tier
  void selectTier(int index) {
    _selectedTierIndex = index;
    _ticketQuantity = 1; // Reset quantity on tier change
    notifyListeners();
  }

  // Get selected tier
  TicketTier? getSelectedTier(EventModel event) {
    if (_selectedTierIndex == null ||
        _selectedTierIndex! >= event.ticketTiers.length) {
      return null;
    }
    return event.ticketTiers[_selectedTierIndex!];
  }

  // Fetch related events by category or organizer
  Future<void> fetchRelatedEvents(EventModel event) async {
    _isLoadingRelated = true;
    _relatedEvents = [];
    notifyListeners();

    try {
      // First try from cache
      final cached = _allEvents
          .where((e) =>
              e.id != event.id &&
              (e.category == event.category ||
                  e.organizerId == event.organizerId))
          .take(10)
          .toList();

      if (cached.isNotEmpty) {
        _relatedEvents = cached;
        _isLoadingRelated = false;
        notifyListeners();
        return;
      }

      // Fallback to Firestore query
      final snapshot = await _firestore
          .collection('events')
          .where('category', isEqualTo: event.category)
          .limit(11)
          .get();

      _relatedEvents = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .where((e) => e.id != event.id)
          .take(10)
          .toList();

      _isLoadingRelated = false;
      notifyListeners();
    } catch (e) {
      _isLoadingRelated = false;
      notifyListeners();
      debugPrint('❌ Error loading related events: $e');
    }
  }

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
    _selectedTierIndex = null;
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

  // Keep provider-specific default message while matching mixin signature.
  @override
  void setUploadSuccess({String message = 'Event created successfully!'}) {
    super.setUploadSuccess(message: message);
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
          .limit(_initialPageSize)
          .get();

      _lastEventDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= _initialPageSize;

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

  Future<void> loadMoreEvents(String school) async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('events')
          .orderBy('eventDate', descending: false)
          .limit(_pageSize);

      if (_lastEventDoc != null) {
        query = query.startAfterDocument(_lastEventDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastEventDoc = snapshot.docs.last;
        final newEvents = snapshot.docs
            .map((doc) {
              try {
                return EventModel.fromJson(doc.data() as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing event: $e');
                return null;
              }
            })
            .whereType<EventModel>()
            .where((event) => !_allEvents.any((e) => e.id == event.id))
            .toList();

        _allEvents.addAll(newEvents);
        _hasMore = snapshot.docs.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error loading more events: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
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

  /// Process ticket purchase. Returns ticket ID on success, null on failure.
  Future<String?> processPurchase({
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

      final ticketId = ticketRef.id;

      // Reset purchase state
      resetTicketPurchase();

      return ticketId;
    } catch (e) {
      debugPrint('Error processing purchase: $e');
      _isProcessingPurchase = false;
      notifyListeners();
      return null;
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

  // Update an existing event
  Future<bool> updateEvent(String eventId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('events').doc(eventId).update(data);

      // Update local cache
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final doc = await _firestore.collection('events').doc(eventId).get();
        if (doc.exists) {
          _allEvents[index] = EventModel.fromJson(doc.data()!);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update event';
      notifyListeners();
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('events').doc(eventId).delete();
      removeEvent(eventId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete event';
      notifyListeners();
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  // Cancel an event (sets cancelled status, prevents new purchases)
  Future<bool> cancelEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('events').doc(eventId).update({
        'cancelled': true,
      });

      // Update local cache
      final index = _allEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final doc = await _firestore.collection('events').doc(eventId).get();
        if (doc.exists) {
          _allEvents[index] = EventModel.fromJson(doc.data()!);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to cancel event';
      notifyListeners();
      debugPrint('Error cancelling event: $e');
      return false;
    }
  }

  Future<void> refreshEvents(String school) async {
    _hasLoaded = false;
    _hasMore = true;
    _lastEventDoc = null;
    _allEvents.clear();
    await loadEvents(school);
  }

  void clearCache() {
    _allEvents.clear();
    _attendingEvents.clear();
    _hasLoaded = false;
    _hasMore = true;
    _lastEventDoc = null;
    notifyListeners();
  }

  // --- Manage Event Dashboard Methods ---

  /// Fetch all attendees for an event
  Future<List<Map<String, dynamic>>> getAttendees(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching attendees: $e');
      return [];
    }
  }

  /// Toggle check-in status for an attendee
  Future<bool> toggleCheckIn(String eventId, String attendeeId) async {
    try {
      final ref = _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .doc(attendeeId);

      final doc = await ref.get();
      if (!doc.exists) return false;

      final currentStatus = doc.data()?['checkedIn'] ?? false;
      await ref.update({
        'checkedIn': !currentStatus,
        'checkedInAt': !currentStatus ? FieldValue.serverTimestamp() : null,
      });
      return true;
    } catch (e) {
      debugPrint('Error toggling check-in: $e');
      return false;
    }
  }

  /// Mark an attendee as checked in by ticket ID
  Future<Map<String, dynamic>?> checkInByTicketId(
      String eventId, String ticketId) async {
    try {
      // Find the ticket
      final ticketSnap = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (!ticketSnap.exists) return {'status': 'invalid'};

      final ticketData = ticketSnap.data()!;
      final userId = ticketData['userId'] as String?;
      if (userId == null) return {'status': 'invalid'};

      // Find the attendee
      final attendeeQuery = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('attendees')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (attendeeQuery.docs.isEmpty) return {'status': 'invalid'};

      final attendeeDoc = attendeeQuery.docs.first;
      final attendeeData = attendeeDoc.data();

      if (attendeeData['checkedIn'] == true) {
        return {
          'status': 'already',
          'name': attendeeData['userName'] ?? 'Unknown',
        };
      }

      await attendeeDoc.reference.update({
        'checkedIn': true,
        'checkedInAt': FieldValue.serverTimestamp(),
      });

      return {
        'status': 'success',
        'name': attendeeData['userName'] ?? 'Unknown',
      };
    } catch (e) {
      debugPrint('Error checking in by ticket: $e');
      return {'status': 'error'};
    }
  }

  /// Fetch all ticket purchases for an event
  Future<List<Map<String, dynamic>>> getTicketPurchases(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('tickets')
          .orderBy('purchasedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching ticket purchases: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
