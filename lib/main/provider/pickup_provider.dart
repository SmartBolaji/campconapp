import 'dart:async';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user's pickup center (if they have one)
  PickupCenterModel? _myPickupCenter;

  // All approved pickup centers (for buyers to select)
  List<PickupCenterModel> _approvedCenters = [];

  // Application form data
  String _centerName = '';
  String _description = '';
  String _address = '';
  String? _landmark;
  String _phoneNumber = '';
  String? _alternatePhone;
  PickupCenterType _selectedType = PickupCenterType.shop;
  List<String> _selectedDays = [];
  String _openingTime = '08:00';
  String _closingTime = '18:00';

  // State
  bool _isLoading = false;
  bool _isLoadingCenters = false;
  bool _isSubmitting = false;
  String? _error;

  // Stream subscriptions
  StreamSubscription<DocumentSnapshot>? _myPickupSubscription;
  StreamSubscription<QuerySnapshot>? _centersSubscription;

  // Getters
  PickupCenterModel? get myPickupCenter => _myPickupCenter;
  List<PickupCenterModel> get approvedCenters => _approvedCenters;
  bool get hasPickupCenter => _myPickupCenter != null;

  String get centerName => _centerName;
  String get description => _description;
  String get address => _address;
  String? get landmark => _landmark;
  String get phoneNumber => _phoneNumber;
  String? get alternatePhone => _alternatePhone;
  PickupCenterType get selectedType => _selectedType;
  List<String> get selectedDays => _selectedDays;
  String get openingTime => _openingTime;
  String get closingTime => _closingTime;

  bool get isLoading => _isLoading;
  bool get isLoadingCenters => _isLoadingCenters;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // Available days
  final List<String> availableDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Check if form is valid
  bool get isFormValid =>
      _centerName.trim().isNotEmpty &&
      _description.trim().isNotEmpty &&
      _address.trim().isNotEmpty &&
      _phoneNumber.trim().isNotEmpty &&
      _selectedDays.isNotEmpty;

  // Initialize provider for a user
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Cancel existing subscriptions
    await _myPickupSubscription?.cancel();
    await _centersSubscription?.cancel();

    // Listen to user's pickup center
    _myPickupSubscription =
        _firestore.collection('pickup_centers').doc(userId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _myPickupCenter = PickupCenterModel.fromMap(snapshot.data()!);
        } else {
          _myPickupCenter = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load your pickup center';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Error loading pickup center: $error');
      },
    );

    // Load approved centers
    await loadApprovedCenters();
  }

  // Load all approved pickup centers
  Future<void> loadApprovedCenters() async {
    _isLoadingCenters = true;
    notifyListeners();

    await _centersSubscription?.cancel();

    _centersSubscription = _firestore
        .collection('pickup_centers')
        .where('status', isEqualTo: 'approved')
        .orderBy('rating', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _approvedCenters = snapshot.docs.map((doc) {
          return PickupCenterModel.fromMap(doc.data());
        }).toList();
        _isLoadingCenters = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load pickup centers';
        _isLoadingCenters = false;
        notifyListeners();
        debugPrint('❌ Error loading approved centers: $error');
      },
    );
  }

  // Form setters
  void setCenterName(String value) {
    _centerName = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setLandmark(String? value) {
    _landmark = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setAlternatePhone(String? value) {
    _alternatePhone = value;
    notifyListeners();
  }

  void setSelectedType(PickupCenterType type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleDay(String day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    notifyListeners();
  }

  void selectAllDays() {
    _selectedDays = List.from(availableDays);
    notifyListeners();
  }

  void selectWeekdays() {
    _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    notifyListeners();
  }

  void clearDays() {
    _selectedDays = [];
    notifyListeners();
  }

  void setOpeningTime(String time) {
    _openingTime = time;
    notifyListeners();
  }

  void setClosingTime(String time) {
    _closingTime = time;
    notifyListeners();
  }

  // Submit application
  Future<bool> submitApplication({
    required String userId,
    required String userName,
    String? userImage,
  }) async {
    if (!isFormValid) {
      _error = 'Please fill in all required fields';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      final pickupCenter = PickupCenterModel(
        id: userId,
        ownerId: userId,
        ownerName: userName,
        ownerImage: userImage,
        name: _centerName.trim(),
        description: _description.trim(),
        address: _address.trim(),
        landmark: _landmark?.trim(),
        phoneNumber: _phoneNumber.trim(),
        alternatePhone: _alternatePhone?.trim(),
        type: _selectedType,
        status: PickupCenterStatus.pending,
        operatingDays: _selectedDays,
        openingTime: _openingTime,
        closingTime: _closingTime,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('pickup_centers')
          .doc(userId)
          .set(pickupCenter.toMap());

      _isSubmitting = false;
      _resetForm();
      notifyListeners();

      debugPrint('✅ Pickup center application submitted');
      return true;
    } catch (e) {
      _isSubmitting = false;
      _error = 'Failed to submit application';
      notifyListeners();
      debugPrint('❌ Error submitting application: $e');
      return false;
    }
  }

  // Update pickup center
  Future<bool> updatePickupCenter({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('pickup_centers').doc(userId).update(updates);

      _isSubmitting = false;
      notifyListeners();

      debugPrint('✅ Pickup center updated');
      return true;
    } catch (e) {
      _isSubmitting = false;
      _error = 'Failed to update pickup center';
      notifyListeners();
      debugPrint('❌ Error updating pickup center: $e');
      return false;
    }
  }

  // Delete/withdraw application
  Future<bool> withdrawApplication(String userId) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('pickup_centers').doc(userId).delete();

      _myPickupCenter = null;
      _isSubmitting = false;
      notifyListeners();

      debugPrint('✅ Application withdrawn');
      return true;
    } catch (e) {
      _isSubmitting = false;
      _error = 'Failed to withdraw application';
      notifyListeners();
      debugPrint('❌ Error withdrawing application: $e');
      return false;
    }
  }

  // Get pickup center names for dropdown (used in ProductProvider)
  List<String> get pickupLocationNames {
    return _approvedCenters.map((center) => center.name).toList();
  }

  // Get pickup center by name
  PickupCenterModel? getCenterByName(String name) {
    try {
      return _approvedCenters.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  // Reset form
  void _resetForm() {
    _centerName = '';
    _description = '';
    _address = '';
    _landmark = null;
    _phoneNumber = '';
    _alternatePhone = null;
    _selectedType = PickupCenterType.shop;
    _selectedDays = [];
    _openingTime = '08:00';
    _closingTime = '18:00';
  }

  // Pre-fill form for editing
  void loadFormFromCenter(PickupCenterModel center) {
    _centerName = center.name;
    _description = center.description;
    _address = center.address;
    _landmark = center.landmark;
    _phoneNumber = center.phoneNumber;
    _alternatePhone = center.alternatePhone;
    _selectedType = center.type;
    _selectedDays = List.from(center.operatingDays);
    _openingTime = center.openingTime;
    _closingTime = center.closingTime;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear and reset
  void clear() {
    _myPickupSubscription?.cancel();
    _centersSubscription?.cancel();
    _myPickupCenter = null;
    _approvedCenters = [];
    _resetForm();
    _isLoading = false;
    _isLoadingCenters = false;
    _isSubmitting = false;
    _error = null;
  }

  @override
  void dispose() {
    _myPickupSubscription?.cancel();
    _centersSubscription?.cancel();
    super.dispose();
  }
}
