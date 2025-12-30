import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'dart:async';

class FeedProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store post data with post ID as key
  final Map<String, PostState> _posts = {};

  // Cache for user data
  final Map<String, UserModel> _userCache = {};

  // Feed state
  bool _isLoadingForYou = true;
  bool _isLoadingFriends = true;
  bool _isLoadingCampus = true; // ✅ Added
  String? _errorForYou;
  String? _errorFriends;
  String? _errorCampus; // ✅ Added
  List<PostWithAuthor> _forYouPosts = [];
  List<PostWithAuthor> _friendsPosts = [];
  List<PostWithAuthor> _campusPosts = []; // ✅ Added

  // ✅ Track if feeds have been loaded
  bool _forYouLoaded = false;
  bool _friendsLoaded = false;
  bool _campusLoaded = false; // ✅ Added

  StreamSubscription<List<PostWithAuthor>>? _forYouSubscription;
  StreamSubscription<List<PostWithAuthor>>? _friendsSubscription;
  StreamSubscription<List<PostWithAuthor>>? _campusSubscription; // ✅ Added

  // Getters
  bool get isLoadingForYou => _isLoadingForYou;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingCampus => _isLoadingCampus; // ✅ Added
  String? get errorForYou => _errorForYou;
  String? get errorFriends => _errorFriends;
  String? get errorCampus => _errorCampus; // ✅ Added
  List<PostWithAuthor> get forYouPosts => _forYouPosts;
  List<PostWithAuthor> get friendsPosts => _friendsPosts;
  List<PostWithAuthor> get campusPosts => _campusPosts; // ✅ Added

  // Get post state (always returns a valid state)
  PostState getPostState(String postId) {
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }
    return _posts[postId]!;
  }

  // Load For You feed
  Future<void> loadForYouFeed(String currentUserId) async {
    // ✅ Skip if already loaded
    if (_forYouLoaded && _forYouPosts.isNotEmpty) {
      debugPrint('✅ For You feed already loaded, skipping...');
      return;
    }

    if (currentUserId.isEmpty) {
      _errorForYou = 'User not authenticated';
      _isLoadingForYou = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingForYou = true;
      _errorForYou = null;
      notifyListeners();

      // Cancel existing subscription
      await _forYouSubscription?.cancel();

      // Load posts once
      final postsWithAuthors = await getPostsWithAuthors().first;

      // Initialize post states silently - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _forYouPosts = postsWithAuthors;
      _isLoadingForYou = false;
      _forYouLoaded = true;
      notifyListeners();

      // Listen for updates
      _forYouSubscription = getPostsWithAuthors().listen(
        (newPosts) {
          // Only update if there's actual change
          if (newPosts.length != _forYouPosts.length) {
            _forYouPosts = newPosts;
            notifyListeners();
          } else {
            // Check if comment counts changed
            bool hasChanges = false;
            for (int i = 0; i < newPosts.length; i++) {
              if (i < _forYouPosts.length &&
                  newPosts[i].post.comments != _forYouPosts[i].post.comments) {
                hasChanges = true;
                break;
              }
            }

            if (hasChanges) {
              _forYouPosts = newPosts;
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('For You stream error: $error');
        },
      );

      debugPrint('✅ For You feed loaded successfully');
    } catch (e) {
      _isLoadingForYou = false;
      _errorForYou = 'Failed to load posts';
      _forYouLoaded = false; // ✅ Reset on error
      notifyListeners();
      debugPrint('Error loading For You feed: $e');
    }
  }

  // Refresh For You feed
  Future<void> refreshForYouFeed(String currentUserId) async {
    if (currentUserId.isEmpty) return;

    try {
      debugPrint('🔄 Refreshing For You feed...');

      final postsWithAuthors = await getPostsWithAuthors().first;

      // Re-initialize post states - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _forYouPosts = postsWithAuthors;
      notifyListeners();

      debugPrint('✅ For You feed refreshed');
    } catch (e) {
      debugPrint('Error refreshing For You feed: $e');
    }
  }

  // Load Friends feed
  Future<void> loadFriendsFeed(String currentUserId) async {
    // ✅ Skip if already loaded
    if (_friendsLoaded) {
      debugPrint('✅ Friends feed already loaded, skipping...');
      return;
    }

    if (currentUserId.isEmpty) {
      _errorFriends = 'User not authenticated';
      _isLoadingFriends = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingFriends = true;
      _errorFriends = null;
      notifyListeners();

      // Cancel existing subscription
      await _friendsSubscription?.cancel();

      // Load posts from following users
      final postsWithAuthors = await getFollowingFeed(currentUserId).first;

      // Initialize post states silently - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _friendsPosts = postsWithAuthors;
      _isLoadingFriends = false;
      _friendsLoaded = true;
      notifyListeners();

      // Listen for updates
      _friendsSubscription = getFollowingFeed(currentUserId).listen(
        (newPosts) {
          // Only update if there's actual change
          if (newPosts.length != _friendsPosts.length) {
            _friendsPosts = newPosts;
            notifyListeners();
          } else {
            // Check if comment counts changed
            bool hasChanges = false;
            for (int i = 0; i < newPosts.length; i++) {
              if (i < _friendsPosts.length &&
                  newPosts[i].post.comments != _friendsPosts[i].post.comments) {
                hasChanges = true;
                break;
              }
            }

            if (hasChanges) {
              _friendsPosts = newPosts;
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('Friends stream error: $error');
        },
      );

      debugPrint('✅ Friends feed loaded successfully');
    } catch (e) {
      _isLoadingFriends = false;
      _errorFriends = 'Failed to load posts';
      _friendsLoaded = false; // ✅ Reset on error
      notifyListeners();
      debugPrint('Error loading Friends feed: $e');
    }
  }

  // Refresh Friends feed
  Future<void> refreshFriendsFeed(String currentUserId) async {
    if (currentUserId.isEmpty) return;

    try {
      debugPrint('🔄 Refreshing Friends feed...');

      final postsWithAuthors = await getFollowingFeed(currentUserId).first;

      // Re-initialize post states - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _friendsPosts = postsWithAuthors;
      notifyListeners();

      debugPrint('✅ Friends feed refreshed');
    } catch (e) {
      debugPrint('Error refreshing Friends feed: $e');
    }
  }

  // ✅ Load Campus feed
  Future<void> loadCampusFeed(String currentUserId, String campus) async {
    // Skip if already loaded
    if (_campusLoaded && _campusPosts.isNotEmpty) {
      debugPrint('✅ Campus feed already loaded, skipping...');
      return;
    }

    if (currentUserId.isEmpty || campus.isEmpty) {
      _errorCampus =
          campus.isEmpty ? 'No campus selected' : 'User not authenticated';
      _isLoadingCampus = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingCampus = true;
      _errorCampus = null;
      notifyListeners();

      // Cancel existing subscription
      await _campusSubscription?.cancel();

      // Load posts from campus
      final postsWithAuthors = await getCampusFeed(campus).first;

      // Initialize post states silently - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _campusPosts = postsWithAuthors;
      _isLoadingCampus = false;
      _campusLoaded = true;
      notifyListeners();

      // Listen for updates
      _campusSubscription = getCampusFeed(campus).listen(
        (newPosts) {
          // Only update if there's actual change
          if (newPosts.length != _campusPosts.length) {
            _campusPosts = newPosts;
            notifyListeners();
          } else {
            // Check if comment counts changed
            bool hasChanges = false;
            for (int i = 0; i < newPosts.length; i++) {
              if (i < _campusPosts.length &&
                  newPosts[i].post.comments != _campusPosts[i].post.comments) {
                hasChanges = true;
                break;
              }
            }

            if (hasChanges) {
              _campusPosts = newPosts;
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('Campus stream error: $error');
        },
      );

      debugPrint('✅ Campus feed loaded successfully');
    } catch (e) {
      _isLoadingCampus = false;
      _errorCampus = 'Failed to load campus posts';
      _campusLoaded = false;
      notifyListeners();
      debugPrint('Error loading Campus feed: $e');
    }
  }

  // ✅ Refresh Campus feed
  Future<void> refreshCampusFeed(String currentUserId, String campus) async {
    if (currentUserId.isEmpty || campus.isEmpty) return;

    try {
      debugPrint('🔄 Refreshing Campus feed...');

      final postsWithAuthors = await getCampusFeed(campus).first;

      // Re-initialize post states - ✅ ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), // ✅ NEW
        ]);
      }

      _campusPosts = postsWithAuthors;
      notifyListeners();

      debugPrint('✅ Campus feed refreshed');
    } catch (e) {
      debugPrint('Error refreshing Campus feed: $e');
    }
  }

  // Retry loading For You feed
  void retryForYouFeed(String currentUserId) {
    _forYouLoaded = false; // ✅ Reset loaded flag
    loadForYouFeed(currentUserId);
  }

  // Retry loading Friends feed
  void retryFriendsFeed(String currentUserId) {
    _friendsLoaded = false; // ✅ Reset loaded flag
    loadFriendsFeed(currentUserId);
  }

  // ✅ Retry loading Campus feed
  void retryCampusFeed(String currentUserId, String campus) {
    _campusLoaded = false;
    loadCampusFeed(currentUserId, campus);
  }

  // Delete post from local lists
  void deletePostLocally(String postId) {
    _forYouPosts.removeWhere((p) => p.post.postId == postId);
    _friendsPosts.removeWhere((p) => p.post.postId == postId);
    _campusPosts.removeWhere((p) => p.post.postId == postId); // ✅ Added
    _posts.remove(postId);
    notifyListeners();
  }

  // ✅ Force reload (useful after posting new content)
  void forceReloadForYou(String currentUserId) {
    _forYouLoaded = false;
    loadForYouFeed(currentUserId);
  }

  void forceReloadFriends(String currentUserId) {
    _friendsLoaded = false;
    loadFriendsFeed(currentUserId);
  }

  // ✅ Force reload Campus feed
  void forceReloadCampus(String currentUserId, String campus) {
    _campusLoaded = false;
    loadCampusFeed(currentUserId, campus);
  }

  // ✅ Invalidate cache (useful when user logs out or switches accounts)
  void invalidateCache() {
    _forYouLoaded = false;
    _friendsLoaded = false;
    _campusLoaded = false; // ✅ Added
    _forYouPosts.clear();
    _friendsPosts.clear();
    _campusPosts.clear(); // ✅ Added
    _userCache.clear();
    _posts.clear();
    _errorForYou = null;
    _errorFriends = null;
    _errorCampus = null; // ✅ Added
    _isLoadingForYou = true;
    _isLoadingFriends = true;
    _isLoadingCampus = true; // ✅ Added

    _forYouSubscription?.cancel();
    _friendsSubscription?.cancel();
    _campusSubscription?.cancel(); // ✅ Added

    notifyListeners();
    debugPrint('🗑️ Feed cache invalidated');
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
          int repostsCount = 0; // ✅ NEW

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
              _firestore
                  .collection('posts')
                  .doc(post.postId)
                  .collection('reposts')
                  .count()
                  .get(), // ✅ NEW
            ]);

            likesCount = counts[0].count ?? 0;
            bookmarksCount = counts[1].count ?? 0;
            commentsCount = counts[2].count ?? 0;
            repostsCount = counts[3].count ?? 0; // ✅ NEW
          } catch (e) {
            debugPrint('Error getting counts for ${post.postId}: $e');
          }

          // Initialize post state if not exists (without notifying)
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
              repostsCount: post.shares, // ✅ Use post.shares for repost count
            );
          } else {
            // Update counts from Firestore (preserve like/bookmark/repost state)
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
            currentState.repostsCount = post.shares; // ✅ Use post.shares
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

  /// Get posts from users that current user is following (for Friends tab)
  Stream<List<PostWithAuthor>> getFollowingFeed(String currentUserId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .snapshots()
        .asyncMap((followingSnapshot) async {
      // Get list of user IDs being followed
      List<String> followingIds =
          followingSnapshot.docs.map((doc) => doc.id).toList();

      if (followingIds.isEmpty) {
        return <PostWithAuthor>[];
      }

      // Firestore 'in' query limit is 10, so we need to batch
      List<PostWithAuthor> allPosts = [];

      // Process in batches of 10
      for (int i = 0; i < followingIds.length; i += 10) {
        final batch = followingIds.skip(i).take(10).toList();

        final postsSnapshot = await _firestore
            .collection('posts')
            .where('userId', whereIn: batch)
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get();

        for (var doc in postsSnapshot.docs) {
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

            // Get counts
            int likesCount = 0;
            int bookmarksCount = 0;
            int commentsCount = 0;
            int repostsCount = 0; // ✅ NEW

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
                _firestore
                    .collection('posts')
                    .doc(post.postId)
                    .collection('reposts')
                    .count()
                    .get(), // ✅ NEW
              ]);

              likesCount = counts[0].count ?? 0;
              bookmarksCount = counts[1].count ?? 0;
              commentsCount = counts[2].count ?? 0;
              repostsCount = counts[3].count ?? 0; // ✅ NEW
            } catch (e) {
              debugPrint('Error getting counts for ${post.postId}: $e');
            }

            // Initialize post state
            if (!_posts.containsKey(post.postId)) {
              _posts[post.postId] = PostState(
                likesCount: likesCount,
                bookmarksCount: bookmarksCount,
                repliesCount: commentsCount,
                repostsCount: repostsCount, // ✅ NEW
              );
            }

            allPosts.add(PostWithAuthor(
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
      }

      // Sort by date
      allPosts.sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));

      return allPosts;
    });
  }

  // Get campus feed (posts filtered by campus)
  Stream<List<PostWithAuthor>> getCampusFeed(String campus) {
    return _firestore
        .collection('posts')
        .where('campus', isEqualTo: campus)
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
          int repostsCount = 0; // ✅ NEW

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
              _firestore
                  .collection('posts')
                  .doc(post.postId)
                  .collection('reposts')
                  .count()
                  .get(), // ✅ NEW
            ]);

            likesCount = counts[0].count ?? 0;
            bookmarksCount = counts[1].count ?? 0;
            commentsCount = counts[2].count ?? 0;
            repostsCount = counts[3].count ?? 0; // ✅ NEW
          } catch (e) {
            debugPrint('Error getting counts for ${post.postId}: $e');
          }

          // Initialize or update post state
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
              repostsCount: repostsCount, // ✅ NEW
            );
          } else {
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
            currentState.repostsCount = repostsCount; // ✅ NEW
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
      final likeDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();

      final isLiked = likeDoc.exists;

      // Update local state
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
      final bookmarkDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(userId)
          .get();

      final isBookmarked = bookmarkDoc.exists;

      // Update local state
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

  // ✅ NEW: Check if current user reposted a post
  Future<bool> checkIfReposted(String postId, String userId) async {
    try {
      final repostDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reposts')
          .doc(postId)
          .get();

      final isReposted = repostDoc.exists;

      // Update local state
      if (!_posts.containsKey(postId)) {
        _posts[postId] = PostState();
      }
      _posts[postId]!.isReposted = isReposted;

      return isReposted;
    } catch (e) {
      debugPrint('Error checking repost status: $e');
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

  // ✅ NEW: Toggle repost with optimistic updates
  Future<void> toggleRepost(String postId, String userId) async {
    // Ensure post state exists
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }

    final post = _posts[postId]!;
    final wasReposted = post.isReposted;

    // Optimistically update UI IMMEDIATELY
    post.isReposted = !wasReposted;
    post.repostsCount =
        (post.repostsCount + (wasReposted ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final userRepostDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('reposts')
          .doc(postId);

      final postRef = _firestore.collection('posts').doc(postId);

      await _firestore.runTransaction((transaction) async {
        final repostSnapshot = await transaction.get(userRepostDoc);

        if (!repostSnapshot.exists && !wasReposted) {
          // Add repost
          transaction.set(userRepostDoc, {
            'postRef': postRef,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Update shares count on the post
          transaction.update(postRef, {
            'shares': FieldValue.increment(1),
          });
        } else if (repostSnapshot.exists && wasReposted) {
          // Remove repost
          transaction.delete(userRepostDoc);

          // Update shares count on the post
          transaction.update(postRef, {
            'shares': FieldValue.increment(-1),
          });
        }
      });

      debugPrint('✅ Repost synced successfully: $postId');
    } catch (e) {
      // Revert on error
      post.isReposted = wasReposted;
      post.repostsCount =
          (post.repostsCount + (wasReposted ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('❌ Error toggling repost: $e');
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

  // Clear cache (deprecated - use invalidateCache instead)
  @Deprecated('Use invalidateCache() instead')
  void clearCache() {
    invalidateCache();
  }

  @override
  void dispose() {
    _forYouSubscription?.cancel();
    _friendsSubscription?.cancel();
    _campusSubscription?.cancel();
    super.dispose();
  }
}

// ✅ UPDATED: PostState with repost support
class PostState {
  int likesCount;
  int bookmarksCount;
  int repliesCount;
  int repostsCount; // ✅ NEW
  bool isLiked;
  bool isBookmarked;
  bool isReposted; // ✅ NEW

  PostState({
    this.likesCount = 0,
    this.bookmarksCount = 0,
    this.repliesCount = 0,
    this.repostsCount = 0, // ✅ NEW
    this.isLiked = false,
    this.isBookmarked = false,
    this.isReposted = false, // ✅ NEW
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
