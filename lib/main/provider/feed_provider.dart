import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';

class FeedProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store post data with post ID as key
  final Map<String, PostState> _posts = {};

  // Cache for user data
  final Map<String, UserModel> _userCache = {};

  // Get post state (always returns a valid state)
  PostState getPostState(String postId) {
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }
    return _posts[postId]!;
  }

  // Fetch posts with author data
  Stream<List<PostWithAuthor>> getPostsWithAuthors() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
      List<PostWithAuthor> postsWithAuthors = [];

      for (var doc in snapshot.docs) {
        try {
          final postData = doc.data();
          final post = PostModel.fromMap(postData);

          // Get or fetch author data
          UserModel? author = _userCache[post.userId];
          if (author == null) {
            try {
              final userDoc =
                  await _firestore.collection('users').doc(post.userId).get();
              if (userDoc.exists && userDoc.data() != null) {
                author = UserModel.fromMap(userDoc.data()!);
                _userCache[post.userId] = author;
              }
            } catch (e) {
              debugPrint('Error fetching user ${post.userId}: $e');
            }
          }

          // Get counts from subcollections
          int likesCount = 0;
          int bookmarksCount = 0;
          int commentsCount = 0;

          try {
            final counts = await Future.wait([
              _firestore
                  .collection('posts')
                  .doc(post.postId)
                  .collection('likes')
                  .count()
                  .get(),
              _firestore
                  .collection('posts')
                  .doc(post.postId)
                  .collection('bookmarks')
                  .count()
                  .get(),
              _firestore
                  .collection('posts')
                  .doc(post.postId)
                  .collection('comments')
                  .count()
                  .get(),
            ]);

            likesCount = counts[0].count ?? 0;
            bookmarksCount = counts[1].count ?? 0;
            commentsCount = counts[2].count ?? 0;
          } catch (e) {
            debugPrint('Error getting counts for ${post.postId}: $e');
          }

          // Initialize post state if not exists (without notifying)
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
            );
          } else {
            // Update counts from Firestore (preserve like/bookmark state)
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
          }

          postsWithAuthors.add(PostWithAuthor(
            post: post.copyWith(
              likes: likesCount,
              comments: commentsCount,
              shares: 0,
            ),
            author: author,
          ));
        } catch (e) {
          debugPrint('Error processing post: $e');
        }
      }

      return postsWithAuthors;
    });
  }

  // Check if current user liked a post
  Future<bool> checkIfLiked(String postId, String userId) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();

      final isLiked = doc.exists;

      // Update state silently (no notify)
      if (!_posts.containsKey(postId)) {
        _posts[postId] = PostState();
      }
      _posts[postId]!.isLiked = isLiked;

      return isLiked;
    } catch (e) {
      debugPrint('Error checking like status: $e');
      return false;
    }
  }

  // Check if current user bookmarked a post
  Future<bool> checkIfBookmarked(String postId, String userId) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(userId)
          .get();

      final isBookmarked = doc.exists;

      // Update state silently (no notify)
      if (!_posts.containsKey(postId)) {
        _posts[postId] = PostState();
      }
      _posts[postId]!.isBookmarked = isBookmarked;

      return isBookmarked;
    } catch (e) {
      debugPrint('Error checking bookmark status: $e');
      return false;
    }
  }

  // Update like state with optimistic updates
  Future<void> toggleLike(
      String postId, String userId, String postAuthorId) async {
    // Ensure post state exists
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }

    final post = _posts[postId]!;
    final wasLiked = post.isLiked;

    // Optimistically update UI IMMEDIATELY
    post.isLiked = !wasLiked;
    post.likesCount =
        (post.likesCount + (wasLiked ? -1 : 1)).clamp(0, 999999999);
    notifyListeners(); // ✅ Updates UI instantly

    try {
      final likeDoc = _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final likeSnapshot = await transaction.get(likeDoc);

        if (!likeSnapshot.exists && !wasLiked) {
          // Add like
          final userRef = _firestore.collection('users').doc(userId);
          transaction.set(likeDoc, {
            'likedby': userRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Create notification if not liking own post
          if (postAuthorId != userId) {
            debugPrint('📢 Create like notification for $postAuthorId');
          }
        } else if (likeSnapshot.exists && wasLiked) {
          // Remove like
          transaction.delete(likeDoc);
        }
      });

      debugPrint('✅ Like synced successfully: $postId');
    } catch (e) {
      // Revert on error
      post.isLiked = wasLiked;
      post.likesCount =
          (post.likesCount + (wasLiked ? 1 : -1)).clamp(0, 999999999);
      notifyListeners(); // ✅ Reverts UI
      debugPrint('❌ Error toggling like: $e');
      rethrow;
    }
  }

  // Update bookmark state with optimistic updates
  Future<void> toggleBookmark(String postId, String userId) async {
    // Ensure post state exists
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }

    final post = _posts[postId]!;
    final wasBookmarked = post.isBookmarked;

    // Optimistically update UI IMMEDIATELY
    post.isBookmarked = !wasBookmarked;
    post.bookmarksCount =
        (post.bookmarksCount + (wasBookmarked ? -1 : 1)).clamp(0, 999999999);
    notifyListeners(); // ✅ Updates UI instantly

    try {
      final bookmarkDoc = _firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(userId);

      final userBookmarkDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc(postId);

      await _firestore.runTransaction((transaction) async {
        final bookmarkSnapshot = await transaction.get(bookmarkDoc);

        if (!bookmarkSnapshot.exists && !wasBookmarked) {
          // Add bookmark
          final userRef = _firestore.collection('users').doc(userId);
          final postRef = _firestore.collection('posts').doc(postId);

          transaction.set(bookmarkDoc, {
            'bookmarkedby': userRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          transaction.set(userBookmarkDoc, {
            'postRef': postRef,
            'type': 'media',
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else if (bookmarkSnapshot.exists && wasBookmarked) {
          // Remove bookmark
          transaction.delete(bookmarkDoc);
          transaction.delete(userBookmarkDoc);
        }
      });

      debugPrint('✅ Bookmark synced successfully: $postId');
    } catch (e) {
      // Revert on error
      post.isBookmarked = wasBookmarked;
      post.bookmarksCount =
          (post.bookmarksCount + (wasBookmarked ? 1 : -1)).clamp(0, 999999999);
      notifyListeners(); // ✅ Reverts UI
      debugPrint('❌ Error toggling bookmark: $e');
      rethrow;
    }
  }

  // Update replies count
  void updateRepliesCount(String postId, int increment) {
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }

    _posts[postId]!.repliesCount =
        (_posts[postId]!.repliesCount + increment).clamp(0, 999999999);
    notifyListeners();
  }

  // Clear cache
  void clearCache() {
    _userCache.clear();
    _posts.clear();
    notifyListeners();
  }
}

class PostState {
  int likesCount;
  int bookmarksCount;
  int repliesCount;
  bool isLiked;
  bool isBookmarked;

  PostState({
    this.likesCount = 0,
    this.bookmarksCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });
}

class PostWithAuthor {
  final PostModel post;
  final UserModel? author;

  PostWithAuthor({
    required this.post,
    this.author,
  });
}
