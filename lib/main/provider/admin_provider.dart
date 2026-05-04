import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAdmin = false;
  bool _isCheckingAccess = false;
  String? _checkedUserId;

  int _selectedTab = 0;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  List<PostModel> _posts = [];
  List<UserModel> _users = [];
  List<Product> _items = [];
  List<Product> _services = [];
  List<UserModel> _sellerApplications = [];
  List<PickupCenterModel> _pickupApplications = [];

  bool get isAdmin => _isAdmin;
  bool get isCheckingAccess => _isCheckingAccess;
  String? get checkedUserId => _checkedUserId;

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  List<PostModel> get posts => _posts;
  List<UserModel> get users => _users;
  List<Product> get items => _items;
  List<Product> get services => _services;
  List<UserModel> get sellerApplications => _sellerApplications;
  List<PickupCenterModel> get pickupApplications => _pickupApplications;

  // Search results for user lookup
  List<UserModel> _searchResults = [];
  List<UserModel> get searchResults => _searchResults;
  List<PostModel> _searchPosts = [];
  List<PostModel> get searchPostsResults => _searchPosts;
  List<Product> _searchProducts = [];
  List<Product> get searchProducts => _searchProducts;
  List<PickupCenterModel> _searchPickupCenters = [];
  List<PickupCenterModel> get searchPickupCentersResults =>
      _searchPickupCenters;

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> checkAdminAccess(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _isAdmin = false;
      _checkedUserId = null;
      notifyListeners();
      return;
    }

    if (_checkedUserId == userId) return;

    _isCheckingAccess = true;
    _checkedUserId = userId;
    notifyListeners();

    try {
      final doc = await _firestore.collection('admin').doc(userId).get();
      if (doc.exists) {
        _isAdmin = true;
      } else {
        final fallback = await _firestore
            .collection('admin')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();
        _isAdmin = fallback.docs.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Admin access check error: $e');
      _isAdmin = false;
    } finally {
      _isCheckingAccess = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadPosts(),
        _loadUsers(),
        _loadItems(),
        _loadServices(),
        _loadSellerApplications(),
        _loadPickupApplications(),
      ]);
    } catch (e) {
      _error = 'Failed to load admin data';
      debugPrint('Load admin data error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentTab() async {
    _error = null;
    notifyListeners();

    try {
      switch (_selectedTab) {
        case 0:
          await _loadPosts();
          break;
        case 1:
          await _loadSellerApplications();
          break;
        case 2:
          await _loadUsers();
          break;
        case 3:
          await _loadItems();
          break;
        case 4:
          await _loadServices();
          break;
        case 5:
          await _loadPickupApplications();
          break;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh data';
      notifyListeners();
    }
  }

  Future<void> _loadPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    _posts = snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data()))
        .toList(growable: false);
  }

  Future<void> _loadItems() async {
    final snapshot = await _firestore
        .collection('marketplace')
        .where('isItem', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    _items = snapshot.docs
        .map((doc) => Product.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<void> _loadUsers() async {
    final snapshot = await _firestore.collection('users').limit(200).get();

    _users = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['uid'] == null || (data['uid'] as String).isEmpty) {
        data['uid'] = doc.id;
      }
      return UserModel.fromMap(data);
    }).toList(growable: false);
  }

  Future<void> _loadServices() async {
    final snapshot = await _firestore
        .collection('marketplace')
        .where('isItem', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    _services = snapshot.docs
        .map((doc) => Product.fromJson(doc.data()))
        .toList(growable: false);
  }

  Future<void> _loadSellerApplications() async {
    final snapshot = await _firestore
        .collection('users')
        .where('sellerStatus', isEqualTo: 'pending')
        .limit(200)
        .get();

    _sellerApplications = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['uid'] == null || (data['uid'] as String).isEmpty) {
        data['uid'] = doc.id;
      }
      return UserModel.fromMap(data);
    }).toList(growable: false);
  }

  Future<void> _loadPickupApplications() async {
    final snapshot = await _firestore
        .collection('pickup_centers')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    _pickupApplications = snapshot.docs
        .map((doc) => PickupCenterModel.fromMap(doc.data()))
        .toList(growable: false);
  }

  /// Search users by username (prefix match). Updates [searchResults].
  Future<void> searchUsers(String username) async {
    _error = null;
    _isLoading = true;
    _searchResults = [];
    notifyListeners();

    try {
      final q = _firestore
          .collection('users')
          .orderBy('username')
          .startAt([username]).endAt([username + '\uf8ff']).limit(50);

      final snapshot = await q.get();
      _searchResults = snapshot.docs.map((d) {
        final data = d.data();
        if (data['uid'] == null || (data['uid'] as String).isEmpty) {
          data['uid'] = d.id;
        }
        return UserModel.fromMap(data);
      }).toList(growable: false);
    } catch (e) {
      debugPrint('Search users error: $e');
      _error = 'Failed to search users';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPosts(String username) async {
    _error = null;
    _isLoading = true;
    _searchPosts = [];
    notifyListeners();

    try {
      final q = _firestore
          .collection('posts')
          .orderBy('username')
          .startAt([username]).endAt([username + '\uf8ff']).limit(100);

      final snapshot = await q.get();
      _searchPosts = snapshot.docs
          .map((d) => PostModel.fromMap(d.data()))
          .toList(growable: false);
    } catch (e) {
      debugPrint('Search posts error: $e');
      _error = 'Failed to search posts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchListings(String name, {required bool isItem}) async {
    _error = null;
    _isLoading = true;
    _searchProducts = [];
    notifyListeners();

    try {
      final q = _firestore
          .collection('marketplace')
          .orderBy('name')
          .startAt([name]).endAt([name + '\uf8ff']).limit(100);

      final snapshot = await q.get();
      final items = snapshot.docs
          .map((d) => Product.fromJson(d.data()))
          .where((p) => p.isItem == isItem)
          .toList(growable: false);

      _searchProducts = items;
    } catch (e) {
      debugPrint('Search listings error: $e');
      _error = 'Failed to search listings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPickupCenters(String name) async {
    _error = null;
    _isLoading = true;
    _searchPickupCenters = [];
    notifyListeners();

    try {
      final q = _firestore
          .collection('pickup_centers')
          .orderBy('name')
          .startAt([name]).endAt([name + '\uf8ff']).limit(100);

      final snapshot = await q.get();
      _searchPickupCenters = snapshot.docs
          .map((d) => PickupCenterModel.fromMap(d.data()))
          .toList(growable: false);
    } catch (e) {
      debugPrint('Search pickup centers error: $e');
      _error = 'Failed to search pickup centers';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Grants admin access to a user by creating an admin doc and updating user role.
  Future<bool> grantAdmin(String userId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final batch = _firestore.batch();
      final adminRef = _firestore.collection('admin').doc(userId);
      batch.set(adminRef, {
        'userId': userId,
        'grantedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'role': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // remove from search results if present
      _searchResults =
          _searchResults.where((u) => u.uid != userId).toList(growable: false);
      _users = _users
          .map((u) => u.uid == userId ? u.copyWith(role: 'admin') : u)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to grant admin access';
      debugPrint('Grant admin error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String postId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('posts').doc(postId).delete();
      _posts = _posts.where((p) => p.postId != postId).toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to delete post';
      debugPrint('Delete post error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteListing(String listingId, {required bool isItem}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('marketplace').doc(listingId).delete();
      if (isItem) {
        _items = _items.where((p) => p.id != listingId).toList(growable: false);
      } else {
        _services =
            _services.where((p) => p.id != listingId).toList(growable: false);
      }
      return true;
    } catch (e) {
      _error = 'Failed to delete listing';
      debugPrint('Delete listing error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveSellerApplication(String userId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(userId).update({
        'sellerStatus': 'approved',
        'role': 'seller',
        'sellerApplication.status': 'approved',
        'sellerApplication.reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _sellerApplications = _sellerApplications
          .where((u) => u.uid != userId)
          .toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to approve seller application';
      debugPrint('Approve seller error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectSellerApplication(String userId, {String? reason}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(userId).update({
        'sellerStatus': 'rejected',
        'sellerApplication.status': 'rejected',
        'sellerApplication.reviewedAt': FieldValue.serverTimestamp(),
        if (reason != null && reason.isNotEmpty)
          'sellerApplication.rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _sellerApplications = _sellerApplications
          .where((u) => u.uid != userId)
          .toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to reject seller application';
      debugPrint('Reject seller error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approvePickupApplication(String centerId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('pickup_centers').doc(centerId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _pickupApplications = _pickupApplications
          .where((c) => c.id != centerId)
          .toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to approve pickup application';
      debugPrint('Approve pickup error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchPosts = [];
    _searchProducts = [];
    _searchPickupCenters = [];
    notifyListeners();
  }

  Future<bool> suspendPickupCenter(String centerId) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('pickup_centers').doc(centerId).update({
        'status': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _pickupApplications = _pickupApplications
          .where((c) => c.id != centerId)
          .toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to suspend pickup center';
      debugPrint('Suspend pickup error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectPickupApplication(String centerId,
      {String? reason}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('pickup_centers').doc(centerId).update({
        'status': 'rejected',
        if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _pickupApplications = _pickupApplications
          .where((c) => c.id != centerId)
          .toList(growable: false);
      return true;
    } catch (e) {
      _error = 'Failed to reject pickup application';
      debugPrint('Reject pickup error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _users = _users
          .map((u) => u.uid == userId ? u.copyWith(role: role) : u)
          .toList(growable: false);
      _searchResults = _searchResults
          .map((u) => u.uid == userId ? u.copyWith(role: role) : u)
          .toList(growable: false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update user role';
      debugPrint('Update user role error: $e');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }
}
