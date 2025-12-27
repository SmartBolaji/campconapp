// lib/main/provider/notify_provider.dart
import 'package:campcon/main/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NotifyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  int _unreadCount = 0;

  // Tab state (replacing sort and filter)
  int _selectedTab = 0;

  // ✅ COMMENTED OUT - Sort and filter state
  // String _sortBy = 'Recent';
  // String _selectedFilter = 'All';

  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  // ✅ COMMENTED OUT - Sort options
  // final List<String> sortOptions = [
  //   'Recent',
  //   'Oldest First',
  //   'Unread First',
  // ];

  // ✅ COMMENTED OUT - Filter options (based on notification types)
  // final List<String> filterOptions = [
  //   'All',
  //   'Likes',
  //   'Comments',
  //   'Follows',
  //   'Marketplace',
  //   'Events',
  //   'Mentions',
  //   'Shares',
  // ];

  // Tab labels
  final List<String> tabLabels = [
    'All',
    'Likes',
    'Comments',
    'Follows',
    'Marketplace',
    'Events',
    'Mentions',
    'Shares',
  ];

  // Getters
  List<NotificationModel> get notifications => _filteredNotifications;
  List<NotificationModel> get allNotifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  int get selectedTab => _selectedTab;
  String get currentTabLabel => tabLabels[_selectedTab];

  // ✅ COMMENTED OUT - Old getters
  // String get sortBy => _sortBy;
  // String get selectedFilter => _selectedFilter;

  // Get filtered notifications based on selected tab
  List<NotificationModel> get _filteredNotifications {
    List<NotificationModel> filtered = List.from(_notifications);

    // Apply filter based on tab
    switch (_selectedTab) {
      case 0: // All
        break;
      case 1: // Likes
        filtered =
            filtered.where((n) => n.type == NotificationType.like).toList();
        break;
      case 2: // Comments
        filtered = filtered
            .where((n) =>
                n.type == NotificationType.comment ||
                n.type == NotificationType.reply)
            .toList();
        break;
      case 3: // Follows
        filtered =
            filtered.where((n) => n.type == NotificationType.follow).toList();
        break;
      case 4: // Marketplace
        filtered = filtered
            .where((n) =>
                n.type == NotificationType.marketplacePurchase ||
                n.type == NotificationType.marketplaceInterest)
            .toList();
        break;
      case 5: // Events
        filtered = filtered
            .where((n) =>
                n.type == NotificationType.eventInterested ||
                n.type == NotificationType.eventAttending)
            .toList();
        break;
      case 6: // Mentions
        filtered =
            filtered.where((n) => n.type == NotificationType.mention).toList();
        break;
      case 7: // Shares
        filtered =
            filtered.where((n) => n.type == NotificationType.share).toList();
        break;
    }

    // Always sort by recent (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // ✅ COMMENTED OUT - Old filtered and sorted getter
  // List<NotificationModel> get _filteredAndSortedNotifications {
  //   List<NotificationModel> filtered = List.from(_notifications);
  //
  //   // Apply filter
  //   if (_selectedFilter != 'All') {
  //     filtered = filtered.where((notification) {
  //       switch (_selectedFilter) {
  //         case 'Likes':
  //           return notification.type == NotificationType.like;
  //         case 'Comments':
  //           return notification.type == NotificationType.comment ||
  //               notification.type == NotificationType.reply;
  //         case 'Follows':
  //           return notification.type == NotificationType.follow;
  //         case 'Marketplace':
  //           return notification.type == NotificationType.marketplacePurchase ||
  //               notification.type == NotificationType.marketplaceInterest;
  //         case 'Events':
  //           return notification.type == NotificationType.eventInterested ||
  //               notification.type == NotificationType.eventAttending;
  //         case 'Mentions':
  //           return notification.type == NotificationType.mention;
  //         case 'Shares':
  //           return notification.type == NotificationType.share;
  //         default:
  //           return true;
  //       }
  //     }).toList();
  //   }
  //
  //   // Apply sort
  //   switch (_sortBy) {
  //     case 'Recent':
  //       filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //       break;
  //     case 'Oldest First':
  //       filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //       break;
  //     case 'Unread First':
  //       filtered.sort((a, b) {
  //         if (a.isRead == b.isRead) {
  //           return b.createdAt.compareTo(a.createdAt);
  //         }
  //         return a.isRead ? 1 : -1;
  //       });
  //       break;
  //   }
  //
  //   return filtered;
  // }

  // Change tab
  void changeTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  // ✅ COMMENTED OUT - Old change methods
  // void changeSortBy(String newSortBy) {
  //   _sortBy = newSortBy;
  //   notifyListeners();
  // }
  //
  // void changeFilter(String filter) {
  //   _selectedFilter = filter;
  //   notifyListeners();
  // }

  // Load notifications for a user
  Future<void> loadNotifications(String userId) async {
    if (_hasLoaded || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel existing subscription
      await _notificationSubscription?.cancel();

      // Get initial data
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();

      _updateUnreadCount();
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();

      // Listen for real-time updates
      _notificationSubscription = _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .listen((snapshot) {
        _notifications = snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
        _updateUnreadCount();
        notifyListeners();
      });

      debugPrint('✅ Loaded ${_notifications.length} notifications');
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load notifications';
      notifyListeners();
      debugPrint('❌ Error loading notifications: $e');
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications(String userId) async {
    _hasLoaded = false;
    await loadNotifications(userId);
  }

  // Create a notification
  Future<void> createNotification({
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required NotificationType type,
    required String title,
    required String body,
    String? targetId,
    String? targetType,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Don't create notification for self-actions
    if (recipientId == actorId) {
      debugPrint('⚠️ Skipping self-notification');
      return;
    }

    try {
      final notification = NotificationModel(
        id: '', // Will be generated by Firestore
        recipientId: recipientId,
        actorId: actorId,
        actorName: actorName,
        actorProfileImage: actorProfileImage,
        type: type,
        title: title,
        body: body,
        targetId: targetId,
        targetType: targetType,
        imageUrl: imageUrl,
        metadata: metadata,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());

      debugPrint('✅ Created notification: $type for $recipientId');
    } catch (e) {
      debugPrint('❌ Error creating notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }

      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);

      for (var notification in unreadNotifications) {
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'isRead': true},
        );
      }

      await batch.commit();

      // Update local state
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _updateUnreadCount();
      notifyListeners();

      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();

      debugPrint('✅ Deleted notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final userNotifications = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .get();

      for (var doc in userNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Update local state
      _notifications.clear();
      _updateUnreadCount();
      notifyListeners();

      debugPrint('✅ Cleared all notifications');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Clear cache
  void clearCache() {
    _notifications.clear();
    _hasLoaded = false;
    _unreadCount = 0;
    _selectedTab = 0;
    // ✅ COMMENTED OUT - Old state reset
    // _sortBy = 'Recent';
    // _selectedFilter = 'All';
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
