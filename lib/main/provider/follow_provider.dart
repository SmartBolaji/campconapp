import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache follow states to prevent excessive reads
  final Map<String, bool> _followStates = {};
  final Map<String, int> _followersCounts = {};
  final Map<String, int> _followingCounts = {};

  // Get follow state (cached)
  bool isFollowing(String currentUserId, String targetUserId) {
    final key = '${currentUserId}_$targetUserId';
    return _followStates[key] ?? false;
  }

  // Get cached counts
  int getFollowersCount(String userId) => _followersCounts[userId] ?? 0;
  int getFollowingCount(String userId) => _followingCounts[userId] ?? 0;

  /// Check if current user is following target user
  Future<bool> checkIfFollowing(
      String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();

      final isFollowing = doc.exists;
      final key = '${currentUserId}_$targetUserId';
      _followStates[key] = isFollowing;

      return isFollowing;
    } catch (e) {
      debugPrint('❌ Error checking follow status: $e');
      return false;
    }
  }

  /// Get follower/following counts for a user
  Future<Map<String, int>> getFollowCounts(String userId) async {
    try {
      final counts = await Future.wait([
        _firestore
            .collection('users')
            .doc(userId)
            .collection('followers')
            .count()
            .get(),
        _firestore
            .collection('users')
            .doc(userId)
            .collection('following')
            .count()
            .get(),
      ]);

      final followersCount = counts[0].count ?? 0;
      final followingCount = counts[1].count ?? 0;

      // Cache counts
      _followersCounts[userId] = followersCount;
      _followingCounts[userId] = followingCount;

      return {
        'followers': followersCount,
        'following': followingCount,
      };
    } catch (e) {
      debugPrint('❌ Error getting follow counts: $e');
      return {'followers': 0, 'following': 0};
    }
  }

  /// Toggle follow/unfollow with optimistic updates
  Future<bool> toggleFollow(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) {
      debugPrint('❌ Cannot follow yourself');
      return false;
    }

    final key = '${currentUserId}_$targetUserId';
    final wasFollowing = _followStates[key] ?? false;

    // Optimistic update
    _followStates[key] = !wasFollowing;
    _followersCounts[targetUserId] =
        (_followersCounts[targetUserId] ?? 0) + (wasFollowing ? -1 : 1);
    _followingCounts[currentUserId] =
        (_followingCounts[currentUserId] ?? 0) + (wasFollowing ? -1 : 1);
    notifyListeners();

    try {
      await _firestore.runTransaction((transaction) async {
        // References
        final currentUserFollowingDoc = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId);

        final targetUserFollowersDoc = _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId);

        final currentUserDoc =
            _firestore.collection('users').doc(currentUserId);
        final targetUserDoc = _firestore.collection('users').doc(targetUserId);

        // Check current state
        final followingSnapshot =
            await transaction.get(currentUserFollowingDoc);

        if (!followingSnapshot.exists && !wasFollowing) {
          // Follow action
          transaction.set(currentUserFollowingDoc, {
            'userId': targetUserId,
            'followedAt': FieldValue.serverTimestamp(),
          });

          transaction.set(targetUserFollowersDoc, {
            'userId': currentUserId,
            'followedAt': FieldValue.serverTimestamp(),
          });

          // Update counts
          transaction.update(currentUserDoc, {
            'followingCount': FieldValue.increment(1),
          });

          transaction.update(targetUserDoc, {
            'followersCount': FieldValue.increment(1),
          });

          debugPrint('✅ Followed user: $targetUserId');
        } else if (followingSnapshot.exists && wasFollowing) {
          // Unfollow action
          transaction.delete(currentUserFollowingDoc);
          transaction.delete(targetUserFollowersDoc);

          // Update counts
          transaction.update(currentUserDoc, {
            'followingCount': FieldValue.increment(-1),
          });

          transaction.update(targetUserDoc, {
            'followersCount': FieldValue.increment(-1),
          });

          debugPrint('✅ Unfollowed user: $targetUserId');
        }
      });

      return true;
    } catch (e) {
      // Revert optimistic update on error
      _followStates[key] = wasFollowing;
      _followersCounts[targetUserId] =
          (_followersCounts[targetUserId] ?? 0) + (wasFollowing ? 1 : -1);
      _followingCounts[currentUserId] =
          (_followingCounts[currentUserId] ?? 0) + (wasFollowing ? 1 : -1);
      notifyListeners();

      debugPrint('❌ Error toggling follow: $e');
      return false;
    }
  }

  /// Get list of users that current user is following
  Stream<List<String>> getFollowingUserIds(String currentUserId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Get list of users following the current user
  Stream<List<String>> getFollowersUserIds(String currentUserId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('followers')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Get detailed follower list with user data
  Future<List<Map<String, dynamic>>> getFollowersList(String userId,
      {int limit = 50}) async {
    try {
      final followersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .orderBy('followedAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> followers = [];

      for (var doc in followersSnapshot.docs) {
        final followerUserId = doc.id;
        final userDoc =
            await _firestore.collection('users').doc(followerUserId).get();

        if (userDoc.exists) {
          followers.add({
            ...userDoc.data()!,
            'followedAt': doc.data()['followedAt'],
          });
        }
      }

      return followers;
    } catch (e) {
      debugPrint('❌ Error getting followers list: $e');
      return [];
    }
  }

  /// Get detailed following list with user data
  Future<List<Map<String, dynamic>>> getFollowingList(String userId,
      {int limit = 50}) async {
    try {
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .orderBy('followedAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> following = [];

      for (var doc in followingSnapshot.docs) {
        final followingUserId = doc.id;
        final userDoc =
            await _firestore.collection('users').doc(followingUserId).get();

        if (userDoc.exists) {
          following.add({
            ...userDoc.data()!,
            'followedAt': doc.data()['followedAt'],
          });
        }
      }

      return following;
    } catch (e) {
      debugPrint('❌ Error getting following list: $e');
      return [];
    }
  }

  /// Clear cache
  void clearCache() {
    _followStates.clear();
    _followersCounts.clear();
    _followingCounts.clear();
    notifyListeners();
  }
}
