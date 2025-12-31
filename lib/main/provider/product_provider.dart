import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current product
  Product? _currentProduct;
  UserModel? _sellerData;

  // Order details
  int _quantity = 1;
  String? _selectedPickupLocationId;
  PickupCenterModel? _selectedPickupCenter;
  String? _selectedPaymentMethod;
  String _orderNotes = '';

  // Pickup centers
  List<PickupCenterModel> _approvedPickupCenters = [];
  bool _isLoadingPickupCenters = false;

  // Loading states
  bool _isLoadingSeller = false;
  bool _isPlacingOrder = false;
  String? _error;

  // Getters
  Product? get currentProduct => _currentProduct;
  UserModel? get sellerData => _sellerData;
  int get quantity => _quantity;
  String? get selectedPickupLocationId => _selectedPickupLocationId;
  PickupCenterModel? get selectedPickupCenter => _selectedPickupCenter;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  String get orderNotes => _orderNotes;
  bool get isLoadingSeller => _isLoadingSeller;
  bool get isLoadingPickupCenters => _isLoadingPickupCenters;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  // Pickup centers list
  List<PickupCenterModel> get approvedPickupCenters => _approvedPickupCenters;
  bool get hasPickupCenters => _approvedPickupCenters.isNotEmpty;

  // Computed properties
  double get totalPrice => (_currentProduct?.price ?? 0) * _quantity;
  bool get canProceedToOrder =>
      _selectedPickupCenter != null && _selectedPaymentMethod != null;

  // Payment methods
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'online',
      title: 'Pay Online',
      subtitle: 'Secure payment before pickup',
      description: 'Complete payment now using your card or wallet',
    ),
    PaymentMethod(
      id: 'pickup',
      title: 'Pay on Pickup',
      subtitle: 'Pay when collecting the item',
      description: 'Pay cash or transfer when you collect the item',
    ),
  ];

  // Load product and seller data
  Future<void> loadProduct(Product product) async {
    _currentProduct = product;
    _resetOrderDetails();
    notifyListeners();

    // Load seller data and pickup centers in parallel
    await Future.wait([
      _loadSellerData(product.sellerId),
      loadApprovedPickupCenters(),
    ]);
  }

  Future<void> _loadSellerData(String sellerId) async {
    _isLoadingSeller = true;
    _error = null;
    notifyListeners();

    try {
      final userDoc = await _firestore.collection('users').doc(sellerId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          // Convert Timestamp fields to ISO strings for UserModel
          final processedData = Map<String, dynamic>.from(data);

          if (data['createdAt'] is Timestamp) {
            processedData['createdAt'] =
                (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }

          if (data['updatedAt'] is Timestamp) {
            processedData['updatedAt'] =
                (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }

          _sellerData = UserModel.fromJson(processedData);
        }
      }

      _isLoadingSeller = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSeller = false;
      _error = 'Failed to load seller information';
      notifyListeners();
      debugPrint('❌ Error loading seller data: $e');
    }
  }

  // Load approved pickup centers from Firestore
  Future<void> loadApprovedPickupCenters() async {
    _isLoadingPickupCenters = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('pickup_centers')
          .where('status', isEqualTo: 'approved')
          .orderBy('rating', descending: true)
          .get();

      _approvedPickupCenters = snapshot.docs.map((doc) {
        return PickupCenterModel.fromMap(doc.data());
      }).toList();

      _isLoadingPickupCenters = false;
      notifyListeners();
      debugPrint(' Loaded ${_approvedPickupCenters.length} pickup centers');
    } catch (e) {
      _isLoadingPickupCenters = false;
      debugPrint('❌ Error loading pickup centers: $e');
      // Don't set error - this is not critical
      notifyListeners();
    }
  }

  // Get pickup center by ID
  PickupCenterModel? getPickupCenterById(String id) {
    try {
      return _approvedPickupCenters.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update quantity
  void incrementQuantity() {
    if (_quantity < 99) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  void setQuantity(int value) {
    if (value > 0 && value <= 99) {
      _quantity = value;
      notifyListeners();
    }
  }

  // Update pickup location
  void setPickupLocation(String? centerId) {
    _selectedPickupLocationId = centerId;
    _selectedPickupCenter =
        centerId != null ? getPickupCenterById(centerId) : null;
    notifyListeners();
  }

  // Update payment method
  void setPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Update order notes
  void setOrderNotes(String notes) {
    _orderNotes = notes;
    notifyListeners();
  }

  // Reset order details
  void _resetOrderDetails() {
    _quantity = 1;
    _selectedPickupLocationId = null;
    _selectedPickupCenter = null;
    _selectedPaymentMethod = null;
    _orderNotes = '';
  }

  // Place order
  Future<bool> placeOrder(String buyerId) async {
    if (_currentProduct == null || !canProceedToOrder) {
      _error = 'Please select pickup location and payment method';
      notifyListeners();
      return false;
    }

    _isPlacingOrder = true;
    _error = null;
    notifyListeners();

    try {
      final orderRef = _firestore.collection('orders').doc();

      final orderData = {
        'id': orderRef.id,
        'productId': _currentProduct!.id,
        'productName': _currentProduct!.name,
        'productImage': _currentProduct!.imageUrl,
        'sellerId': _currentProduct!.sellerId,
        'sellerName': _sellerData?.fullName ?? 'Unknown',
        'buyerId': buyerId,
        'quantity': _quantity,
        'unitPrice': _currentProduct!.discountedPrice ?? _currentProduct!.price,
        'totalPrice': totalPrice,
        // Store pickup center details
        'pickupLocationId': _selectedPickupCenter!.id,
        'pickupLocation': _selectedPickupCenter!.name,
        'pickupAddress': _selectedPickupCenter!.fullAddress,
        'pickupPhone': _selectedPickupCenter!.phoneNumber,
        'pickupCenterOwnerId': _selectedPickupCenter!.ownerId,
        'paymentMethod': _selectedPaymentMethod,
        'orderNotes': _orderNotes.isNotEmpty ? _orderNotes : null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      // Increment pickup center's total pickups
      await _firestore
          .collection('pickup_centers')
          .doc(_selectedPickupCenter!.id)
          .update({
        'totalPickups': FieldValue.increment(1),
      });

      _isPlacingOrder = false;
      _resetOrderDetails();
      notifyListeners();

      debugPrint(' Order placed successfully');
      return true;
    } catch (e) {
      _isPlacingOrder = false;
      _error = 'Failed to place order. Please try again.';
      notifyListeners();
      debugPrint('❌ Error placing order: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _currentProduct = null;
    _sellerData = null;
    _resetOrderDetails();
    _approvedPickupCenters = [];
    _isLoadingSeller = false;
    _isLoadingPickupCenters = false;
    _isPlacingOrder = false;
    _error = null;
    notifyListeners();
  }
}

// Payment method model
class PaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final String description;

  PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
