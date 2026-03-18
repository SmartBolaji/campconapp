import 'dart:async';
import 'package:campcon/main/models/order_model.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SalesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current seller ID
  String? _sellerId;

  // Orders lists
  List<OrderModel> _allOrders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _completedOrders = [];
  List<OrderModel> _cancelledOrders = [];

  // Buyer data cache
  final Map<String, UserModel> _buyersCache = {};

  // Stats
  double _totalRevenue = 0;
  double _todayRevenue = 0;
  int _totalSales = 0;
  int _pendingCount = 0;

  // Product filter
  String? _filterProductId;
  String? _filterProductName;

  // Seller listings
  List<Product> _sellerListings = [];
  bool _isLoadingListings = false;

  // Earnings data
  Map<String, double> _revenueByProduct = {};
  List<MapEntry<String, double>> _topProducts = [];
  Map<String, double> _weeklyRevenue = {};
  Map<String, double> _monthlyRevenue = {};

  // State
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  int _selectedTabIndex = 0;

  // Stream subscription
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  // Getters
  List<OrderModel> get allOrders => _allOrders;
  List<OrderModel> get pendingOrders => _filterOrders(_pendingOrders);
  List<OrderModel> get activeOrders => _filterOrders(_activeOrders);
  List<OrderModel> get completedOrders => _filterOrders(_completedOrders);
  List<OrderModel> get cancelledOrders => _filterOrders(_cancelledOrders);

  double get totalRevenue => _totalRevenue;
  double get todayRevenue => _todayRevenue;
  int get totalSales => _totalSales;
  int get pendingCount => _pendingCount;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;

  Map<String, UserModel> get buyersCache => _buyersCache;

  // Product filter getters
  String? get filterProductId => _filterProductId;
  String? get filterProductName => _filterProductName;
  bool get hasProductFilter => _filterProductId != null;

  // Seller listings getters
  List<Product> get sellerListings => _sellerListings;
  bool get isLoadingListings => _isLoadingListings;

  // Earnings getters
  Map<String, double> get revenueByProduct => _revenueByProduct;
  List<MapEntry<String, double>> get topProducts => _topProducts;
  Map<String, double> get weeklyRevenue => _weeklyRevenue;
  Map<String, double> get monthlyRevenue => _monthlyRevenue;

  // Filter orders by productId if filter is active
  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_filterProductId == null) return orders;
    return orders.where((o) => o.productId == _filterProductId).toList();
  }

  // Get orders for current tab
  List<OrderModel> get currentTabOrders {
    switch (_selectedTabIndex) {
      case 0:
        return _pendingOrders;
      case 1:
        return _activeOrders;
      case 2:
        return _completedOrders;
      case 3:
        return _cancelledOrders;
      default:
        return _allOrders;
    }
  }

  // Initialize with seller ID
  Future<void> initialize(String sellerId) async {
    if (_sellerId == sellerId && _ordersSubscription != null) return;

    _sellerId = sellerId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Cancel existing subscription
    await _ordersSubscription?.cancel();

    // Start listening to orders
    _ordersSubscription = _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
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
  }

  void _processOrders(List<QueryDocumentSnapshot> docs) {
    _allOrders = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromMap(data);
    }).toList();

    // Categorize orders
    _pendingOrders = _allOrders.where((o) => o.isPending).toList();
    _activeOrders = _allOrders
        .where((o) => o.isConfirmed || o.isProcessing || o.isReady)
        .toList();
    _completedOrders = _allOrders.where((o) => o.isCompleted).toList();
    _cancelledOrders = _allOrders.where((o) => o.isCancelled).toList();

    // Calculate stats
    _calculateStats();

    // Load buyer data for pending and active orders
    _loadBuyersData();

    _isLoading = false;
    notifyListeners();
  }

  void _calculateStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    _totalRevenue =
        _completedOrders.fold(0, (sum, order) => sum + order.totalPrice);
    _todayRevenue = _completedOrders
        .where(
            (o) => o.completedAt != null && o.completedAt!.isAfter(todayStart))
        .fold(0, (sum, order) => sum + order.totalPrice);
    _totalSales = _completedOrders.length;
    _pendingCount = _pendingOrders.length;
  }

  Future<void> _loadBuyersData() async {
    // Get unique buyer IDs from pending and active orders
    final buyerIds = <String>{};
    for (var order in [..._pendingOrders, ..._activeOrders]) {
      if (!_buyersCache.containsKey(order.buyerId)) {
        buyerIds.add(order.buyerId);
      }
    }

    // Fetch buyer data
    for (var buyerId in buyerIds) {
      try {
        final doc = await _firestore.collection('users').doc(buyerId).get();
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
          _buyersCache[buyerId] = UserModel.fromJson(data);
        }
      } catch (e) {
        debugPrint('❌ Error loading buyer data for $buyerId: $e');
      }
    }
    notifyListeners();
  }

  // Set selected tab
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp for specific statuses
      switch (newStatus) {
        case OrderStatus.confirmed:
          updates['confirmedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.completed:
          updates['completedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.cancelled:
          updates['cancelledAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);

      _isUpdating = false;
      notifyListeners();
      debugPrint(' Order status updated to ${newStatus.name}');
      return true;
    } catch (e) {
      _isUpdating = false;
      _error = 'Failed to update order status';
      notifyListeners();
      debugPrint('❌ Error updating order status: $e');
      return false;
    }
  }

  // Confirm order
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  // Start processing order
  Future<bool> startProcessing(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.processing);
  }

  // Mark order as ready
  Future<bool> markAsReady(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.ready);
  }

  // Complete order
  Future<bool> completeOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.completed);
  }

  // Cancel order with reason
  Future<bool> cancelOrder(String orderId, String reason) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isUpdating = false;
      notifyListeners();
      debugPrint(' Order cancelled');
      return true;
    } catch (e) {
      _isUpdating = false;
      _error = 'Failed to cancel order';
      notifyListeners();
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  // Get buyer info
  UserModel? getBuyer(String buyerId) {
    return _buyersCache[buyerId];
  }

  // Refresh orders
  Future<void> refresh() async {
    if (_sellerId == null) return;
    await initialize(_sellerId!);
  }

  // Format currency
  String formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Clear and reset
  void clear() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _sellerId = null;
    _allOrders = [];
    _pendingOrders = [];
    _activeOrders = [];
    _completedOrders = [];
    _cancelledOrders = [];
    _buyersCache.clear();
    _totalRevenue = 0;
    _todayRevenue = 0;
    _totalSales = 0;
    _pendingCount = 0;
    _filterProductId = null;
    _filterProductName = null;
    _sellerListings = [];
    _revenueByProduct = {};
    _topProducts = [];
    _weeklyRevenue = {};
    _monthlyRevenue = {};
    _isLoading = false;
    _isUpdating = false;
    _error = null;
    _selectedTabIndex = 0;
  }

  // ── Product Filter ──────────────────────────────────────────────

  void setProductFilter(String productId, String productName) {
    _filterProductId = productId;
    _filterProductName = productName;
    notifyListeners();
  }

  void clearProductFilter() {
    _filterProductId = null;
    _filterProductName = null;
    notifyListeners();
  }

  // ── Seller Listings ─────────────────────────────────────────────

  Future<void> fetchSellerListings() async {
    if (_sellerId == null) return;

    _isLoadingListings = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('marketplace')
          .where('sellerId', isEqualTo: _sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _sellerListings = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();

      _isLoadingListings = false;
      notifyListeners();
    } catch (e) {
      _isLoadingListings = false;
      notifyListeners();
      debugPrint('❌ Error fetching seller listings: $e');
    }
  }

  Future<void> toggleListingActive(String productId, bool isActive) async {
    try {
      await _firestore
          .collection('marketplace')
          .doc(productId)
          .update({'isActive': isActive});
      // Refresh listings
      await fetchSellerListings();
    } catch (e) {
      debugPrint('❌ Error toggling listing: $e');
    }
  }

  Future<bool> deleteListing(String productId) async {
    try {
      await _firestore.collection('marketplace').doc(productId).delete();
      _sellerListings.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting listing: $e');
      return false;
    }
  }

  // ── Earnings Breakdown ──────────────────────────────────────────

  void calculateEarningsBreakdown() {
    // Revenue by product
    _revenueByProduct = {};
    for (var order in _completedOrders) {
      _revenueByProduct[order.productName] =
          (_revenueByProduct[order.productName] ?? 0) + order.totalPrice;
    }

    // Top products sorted by revenue
    _topProducts = _revenueByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Weekly revenue (last 7 days)
    _weeklyRevenue = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayKey = '${_weekdayShort(day.weekday)} ${day.day}';
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      _weeklyRevenue[dayKey] = _completedOrders
          .where((o) =>
              o.completedAt != null &&
              o.completedAt!.isAfter(dayStart) &&
              o.completedAt!.isBefore(dayEnd))
          .fold(0, (sum, o) => sum + o.totalPrice);
    }

    // Monthly revenue (last 6 months)
    _monthlyRevenue = {};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = _monthShort(month.month);
      final nextMonth = DateTime(month.year, month.month + 1, 1);

      _monthlyRevenue[monthKey] = _completedOrders
          .where((o) =>
              o.completedAt != null &&
              o.completedAt!.isAfter(month) &&
              o.completedAt!.isBefore(nextMonth))
          .fold(0, (sum, o) => sum + o.totalPrice);
    }

    notifyListeners();
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[((month - 1) % 12)];
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
