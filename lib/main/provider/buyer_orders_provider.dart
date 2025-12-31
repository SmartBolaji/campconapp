import 'dart:async';
import 'package:campcon/main/models/order_model.dart';
import 'package:campcon/main/models/review_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BuyerOrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current buyer ID
  String? _buyerId;

  // Orders lists
  List<OrderModel> _allOrders = [];
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _completedOrders = [];
  List<OrderModel> _cancelledOrders = [];

  // Seller data cache
  final Map<String, UserModel> _sellersCache = {};

  // Reviews cache (to check if order has been reviewed)
  final Set<String> _reviewedOrderIds = {};

  // State
  bool _isLoading = false;
  bool _isSubmittingReview = false;
  String? _error;
  int _selectedTabIndex = 0;

  // Stream subscription
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  List<OrderModel> get cancelledOrders => _cancelledOrders;

  bool get isLoading => _isLoading;
  bool get isSubmittingReview => _isSubmittingReview;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;

  Map<String, UserModel> get sellersCache => _sellersCache;

  // Count of active orders (for badge)
  int get activeOrdersCount => _activeOrders.length;

  // Get orders for current tab
  List<OrderModel> get currentTabOrders {
    switch (_selectedTabIndex) {
      case 0:
        return _activeOrders;
      case 1:
        return _completedOrders;
      case 2:
        return _cancelledOrders;
      default:
        return _allOrders;
    }
  }

  // Initialize with buyer ID
  Future<void> initialize(String buyerId) async {
    if (_buyerId == buyerId && _ordersSubscription != null) return;

    _buyerId = buyerId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Cancel existing subscription
    await _ordersSubscription?.cancel();

    // Start listening to orders
    _ordersSubscription = _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _processOrders(snapshot.docs);
      },
      onError: (error) {
        _error = 'Failed to load orders: $error';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Error listening to orders: $error');
      },
    );

    // Load reviewed order IDs
    await _loadReviewedOrders(buyerId);
  }

  void _processOrders(List<QueryDocumentSnapshot> docs) {
    _allOrders = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromMap(data);
    }).toList();

    // Categorize orders
    _activeOrders = _allOrders
        .where(
            (o) => o.isPending || o.isConfirmed || o.isProcessing || o.isReady)
        .toList();
    _completedOrders = _allOrders.where((o) => o.isCompleted).toList();
    _cancelledOrders = _allOrders.where((o) => o.isCancelled).toList();

    // Load seller data for active orders
    _loadSellersData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSellersData() async {
    // Get unique seller IDs
    final sellerIds = <String>{};
    for (var order in _allOrders) {
      if (!_sellersCache.containsKey(order.sellerId)) {
        sellerIds.add(order.sellerId);
      }
    }

    // Fetch seller data
    for (var sellerId in sellerIds) {
      try {
        final doc = await _firestore.collection('users').doc(sellerId).get();
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          // Handle Timestamp conversion
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] =
                (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          if (data['updatedAt'] is Timestamp) {
            data['updatedAt'] =
                (data['updatedAt'] as Timestamp).toDate().toIso8601String();
          }
          _sellersCache[sellerId] = UserModel.fromJson(data);
        }
      } catch (e) {
        debugPrint('❌ Error loading seller data for $sellerId: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _loadReviewedOrders(String buyerId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('buyerId', isEqualTo: buyerId)
          .get();

      _reviewedOrderIds.clear();
      for (var doc in reviewsSnapshot.docs) {
        final orderId = doc.data()['orderId'] as String?;
        if (orderId != null) {
          _reviewedOrderIds.add(orderId);
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading reviewed orders: $e');
    }
  }

  // Check if order has been reviewed
  bool hasReviewed(String orderId) {
    return _reviewedOrderIds.contains(orderId);
  }

  // Set selected tab
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Get seller info
  UserModel? getSeller(String sellerId) {
    return _sellersCache[sellerId];
  }

  // Submit review
  Future<bool> submitReview({
    required String orderId,
    required String productId,
    required String sellerId,
    required String buyerName,
    String? buyerImage,
    required double rating,
    String? comment,
  }) async {
    if (_buyerId == null) return false;

    _isSubmittingReview = true;
    _error = null;
    notifyListeners();

    try {
      final reviewRef = _firestore.collection('reviews').doc();

      final review = ReviewModel(
        id: reviewRef.id,
        orderId: orderId,
        productId: productId,
        buyerId: _buyerId!,
        buyerName: buyerName,
        buyerImage: buyerImage,
        sellerId: sellerId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      // Save review
      await reviewRef.set(review.toMap());

      // Update order to mark as reviewed
      await _firestore.collection('orders').doc(orderId).update({
        'hasReview': true,
        'reviewId': reviewRef.id,
      });

      // Update product's average rating
      await _updateProductRating(productId);

      // Update seller's average rating
      await _updateSellerRating(sellerId);

      // Add to reviewed orders cache
      _reviewedOrderIds.add(orderId);

      _isSubmittingReview = false;
      notifyListeners();
      debugPrint(' Review submitted successfully');
      return true;
    } catch (e) {
      _isSubmittingReview = false;
      _error = 'Failed to submit review';
      notifyListeners();
      debugPrint('❌ Error submitting review: $e');
      return false;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }

      final avgRating = totalRating / reviewsSnapshot.docs.length;

      await _firestore.collection('products').doc(productId).update({
        'averageRating': avgRating,
        'reviewCount': reviewsSnapshot.docs.length,
      });
    } catch (e) {
      debugPrint('❌ Error updating product rating: $e');
    }
  }

  Future<void> _updateSellerRating(String sellerId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }

      final avgRating = totalRating / reviewsSnapshot.docs.length;

      await _firestore.collection('users').doc(sellerId).update({
        'sellerRating': avgRating,
        'totalReviews': reviewsSnapshot.docs.length,
      });
    } catch (e) {
      debugPrint('❌ Error updating seller rating: $e');
    }
  }

  // Cancel order (buyer can cancel if still pending)
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      // Check if order is still pending
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return false;

      final status = orderDoc.data()?['status'];
      if (status != 'pending') {
        _error = 'Can only cancel pending orders';
        notifyListeners();
        return false;
      }

      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'cancelledBy': 'buyer',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(' Order cancelled by buyer');
      return true;
    } catch (e) {
      _error = 'Failed to cancel order';
      notifyListeners();
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  // Confirm order received (marks as completed from buyer side)
  Future<bool> confirmReceived(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(' Order confirmed as received');
      return true;
    } catch (e) {
      _error = 'Failed to confirm order';
      notifyListeners();
      debugPrint('❌ Error confirming order: $e');
      return false;
    }
  }

  // Refresh orders
  Future<void> refresh() async {
    if (_buyerId == null) return;
    await initialize(_buyerId!);
  }

  // Format currency
  String formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Clear and reset
  void clear() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _buyerId = null;
    _allOrders = [];
    _activeOrders = [];
    _completedOrders = [];
    _cancelledOrders = [];
    _sellersCache.clear();
    _reviewedOrderIds.clear();
    _isLoading = false;
    _isSubmittingReview = false;
    _error = null;
    _selectedTabIndex = 0;
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
