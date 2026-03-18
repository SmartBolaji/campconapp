import 'dart:async';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchContext {
  home,
  messaging,
  resources,
  notifications,
  market,
}

enum SearchStatus {
  idle,
  searching,
  success,
  empty,
  error,
}

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current search context
  SearchContext _context = SearchContext.home;

  // Search state
  SearchStatus _status = SearchStatus.idle;
  String _query = '';
  String? _errorMessage;
  Timer? _debounceTimer;

  // Current user ID
  String? _currentUserId;

  // Results by type
  List<PostModel> _posts = [];
  List<UserModel> _users = [];
  List<Product> _products = [];
  List<ResourceModel> _resources = [];
  List<NotificationModel> _notifications = [];
  List<Map<String, dynamic>> _conversations = [];

  // Recent searches (stored per context)
  Map<SearchContext, List<String>> _recentSearches = {};

  // Trending/suggested searches
  List<String> _trendingSearches = [];

  // Filter state for market
  String _marketCategory = 'All';
  String _marketSort = 'Recent';
  bool _showProducts = true;
  bool _showServices = true;

  // Filter state for resources
  String? _resourceFaculty;
  String? _resourceDepartment;
  String _resourceType = 'All';

  // Getters
  SearchContext get context => _context;
  SearchStatus get status => _status;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  List<PostModel> get posts => _posts;
  List<UserModel> get users => _users;
  List<Product> get products => _products;
  List<ResourceModel> get resources => _resources;
  List<NotificationModel> get notifications => _notifications;
  List<Map<String, dynamic>> get conversations => _conversations;

  List<String> get recentSearches => _recentSearches[_context] ?? [];
  List<String> get trendingSearches => _trendingSearches;

  String get marketCategory => _marketCategory;
  String get marketSort => _marketSort;
  bool get showProducts => _showProducts;
  bool get showServices => _showServices;

  String? get resourceFaculty => _resourceFaculty;
  String? get resourceDepartment => _resourceDepartment;
  String get resourceType => _resourceType;

  bool get hasResults {
    switch (_context) {
      case SearchContext.home:
        return _posts.isNotEmpty || _users.isNotEmpty;
      case SearchContext.messaging:
        return _conversations.isNotEmpty || _users.isNotEmpty;
      case SearchContext.resources:
        return _resources.isNotEmpty;
      case SearchContext.notifications:
        return _notifications.isNotEmpty;
      case SearchContext.market:
        return _products.isNotEmpty;
    }
  }

  bool get isSearching => _status == SearchStatus.searching;

  // Context-specific hint text
  String get hintText {
    switch (_context) {
      case SearchContext.home:
        return 'Search posts, people...';
      case SearchContext.messaging:
        return 'Search messages, people...';
      case SearchContext.resources:
        return 'Search resources, courses...';
      case SearchContext.notifications:
        return 'Search notifications...';
      case SearchContext.market:
        return 'Search products, services...';
    }
  }

  // Context-specific title
  String get title {
    switch (_context) {
      case SearchContext.home:
        return 'Search';
      case SearchContext.messaging:
        return 'Search Messages';
      case SearchContext.resources:
        return 'Search Resources';
      case SearchContext.notifications:
        return 'Search Notifications';
      case SearchContext.market:
        return 'Search Marketplace';
    }
  }

  // Initialize with context
  void initialize(SearchContext context, {String? userId}) {
    _context = context;
    _currentUserId = userId;
    _query = '';
    _status = SearchStatus.idle;
    _clearResults();
    _loadRecentSearches();
    _loadTrendingSearches();
    notifyListeners();
  }

  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  // Update query with debounce
  void updateQuery(String query) {
    _query = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _status = SearchStatus.idle;
      _clearResults();
      notifyListeners();
      return;
    }

    _status = SearchStatus.searching;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  // Clear query
  void clearQuery() {
    _query = '';
    _status = SearchStatus.idle;
    _clearResults();
    notifyListeners();
  }

  // Perform search based on context
  Future<void> _performSearch() async {
    if (_query.isEmpty) return;

    try {
      _status = SearchStatus.searching;
      notifyListeners();

      switch (_context) {
        case SearchContext.home:
          await _searchHome();
          break;
        case SearchContext.messaging:
          await _searchMessaging();
          break;
        case SearchContext.resources:
          await _searchResources();
          break;
        case SearchContext.notifications:
          await _searchNotifications();
          break;
        case SearchContext.market:
          await _searchMarket();
          break;
      }

      _status = hasResults ? SearchStatus.success : SearchStatus.empty;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString();
      debugPrint('Search error: $e');
    }

    notifyListeners();
  }

  // Search home (posts + users)
  Future<void> _searchHome() async {
    final queryLower = _query.toLowerCase();

    // Search posts
    final postsQuery = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .get();

    _posts = postsQuery.docs
        .map((doc) => PostModel.fromMap(doc.data()))
        .where((post) =>
            post.content.toLowerCase().contains(queryLower) ||
            post.username.toLowerCase().contains(queryLower) ||
            post.tags.any((tag) => tag.toLowerCase().contains(queryLower)))
        .toList();

    // Search users
    await _searchUsers();
  }

  // Search messaging (conversations + users)
  Future<void> _searchMessaging() async {
    if (_currentUserId == null) return;

    final queryLower = _query.toLowerCase();

    // Get user's conversations
    final chatsQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .get();

    List<Map<String, dynamic>> results = [];

    for (var doc in chatsQuery.docs) {
      var data = doc.data();
      var participants = List<String>.from(data['participants'] ?? []);
      String otherUserId = participants.firstWhere(
        (id) => id != _currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty) {
        // Get other user's data
        var userDoc =
            await _firestore.collection('users').doc(otherUserId).get();
        if (userDoc.exists) {
          var userData = userDoc.data()!;
          String name = userData['name'] ?? userData['username'] ?? '';
          String lastMessage = data['lastMessage'] ?? '';

          // Filter by query
          if (name.toLowerCase().contains(queryLower) ||
              lastMessage.toLowerCase().contains(queryLower)) {
            results.add({
              'chatId': doc.id,
              'otherUserId': otherUserId,
              'userData': userData,
              'lastMessage': lastMessage,
              'lastMessageTime': data['lastMessageTime'],
              'unreadCount': data['unreadCount_$_currentUserId'] ?? 0,
            });
          }
        }
      }
    }

    _conversations = results;

    // Also search users for new conversations
    await _searchUsers();
  }

  // Search resources
  Future<void> _searchResources() async {
    final queryLower = _query.toLowerCase();

    Query<Map<String, dynamic>> query = _firestore.collection('resources');

    // Apply filters
    if (_resourceFaculty != null) {
      query = query.where('faculty', isEqualTo: _resourceFaculty);
    }
    if (_resourceDepartment != null) {
      query = query.where('department', isEqualTo: _resourceDepartment);
    }
    if (_resourceType != 'All') {
      query = query.where('resourceType', isEqualTo: _resourceType);
    }

    final snapshot =
        await query.orderBy('createdAt', descending: true).limit(50).get();

    _resources = snapshot.docs
        .map((doc) => ResourceModel.fromJson({...doc.data(), 'id': doc.id}))
        .where((resource) =>
            resource.title.toLowerCase().contains(queryLower) ||
            resource.description.toLowerCase().contains(queryLower) ||
            (resource.course?.toLowerCase().contains(queryLower) ?? false))
        .toList();
  }

  // Search notifications
  Future<void> _searchNotifications() async {
    if (_currentUserId == null) return;

    final queryLower = _query.toLowerCase();

    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    _notifications = snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
        .where((notif) =>
            notif.title.toLowerCase().contains(queryLower) ||
            notif.body.toLowerCase().contains(queryLower))
        .toList();
  }

  // Search market (products + services)
  Future<void> _searchMarket() async {
    final queryLower = _query.toLowerCase();

    List<Product> allProducts = [];

    // Search products if enabled
    if (_showProducts) {
      Query<Map<String, dynamic>> productsQuery =
          _firestore.collection('marketplace').where('isItem', isEqualTo: true);

      if (_marketCategory != 'All') {
        productsQuery =
            productsQuery.where('category', isEqualTo: _marketCategory);
      }

      final productsSnapshot = await productsQuery.limit(30).get();
      allProducts.addAll(productsSnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id})));
    }

    // Search services if enabled
    if (_showServices) {
      Query<Map<String, dynamic>> servicesQuery = _firestore
          .collection('marketplace')
          .where('isItem', isEqualTo: false);

      if (_marketCategory != 'All') {
        servicesQuery =
            servicesQuery.where('category', isEqualTo: _marketCategory);
      }

      final servicesSnapshot = await servicesQuery.limit(30).get();
      allProducts.addAll(servicesSnapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id})));
    }

    // Filter by query
    _products = allProducts
        .where((product) =>
            product.name.toLowerCase().contains(queryLower) ||
            product.description.toLowerCase().contains(queryLower) ||
            product.category.toLowerCase().contains(queryLower))
        .toList();

    // Sort
    _sortProducts();
  }

  // Search users helper
  Future<void> _searchUsers() async {
    final queryLower = _query.toLowerCase();

    final usersSnapshot = await _firestore.collection('users').limit(20).get();

    _users = usersSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) =>
            user.username.toLowerCase().contains(queryLower) ||
            (user.name?.toLowerCase().contains(queryLower) ?? false) ||
            (user.campus?.toLowerCase().contains(queryLower) ?? false))
        .take(10)
        .toList();
  }

  // Sort products
  void _sortProducts() {
    switch (_marketSort) {
      case 'Price: Low to High':
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        _products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Most Popular':
        _products.sort((a, b) => (b.views ?? 0).compareTo(a.views ?? 0));
        break;
      case 'Recent':
      default:
        _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // Market filters
  void setMarketCategory(String category) {
    _marketCategory = category;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  void setMarketSort(String sort) {
    _marketSort = sort;
    _sortProducts();
    notifyListeners();
  }

  void toggleProducts(bool show) {
    _showProducts = show;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  void toggleServices(bool show) {
    _showServices = show;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  // Resource filters
  void setResourceFaculty(String? faculty) {
    _resourceFaculty = faculty;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  void setResourceDepartment(String? department) {
    _resourceDepartment = department;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  void setResourceType(String type) {
    _resourceType = type;
    if (_query.isNotEmpty) _performSearch();
    notifyListeners();
  }

  // Recent searches
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recent_searches_${_context.name}';
      final stored = prefs.getStringList(key) ?? [];
      _recentSearches[_context] = stored;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  Future<void> addToRecentSearches(String query) async {
    if (query.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recent_searches_${_context.name}';

      List<String> searches = _recentSearches[_context] ?? [];
      searches.remove(query); // Remove if exists
      searches.insert(0, query); // Add to front
      if (searches.length > 10)
        searches = searches.sublist(0, 10); // Limit to 10

      await prefs.setStringList(key, searches);
      _recentSearches[_context] = searches;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  Future<void> removeFromRecentSearches(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recent_searches_${_context.name}';

      List<String> searches = _recentSearches[_context] ?? [];
      searches.remove(query);

      await prefs.setStringList(key, searches);
      _recentSearches[_context] = searches;
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recent_searches_${_context.name}';
      await prefs.remove(key);
      _recentSearches[_context] = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  // Load trending searches
  Future<void> _loadTrendingSearches() async {
    // For now, use static trending. Can be fetched from Firebase later
    switch (_context) {
      case SearchContext.home:
        _trendingSearches = ['Campus news', 'Study tips', 'Events', 'Housing'];
        break;
      case SearchContext.messaging:
        _trendingSearches = [];
        break;
      case SearchContext.resources:
        _trendingSearches = [
          'Past questions',
          'Lecture notes',
          'Textbooks',
          'Tutorials'
        ];
        break;
      case SearchContext.notifications:
        _trendingSearches = [];
        break;
      case SearchContext.market:
        _trendingSearches = ['Laptop', 'Textbooks', 'Tutoring', 'Phone'];
        break;
    }
    notifyListeners();
  }

  // Clear results
  void _clearResults() {
    _posts = [];
    _users = [];
    _products = [];
    _resources = [];
    _notifications = [];
    _conversations = [];
  }

  // Reset all filters
  void resetFilters() {
    _marketCategory = 'All';
    _marketSort = 'Recent';
    _showProducts = true;
    _showServices = true;
    _resourceFaculty = null;
    _resourceDepartment = null;
    _resourceType = 'All';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
