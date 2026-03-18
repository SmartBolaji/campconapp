import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/services/notification_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class PostInteractionState {
  int get likesCount;
  set likesCount(int value);

  int get bookmarksCount;
  set bookmarksCount(int value);

  int get repostsCount;
  set repostsCount(int value);

  bool get isLiked;
  set isLiked(bool value);

  bool get isBookmarked;
  set isBookmarked(bool value);

  bool get isReposted;
  set isReposted(bool value);
}

mixin PostInteractionMixin<T extends PostInteractionState> on ChangeNotifier {
  FirebaseFirestore get firestore;
  Map<String, T> get postStates;
  T createPostState();

  T getOrCreatePostState(String postId) {
    if (!postStates.containsKey(postId)) {
      postStates[postId] = createPostState();
    }
    return postStates[postId]!;
  }

  Future<bool> checkIfLiked(String postId, String userId) async {
    try {
      final likeDoc = await firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();

      final state = getOrCreatePostState(postId);
      state.isLiked = likeDoc.exists;
      return state.isLiked;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }

  Future<bool> checkIfBookmarked(String postId, String userId) async {
    try {
      final bookmarkDoc = await firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(userId)
          .get();

      final state = getOrCreatePostState(postId);
      state.isBookmarked = bookmarkDoc.exists;
      return state.isBookmarked;
    } catch (e) {
      debugPrint('Error checking bookmark status: $e');
      return false;
    }
  }

  Future<bool> checkIfReposted(String postId, String userId) async {
    try {
      final repostDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('reposts')
          .doc(postId)
          .get();

      final state = getOrCreatePostState(postId);
      state.isReposted = repostDoc.exists;
      return state.isReposted;
    } catch (e) {
      debugPrint('Error checking repost status: $e');
      return false;
    }
  }

  Future<void> toggleLikeInteraction({
    required String postId,
    required String userId,
    required String postAuthorId,
    NotifyProvider? notifyProvider,
    UserModel? currentUser,
    String? postImageUrl,
    Future<void> Function()? onLikeCompleted,
  }) async {
    final state = getOrCreatePostState(postId);
    final wasLiked = state.isLiked;

    state.isLiked = !wasLiked;
    state.likesCount =
        (state.likesCount + (wasLiked ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final likeDoc = firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId);

      await firestore.runTransaction((transaction) async {
        final likeSnapshot = await transaction.get(likeDoc);

        if (!likeSnapshot.exists && !wasLiked) {
          final userRef = firestore.collection('users').doc(userId);
          transaction.set(likeDoc, {
            'likedby': userRef,
            'timestamp': FieldValue.serverTimestamp(),
          });
          transaction.update(
            firestore.collection('posts').doc(postId),
            {'likesCount': FieldValue.increment(1)},
          );

          if (postAuthorId != userId &&
              currentUser != null &&
              notifyProvider != null) {
            await NotificationHelper.createLikeNotification(
              notifyProvider: notifyProvider,
              recipientId: postAuthorId,
              actorId: userId,
              actorName: currentUser.username,
              actorProfileImage: currentUser.profileImageUrl,
              postId: postId,
              postImageUrl: postImageUrl,
            );
          }
        } else if (likeSnapshot.exists && wasLiked) {
          transaction.delete(likeDoc);
          transaction.update(
            firestore.collection('posts').doc(postId),
            {'likesCount': FieldValue.increment(-1)},
          );
        }
      });

      if (state.isLiked && onLikeCompleted != null) {
        await onLikeCompleted();
      }
    } catch (e) {
      state.isLiked = wasLiked;
      state.likesCount =
          (state.likesCount + (wasLiked ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  Future<void> toggleBookmarkInteraction({
    required String postId,
    required String userId,
  }) async {
    final state = getOrCreatePostState(postId);
    final wasBookmarked = state.isBookmarked;

    state.isBookmarked = !wasBookmarked;
    state.bookmarksCount =
        (state.bookmarksCount + (wasBookmarked ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final bookmarkDoc = firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(userId);

      final userBookmarkDoc = firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(postId);

      await firestore.runTransaction((transaction) async {
        final bookmarkSnapshot = await transaction.get(bookmarkDoc);

        if (!bookmarkSnapshot.exists && !wasBookmarked) {
          final userRef = firestore.collection('users').doc(userId);
          final postRef = firestore.collection('posts').doc(postId);

          transaction.set(bookmarkDoc, {
            'bookmarkedby': userRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.set(userBookmarkDoc, {
            'postRef': postRef,
            'type': 'media',
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.update(
            firestore.collection('posts').doc(postId),
            {'bookmarksCount': FieldValue.increment(1)},
          );
        } else if (bookmarkSnapshot.exists && wasBookmarked) {
          transaction.delete(bookmarkDoc);
          transaction.delete(userBookmarkDoc);
          transaction.update(
            firestore.collection('posts').doc(postId),
            {'bookmarksCount': FieldValue.increment(-1)},
          );
        }
      });
    } catch (e) {
      state.isBookmarked = wasBookmarked;
      state.bookmarksCount =
          (state.bookmarksCount + (wasBookmarked ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('Error toggling bookmark: $e');
      rethrow;
    }
  }

  Future<void> toggleRepostInteraction({
    required String postId,
    required String userId,
  }) async {
    final state = getOrCreatePostState(postId);
    final wasReposted = state.isReposted;

    state.isReposted = !wasReposted;
    state.repostsCount =
        (state.repostsCount + (wasReposted ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final postRepostDoc = firestore
          .collection('posts')
          .doc(postId)
          .collection('reposts')
          .doc(userId);

      final userRepostDoc = firestore
          .collection('users')
          .doc(userId)
          .collection('reposts')
          .doc(postId);

      final postRef = firestore.collection('posts').doc(postId);
      final userRef = firestore.collection('users').doc(userId);

      await firestore.runTransaction((transaction) async {
        final repostSnapshot = await transaction.get(postRepostDoc);

        if (!repostSnapshot.exists && !wasReposted) {
          transaction.set(postRepostDoc, {
            'repostedby': userRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.set(userRepostDoc, {
            'postRef': postRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.update(postRef, {
            'repostsCount': FieldValue.increment(1),
            'shares': FieldValue.increment(1),
          });
        } else if (repostSnapshot.exists && wasReposted) {
          transaction.delete(postRepostDoc);
          transaction.delete(userRepostDoc);
          transaction.update(postRef, {
            'repostsCount': FieldValue.increment(-1),
            'shares': FieldValue.increment(-1),
          });
        }
      });
    } catch (e) {
      state.isReposted = wasReposted;
      state.repostsCount =
          (state.repostsCount + (wasReposted ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('Error toggling repost: $e');
      rethrow;
    }
  }
}
