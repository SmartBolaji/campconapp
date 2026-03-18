import 'package:campcon/main/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MarketplaceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user ID for prioritizing their products
  String? _currentUserId;

  int selectedTab = 0;
  String sortBy = 'Recent';
  String selectedCategory = 'All';

  // Loading states
  bool _isLoadingItems = false;
  bool _isLoadingServices = false;
  bool _isLoadingMoreItems = false;
  bool _isLoadingMoreServices = false;
  bool _hasLoadedItems = false;
  bool _hasLoadedServices = false;
  bool _hasMoreItems = true;
  bool _hasMoreServices = true;
  DocumentSnapshot? _lastItemDoc;
  DocumentSnapshot? _lastServiceDoc;
  String? _error;

  static const int _initialPageSize = 15;
  static const int _pageSize = 10;

  // Subscription
  StreamSubscription<QuerySnapshot>? _itemsSubscription;
  StreamSubscription<QuerySnapshot>? _servicesSubscription;

  // Sort options
  final List<String> sortOptions = [
    'Recent',
    'Price: Low to High',
    'Price: High to Low',
    'Closest to me',
    'Most Popular',
  ];

  // Item categories
  final List<String> itemCategories = [
    'All',
    'Electronics',
    'Books',
    'Clothing',
    'Furniture',
    'Sports',
    'Other',
  ];

  // Service categories
  final List<String> serviceCategories = [
    'All',
    'Tutoring',
    'Photography',
    'Design',
    'Writing',
    'Delivery',
    'Other',
  ];

  // Cache for products
  List<Product> _allProducts = [];
  List<Product> _allServices = [];

  // Getters
  bool get isLoading => selectedTab == 0 ? _isLoadingItems : _isLoadingServices;
  bool get isLoadingMore =>
      selectedTab == 0 ? _isLoadingMoreItems : _isLoadingMoreServices;
  bool get hasLoaded => selectedTab == 0 ? _hasLoadedItems : _hasLoadedServices;
  bool get hasMore => selectedTab == 0 ? _hasMoreItems : _hasMoreServices;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  List<Product> get currentList =>
      selectedTab == 0 ? _allProducts : _allServices;

  List<String> get currentCategories =>
      selectedTab == 0 ? itemCategories : serviceCategories;

  // Get current user's products from the current list
  List<Product> get myProducts {
    if (_currentUserId == null) return [];
    return currentList.where((p) => p.sellerId == _currentUserId).toList();
  }

  // Get other users' products from the current list
  List<Product> get otherProducts {
    if (_currentUserId == null) return currentList;
    return currentList.where((p) => p.sellerId != _currentUserId).toList();
  }

  // Check if current user has any products in current tab
  bool get hasMyProducts => myProducts.isNotEmpty;

  // Set current user ID (call this from UI on init)
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Get filtered and sorted list with user's products first
  List<Product> get filteredList {
    List<Product> list = List.from(currentList);

    // Filter by category
    if (selectedCategory != 'All') {
      list = list.where((p) => p.category == selectedCategory).toList();
    }

    // Sort
    switch (sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Recent':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Most Popular':
        list.sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));
        break;
      case 'Closest to me':
        // TODO: Implement location-based sorting
        break;
    }

    // Prioritize current user's products (move to front)
    if (_currentUserId != null) {
      final myItems = list.where((p) => p.sellerId == _currentUserId).toList();
      final otherItems =
          list.where((p) => p.sellerId != _currentUserId).toList();
      list = [...myItems, ...otherItems];
    }

    return list;
  }

  // Get filtered list separated into sections
  Map<String, List<Product>> get filteredListSectioned {
    List<Product> list = List.from(currentList);

    // Filter by category
    if (selectedCategory != 'All') {
      list = list.where((p) => p.category == selectedCategory).toList();
    }

    // Sort function
    int Function(Product, Product) sortFunction;
    switch (sortBy) {
      case 'Price: Low to High':
        sortFunction = (a, b) => a.price.compareTo(b.price);
        break;
      case 'Price: High to Low':
        sortFunction = (a, b) => b.price.compareTo(a.price);
        break;
      case 'Recent':
        sortFunction = (a, b) => b.createdAt.compareTo(a.createdAt);
        break;
      case 'Most Popular':
        sortFunction = (a, b) => (b.views ?? 0).compareTo(a.views ?? 0);
        break;
      default:
        sortFunction = (a, b) => b.createdAt.compareTo(a.createdAt);
    }

    if (_currentUserId != null) {
      final myItems = list.where((p) => p.sellerId == _currentUserId).toList()
        ..sort(sortFunction);
      final otherItems = list
          .where((p) => p.sellerId != _currentUserId)
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

  // Load items once (called on first tab visit)
  Future<void> loadMarketplaceItems() async {
    if (_hasLoadedItems || _isLoadingItems) return;

    _isLoadingItems = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _itemsSubscription?.cancel();

      // Get initial data
      final snapshot = await _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(_initialPageSize)
          .get();

        _lastItemDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMoreItems = snapshot.docs.length >= _initialPageSize;

      _allProducts = snapshot.docs
          .map((doc) {
            try {
              return Product.fromJson(doc.data());
            } catch (e) {
              debugPrint('Error parsing product: $e');
              return null;
            }
          })
          .whereType<Product>()
          .toList();

      _hasLoadedItems = true;
      _isLoadingItems = false;
      notifyListeners();

      // Listen for new additions only (don't re-fetch everything)
      _itemsSubscription = _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        // Only add if there's a new document
        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              try {
                final product = Product.fromJson(change.doc.data()!);
                // Only add if not already in list
                if (!_allProducts.any((p) => p.id == product.id)) {
                  _allProducts.insert(0, product);
                  notifyListeners();
                }
              } catch (e) {
                debugPrint('Error adding new product: $e');
              }
            }
          }
        }
      });

      debugPrint(' Loaded ${_allProducts.length} items');
    } catch (e) {
      _isLoadingItems = false;
      _error = 'Failed to load items';
      notifyListeners();
      debugPrint('❌ Error loading items: $e');
    }
  }

  // Load services once (called on first tab visit)
  Future<void> loadMarketplaceServices() async {
    if (_hasLoadedServices || _isLoadingServices) return;

    _isLoadingServices = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _servicesSubscription?.cancel();

      // Get initial data
      final snapshot = await _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(_initialPageSize)
          .get();

        _lastServiceDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMoreServices = snapshot.docs.length >= _initialPageSize;

      _allServices = snapshot.docs
          .map((doc) {
            try {
              return Product.fromJson(doc.data());
            } catch (e) {
              debugPrint('Error parsing service: $e');
              return null;
            }
          })
          .whereType<Product>()
          .toList();

      _hasLoadedServices = true;
      _isLoadingServices = false;
      notifyListeners();

      // Listen for new additions only
      _servicesSubscription = _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docChanges.isNotEmpty) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              try {
                final service = Product.fromJson(change.doc.data()!);
                if (!_allServices.any((s) => s.id == service.id)) {
                  _allServices.insert(0, service);
                  notifyListeners();
                }
              } catch (e) {
                debugPrint('Error adding new service: $e');
              }
            }
          }
        }
      });

      debugPrint(' Loaded ${_allServices.length} services');
    } catch (e) {
      _isLoadingServices = false;
      _error = 'Failed to load services';
      notifyListeners();
      debugPrint('❌ Error loading services: $e');
    }
  }

  // Load data for current tab (called from UI)
  Future<void> loadCurrentTab() async {
    if (selectedTab == 0) {
      await loadMarketplaceItems();
    } else {
      await loadMarketplaceServices();
    }
  }

  void changeTab(int index) {
    selectedTab = index;
    selectedCategory = 'All';
    notifyListeners();

    // Load data for new tab if not loaded yet
    loadCurrentTab();
  }

  void changeSortBy(String newSortBy) {
    sortBy = newSortBy;
    notifyListeners();
  }

  void changeCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addProduct(Product product) {
    if (product.isItem) {
      // Remove if exists (to avoid duplicates)
      _allProducts.removeWhere((p) => p.id == product.id);
      _allProducts.insert(0, product);
    } else {
      _allServices.removeWhere((s) => s.id == product.id);
      _allServices.insert(0, product);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _allProducts.removeWhere((p) => p.id == productId);
    _allServices.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Refresh data (for pull-to-refresh)
  Future<void> refreshCurrentTab() async {
    if (selectedTab == 0) {
      _hasLoadedItems = false;
      _hasMoreItems = true;
      _lastItemDoc = null;
      _allProducts.clear();
      await loadMarketplaceItems();
    } else {
      _hasLoadedServices = false;
      _hasMoreServices = true;
      _lastServiceDoc = null;
      _allServices.clear();
      await loadMarketplaceServices();
    }
  }

  Future<void> loadMoreCurrentTab() async {
    if (selectedTab == 0) {
      await loadMoreItems();
    } else {
      await loadMoreServices();
    }
  }

  Future<void> loadMoreItems() async {
    if (_isLoadingItems || _isLoadingMoreItems || !_hasMoreItems) return;

    _isLoadingMoreItems = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastItemDoc != null) {
        query = query.startAfterDocument(_lastItemDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreItems = false;
      } else {
        _lastItemDoc = snapshot.docs.last;
        final newItems = snapshot.docs
            .map((doc) {
              try {
                return Product.fromJson(doc.data() as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing product: $e');
                return null;
              }
            })
            .whereType<Product>()
            .where((item) => !_allProducts.any((p) => p.id == item.id))
            .toList();

        _allProducts.addAll(newItems);
        _hasMoreItems = snapshot.docs.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error loading more items: $e');
    }

    _isLoadingMoreItems = false;
    notifyListeners();
  }

  Future<void> loadMoreServices() async {
    if (_isLoadingServices || _isLoadingMoreServices || !_hasMoreServices) {
      return;
    }

    _isLoadingMoreServices = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastServiceDoc != null) {
        query = query.startAfterDocument(_lastServiceDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreServices = false;
      } else {
        _lastServiceDoc = snapshot.docs.last;
        final newServices = snapshot.docs
            .map((doc) {
              try {
                return Product.fromJson(doc.data() as Map<String, dynamic>);
              } catch (e) {
                debugPrint('Error parsing service: $e');
                return null;
              }
            })
            .whereType<Product>()
            .where((item) => !_allServices.any((s) => s.id == item.id))
            .toList();

        _allServices.addAll(newServices);
        _hasMoreServices = snapshot.docs.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error loading more services: $e');
    }

    _isLoadingMoreServices = false;
    notifyListeners();
  }

  // Clear cache
  void clearCache() {
    _allProducts.clear();
    _allServices.clear();
    _hasLoadedItems = false;
    _hasLoadedServices = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _servicesSubscription?.cancel();
    super.dispose();
  }
}
