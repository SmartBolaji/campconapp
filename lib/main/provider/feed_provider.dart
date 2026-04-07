import 'package:campcon/main/provider/notify_provider.dart'; //  Add this import
import 'package:campcon/main/provider/post_interaction_mixin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/models/post_with_author_model.dart';
import 'dart:async';
import 'dart:collection';
import 'package:campcon/main/services/algorithm/user_engagement_service.dart';
import 'package:campcon/main/services/algorithm/post_tagging_service.dart';
import 'package:campcon/main/services/algorithm/post_scoring_service.dart';

class FeedProvider with ChangeNotifier, PostInteractionMixin<PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserEngagementService _engagementService = UserEngagementService();
  final PostScoringService _scoringService = PostScoringService();

  // Personalization data
  UserPersonalizationData? _personalizationData;

  // Store post data with post ID as key
  final Map<String, PostState> _posts = {};

  // LRU Cache for user data (max 100 entries)
  static const int _userCacheMaxSize = 100;
  final LinkedHashMap<String, UserModel> _userCache =
      LinkedHashMap<String, UserModel>();

  // Feed state
  bool _isLoadingForYou = true;
  bool _isLoadingFriends = true;
  bool _isLoadingCampus = true;
  String? _errorForYou;
  String? _errorFriends;
  String? _errorCampus;
  List<PostWithAuthor> _forYouPosts = [];
  List<PostWithAuthor> _friendsPosts = [];
  List<PostWithAuthor> _campusPosts = [];

  bool _forYouLoaded = false;
  bool _friendsLoaded = false;
  bool _campusLoaded = false;

  StreamSubscription<List<PostWithAuthor>>? _forYouSubscription;
  StreamSubscription<List<PostWithAuthor>>? _friendsSubscription;
  StreamSubscription<List<PostWithAuthor>>? _campusSubscription;

  // ✅ Polling subscriptions for new posts detection
  StreamSubscription<void>? _forYouPollingSubscription;
  StreamSubscription<void>? _friendsPollingSubscription;
  StreamSubscription<void>? _campusPollingSubscription;

  // ✅ NEW: Twitter-style "New posts" counter + timestamps
  int _forYouNewPostsCount = 0;
  int _friendsNewPostsCount = 0;
  int _campusNewPostsCount = 0;
  DateTime? _forYouLastLoadedTime;
  DateTime? _friendsLastLoadedTime;
  DateTime? _campusLastLoadedTime;
  bool _isLoadingNewForYou = false;
  bool _isLoadingNewFriends = false;
  bool _isLoadingNewCampus = false;

  // Pagination state
  DocumentSnapshot? _forYouLastDoc;
  DocumentSnapshot? _friendsLastDoc;
  DocumentSnapshot? _campusLastDoc;
  bool _forYouHasMore = true;
  bool _friendsHasMore = true;
  bool _campusHasMore = true;
  bool _isLoadingMoreForYou = false;
  bool _isLoadingMoreFriends = false;
  bool _isLoadingMoreCampus = false;
  static const int _initialPageSize = 15;
  static const int _pageSize = 10;

  // Getters
  bool get isLoadingForYou => _isLoadingForYou;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingCampus => _isLoadingCampus; //  Added
  bool get isLoadingMoreForYou => _isLoadingMoreForYou;
  bool get isLoadingMoreFriends => _isLoadingMoreFriends;
  bool get isLoadingMoreCampus => _isLoadingMoreCampus;
  bool get forYouHasMore => _forYouHasMore;
  bool get friendsHasMore => _friendsHasMore;
  bool get campusHasMore => _campusHasMore;
  String? get errorForYou => _errorForYou;
  String? get errorFriends => _errorFriends;
  String? get errorCampus => _errorCampus; //  Added
  List<PostWithAuthor> get forYouPosts => _forYouPosts;
  List<PostWithAuthor> get friendsPosts => _friendsPosts;
  List<PostWithAuthor> get campusPosts => _campusPosts; //  Added

  // ✅ NEW: New posts getters
  int get forYouNewPostsCount => _forYouNewPostsCount;
  int get friendsNewPostsCount => _friendsNewPostsCount;
  int get campusNewPostsCount => _campusNewPostsCount;
  bool get isLoadingNewForYou => _isLoadingNewForYou;
  bool get isLoadingNewFriends => _isLoadingNewFriends;
  bool get isLoadingNewCampus => _isLoadingNewCampus;

  // Get post state (always returns a valid state)
  PostState getPostState(String postId) {
    if (!_posts.containsKey(postId)) {
      _posts[postId] = PostState();
    }
    return _posts[postId]!;
  }

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  Map<String, PostState> get postStates => _posts;

  @override
  PostState createPostState() => PostState();

  /// Add user to cache with LRU eviction (max 100 entries)
  void _cacheUser(String userId, UserModel user) {
    // Move to end (most recently used)
    _userCache.remove(userId);
    _userCache[userId] = user;

    // Evict oldest entries if cache exceeds max size
    if (_userCache.length > _userCacheMaxSize) {
      final firstKey = _userCache.keys.first;
      _userCache.remove(firstKey);
      debugPrint('🗑️ Evicted user from cache: $firstKey');
    }
  }

  // Load For You feed
  Future<void> loadForYouFeed(String currentUserId) async {
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

      // Load personalization data
      _personalizationData =
          await _engagementService.getPersonalizationData(currentUserId);
      debugPrint(
          '📊 Personalization data loaded: ${_personalizationData?.hasPersonalizationData}');

      // Load posts with personalization
      final postsWithAuthors =
          await getPersonalizedForYouFeed(currentUserId).first;

      // Initialize post states silently
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId),
        ]);
      }

      _forYouPosts = postsWithAuthors;
      _forYouLastLoadedTime = DateTime.now();
      _isLoadingForYou = false;
      _forYouLoaded = true;
      _forYouNewPostsCount = 0;
      notifyListeners();

      debugPrint('✅ For You feed loaded at $_forYouLastLoadedTime');

      // ✅ START: Twitter-style "New posts" polling (check every 30 seconds)
      await _forYouPollingSubscription?.cancel();
      _forYouPollingSubscription =
          Stream.periodic(const Duration(seconds: 30)).listen((_) async {
        debugPrint('🔍 Checking for new For You posts...');
        await _checkForNewForYouPosts(currentUserId);
      });

      debugPrint('✅ For You feed loaded successfully with polling enabled');
    } catch (e) {
      _isLoadingForYou = false;
      _errorForYou = 'Failed to load posts';
      _forYouLoaded = false;
      notifyListeners();
      debugPrint('Error loading For You feed: $e');
    }
  }

  // Personalized For You feed algorithm
  Stream<List<PostWithAuthor>> getPersonalizedForYouFeed(String currentUserId) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_initialPageSize)
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
                _cacheUser(post.userId, author);
              }
            } catch (e) {
              debugPrint('Error fetching user ${post.userId}: $e');
            }
          }

          // Get counts from denormalized fields instead of subcollection queries
          final likesCount = postData.containsKey('likesCount')
              ? postData['likesCount'] ?? 0
              : 0;
          final bookmarksCount = postData.containsKey('bookmarksCount')
              ? postData['bookmarksCount'] ?? 0
              : 0;
          final commentsCount = postData.containsKey('commentsCount')
              ? postData['commentsCount'] ?? 0
              : 0;

          // Initialize post state
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
              repostsCount: post.shares,
            );
          } else {
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
            currentState.repostsCount = post.shares;
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

      // ✅ Apply personalization scoring and sorting
      if (_personalizationData != null &&
          _personalizationData!.hasPersonalizationData) {
        postsWithAuthors = _scoreAndSortPosts(postsWithAuthors, currentUserId);
      }

      // Return top 50 after scoring
      return postsWithAuthors.take(50).toList();
    });
  }

  /// ✅ NEW: Score and sort posts based on user preferences
  // Prioritizes new posts while still rewarding engagement
  List<PostWithAuthor> _scoreAndSortPosts(
    List<PostWithAuthor> posts,
    String currentUserId,
  ) {
    return _scoringService.scoreAndSortPosts(
      posts,
      currentUserId,
      _personalizationData,
      postStates: _posts,
    );
  }

  // Load Friends feed
  Future<void> loadFriendsFeed(String currentUserId) async {
    //  Skip if already loaded
    if (_friendsLoaded) {
      debugPrint(' Friends feed already loaded, skipping...');
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

      // Initialize post states silently -  ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), //  NEW
        ]);
      }

      _friendsPosts = postsWithAuthors;
      _friendsLastLoadedTime = DateTime.now();
      _isLoadingFriends = false;
      _friendsLoaded = true;
      _friendsNewPostsCount = 0;
      notifyListeners();

      // ✅ START: Twitter-style "New posts" polling (check every 30 seconds)
      await _friendsPollingSubscription?.cancel();
      _friendsPollingSubscription =
          Stream.periodic(const Duration(seconds: 30)).listen((_) async {
        debugPrint('🔍 Checking for new Friends posts...');
        await _checkForNewFriendsPosts(currentUserId);
      });

      debugPrint(' Friends feed loaded successfully with polling enabled');
    } catch (e) {
      _isLoadingFriends = false;
      _errorFriends = 'Failed to load posts';
      _friendsLoaded = false; //  Reset on error
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

      // Re-initialize post states -  ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), //  NEW
        ]);
      }

      _friendsPosts = postsWithAuthors;
      notifyListeners();

      debugPrint(' Friends feed refreshed');
    } catch (e) {
      debugPrint('Error refreshing Friends feed: $e');
    }
  }

  //  Load Campus feed
  Future<void> loadCampusFeed(String currentUserId, String campus) async {
    // Skip if already loaded
    if (_campusLoaded && _campusPosts.isNotEmpty) {
      debugPrint(' Campus feed already loaded, skipping...');
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

      // Initialize post states silently -  ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), //  NEW
        ]);
      }

      _campusPosts = postsWithAuthors;
      _campusLastLoadedTime = DateTime.now();
      _isLoadingCampus = false;
      _campusLoaded = true;
      _campusNewPostsCount = 0;
      notifyListeners();

      // ✅ START: Twitter-style "New posts" polling (check every 30 seconds)
      await _campusPollingSubscription?.cancel();
      _campusPollingSubscription =
          Stream.periodic(const Duration(seconds: 30)).listen((_) async {
        debugPrint('🔍 Checking for new Campus posts...');
        await _checkForNewCampusPosts(campus);
      });

      debugPrint(' Campus feed loaded successfully with polling enabled');
    } catch (e) {
      _isLoadingCampus = false;
      _errorCampus = 'Failed to load campus posts';
      _campusLoaded = false;
      notifyListeners();
      debugPrint('Error loading Campus feed: $e');
    }
  }

  //  Refresh Campus feed
  Future<void> refreshCampusFeed(String currentUserId, String campus) async {
    if (currentUserId.isEmpty || campus.isEmpty) return;

    try {
      debugPrint('🔄 Refreshing Campus feed...');

      final postsWithAuthors = await getCampusFeed(campus).first;

      // Re-initialize post states -  ADDED checkIfReposted
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId), //  NEW
        ]);
      }

      _campusPosts = postsWithAuthors;
      notifyListeners();

      debugPrint(' Campus feed refreshed');
    } catch (e) {
      debugPrint('Error refreshing Campus feed: $e');
    }
  }

  // Retry loading For You feed
  void retryForYouFeed(String currentUserId) {
    _forYouLoaded = false; //  Reset loaded flag
    loadForYouFeed(currentUserId);
  }

  // Retry loading Friends feed
  void retryFriendsFeed(String currentUserId) {
    _friendsLoaded = false; //  Reset loaded flag
    loadFriendsFeed(currentUserId);
  }

  //  Retry loading Campus feed
  void retryCampusFeed(String currentUserId, String campus) {
    _campusLoaded = false;
    loadCampusFeed(currentUserId, campus);
  }

  // Delete post from local lists
  void deletePostLocally(String postId) {
    debugPrint('🗑️ deletePostLocally called for postId=$postId');
    debugPrint(
        '📍 Before delete - forYouPosts: ${_forYouPosts.length}, friendsPosts: ${_friendsPosts.length}, campusPosts: ${_campusPosts.length}');

    _forYouPosts.removeWhere((p) => p.post.postId == postId);
    _friendsPosts.removeWhere((p) => p.post.postId == postId);
    _campusPosts.removeWhere((p) => p.post.postId == postId);
    _posts.remove(postId);

    debugPrint(
        '📍 After delete - forYouPosts: ${_forYouPosts.length}, friendsPosts: ${_friendsPosts.length}, campusPosts: ${_campusPosts.length}');
    debugPrint('✅ Post removed from all lists');

    notifyListeners();
  }

  // ✅ NEW: Check for new posts since last load (For You)
  Future<void> _checkForNewForYouPosts(String currentUserId) async {
    if (_forYouLastLoadedTime == null) {
      debugPrint('⚠️ _forYouLastLoadedTime is null, skipping check');
      return;
    }

    try {
      debugPrint('📍 Checking posts created after: $_forYouLastLoadedTime');

      final query = _firestore
          .collection('posts')
          .where('createdAt', isGreaterThan: _forYouLastLoadedTime!)
          .count();

      final snapshot = await query.get();
      _forYouNewPostsCount = snapshot.count ?? 0;

      debugPrint('📊 New For You posts count: $_forYouNewPostsCount');

      if (_forYouNewPostsCount > 0) {
        debugPrint(
            '✨ Found $_forYouNewPostsCount new For You posts - notifying listeners');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error checking for new For You posts: $e');
    }
  }

  // ✅ NEW: Load new posts and prepend to feed (For You)
  Future<void> loadNewForYouPosts(String currentUserId) async {
    _isLoadingNewForYou = true;
    notifyListeners();

    try {
      debugPrint('🆕 Loading $_forYouNewPostsCount new For You posts...');

      final newPostsWithAuthors = await getPersonalizedForYouFeed(currentUserId)
          .first
          .then((posts) => posts
              .where((p) => p.post.createdAt.isAfter(_forYouLastLoadedTime ??
                  DateTime.now().subtract(Duration(hours: 1))))
              .toList());

      // Initialize post states for new posts
      for (var postWithAuthor in newPostsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId),
        ]);
      }

      // Prepend new posts to top of feed
      _forYouPosts = [...newPostsWithAuthors, ..._forYouPosts];
      _forYouLastLoadedTime = DateTime.now();
      _forYouNewPostsCount = 0;

      debugPrint(
          '✅ Added ${newPostsWithAuthors.length} new posts to top of feed');
      _isLoadingNewForYou = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading new For You posts: $e');
      _isLoadingNewForYou = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Check for new posts since last load (Friends)
  Future<void> _checkForNewFriendsPosts(String currentUserId) async {
    if (_friendsLastLoadedTime == null) return;

    try {
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .get();

      final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      if (followingIds.isEmpty) return;

      int totalCount = 0;
      for (int i = 0; i < followingIds.length; i += 10) {
        final batch = followingIds.skip(i).take(10).toList();
        final query = _firestore
            .collection('posts')
            .where('userId', whereIn: batch)
            .where('createdAt', isGreaterThan: _friendsLastLoadedTime!)
            .count();
        final snapshot = await query.get();
        totalCount += (snapshot.count ?? 0);
      }

      _friendsNewPostsCount = totalCount;
      if (_friendsNewPostsCount > 0) {
        debugPrint('✨ Found $_friendsNewPostsCount new Friends posts');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking for new Friends posts: $e');
    }
  }

  // ✅ NEW: Load new posts and prepend to feed (Friends)
  Future<void> loadNewFriendsPosts(String currentUserId) async {
    _isLoadingNewFriends = true;
    notifyListeners();

    try {
      debugPrint('🆕 Loading $_friendsNewPostsCount new Friends posts...');

      final newPostsWithAuthors = await getFollowingFeed(currentUserId)
          .first
          .then((posts) => posts
              .where((p) => p.post.createdAt.isAfter(_friendsLastLoadedTime ??
                  DateTime.now().subtract(Duration(hours: 1))))
              .toList());

      // Initialize post states for new posts
      for (var postWithAuthor in newPostsWithAuthors) {
        await Future.wait([
          checkIfLiked(postWithAuthor.post.postId, currentUserId),
          checkIfBookmarked(postWithAuthor.post.postId, currentUserId),
          checkIfReposted(postWithAuthor.post.postId, currentUserId),
        ]);
      }

      // Prepend new posts to top of feed
      _friendsPosts = [...newPostsWithAuthors, ..._friendsPosts];
      _friendsLastLoadedTime = DateTime.now();
      _friendsNewPostsCount = 0;

      debugPrint(
          '✅ Added ${newPostsWithAuthors.length} new posts to top of feed');
      _isLoadingNewFriends = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading new Friends posts: $e');
      _isLoadingNewFriends = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Check for new posts since last load (Campus)
  Future<void> _checkForNewCampusPosts(String campus) async {
    if (_campusLastLoadedTime == null) return;

    try {
      final query = _firestore
          .collection('posts')
          .where('campus', isEqualTo: campus)
          .where('createdAt', isGreaterThan: _campusLastLoadedTime!)
          .count();

      final snapshot = await query.get();
      _campusNewPostsCount = snapshot.count ?? 0;

      if (_campusNewPostsCount > 0) {
        debugPrint('✨ Found $_campusNewPostsCount new Campus posts');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking for new Campus posts: $e');
    }
  }

  // ✅ NEW: Load new posts and prepend to feed (Campus)
  Future<void> loadNewCampusPosts(String campus) async {
    _isLoadingNewCampus = true;
    notifyListeners();

    try {
      debugPrint('🆕 Loading $_campusNewPostsCount new Campus posts...');

      final newPostsWithAuthors = await getCampusFeed(campus).first.then(
          (posts) => posts
              .where((p) => p.post.createdAt.isAfter(_campusLastLoadedTime ??
                  DateTime.now().subtract(Duration(hours: 1))))
              .toList());

      // Initialize post states for new posts (no userId needed for campus feed interaction check)
      for (var postWithAuthor in newPostsWithAuthors) {
        // Just create empty post state, actual init will happen in UI
        getOrCreatePostState(postWithAuthor.post.postId);
      }

      // Prepend new posts to top of feed
      _campusPosts = [...newPostsWithAuthors, ..._campusPosts];
      _campusLastLoadedTime = DateTime.now();
      _campusNewPostsCount = 0;

      debugPrint(
          '✅ Added ${newPostsWithAuthors.length} new posts to top of feed');
      _isLoadingNewCampus = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading new Campus posts: $e');
      _isLoadingNewCampus = false;
      notifyListeners();
    }
  }

  //  Force reload (useful after posting new content)
  void forceReloadForYou(String currentUserId) {
    _forYouLoaded = false;
    loadForYouFeed(currentUserId);
  }

  void forceReloadFriends(String currentUserId) {
    _friendsLoaded = false;
    loadFriendsFeed(currentUserId);
  }

  //  Force reload Campus feed
  void forceReloadCampus(String currentUserId, String campus) {
    _campusLoaded = false;
    loadCampusFeed(currentUserId, campus);
  }

  //  Invalidate cache (useful when user logs out or switches accounts)
  void invalidateCache() {
    _forYouLoaded = false;
    _friendsLoaded = false;
    _campusLoaded = false; //  Added
    _forYouPosts.clear();
    _friendsPosts.clear();
    _campusPosts.clear(); //  Added
    _userCache.clear();
    _posts.clear();
    _errorForYou = null;
    _errorFriends = null;
    _errorCampus = null; //  Added
    _isLoadingForYou = true;
    _isLoadingFriends = true;
    _isLoadingCampus = true; //  Added

    _forYouSubscription?.cancel();
    _friendsSubscription?.cancel();
    _campusSubscription?.cancel(); //  Added
    _forYouPollingSubscription?.cancel();
    _friendsPollingSubscription?.cancel();
    _campusPollingSubscription?.cancel();

    notifyListeners();
    debugPrint('🗑️ Feed cache invalidated');
  }

  // Fetch posts with author data
  Stream<List<PostWithAuthor>> getPostsWithAuthors() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_initialPageSize)
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
                _cacheUser(post.userId, author);
              }
            } catch (e) {
              debugPrint('Error fetching user ${post.userId}: $e');
            }
          }

          // Get counts from denormalized fields instead of subcollection queries
          final likesCount = postData.containsKey('likesCount')
              ? postData['likesCount'] ?? 0
              : 0;
          final bookmarksCount = postData.containsKey('bookmarksCount')
              ? postData['bookmarksCount'] ?? 0
              : 0;
          final commentsCount = postData.containsKey('commentsCount')
              ? postData['commentsCount'] ?? 0
              : 0;

          // Initialize post state if not exists (without notifying)
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
              repostsCount: post.shares, // Use post.shares for repost count
            );
          } else {
            // Update counts from Firestore (preserve like/bookmark/repost state)
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
            currentState.repostsCount = post.shares; //  Use post.shares
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

  Future<void> loadMoreForYouFeed(String currentUserId) async {
    if (_isLoadingMoreForYou || !_forYouHasMore) return;

    _isLoadingMoreForYou = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_forYouLastDoc != null) {
        query = query.startAfterDocument(_forYouLastDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _forYouHasMore = false;
      } else {
        _forYouLastDoc = snapshot.docs.last;
        for (final doc in snapshot.docs) {
          final postData = doc.data() as Map<String, dynamic>;
          final post = PostModel.fromMap(postData);
          UserModel? author = _userCache[post.userId];
          if (author == null) {
            final userDoc =
                await _firestore.collection('users').doc(post.userId).get();
            if (userDoc.exists && userDoc.data() != null) {
              author = UserModel.fromMap(userDoc.data()!);
              _cacheUser(post.userId, author);
            }
          }

          final likesCount = postData.containsKey('likesCount')
              ? postData['likesCount'] ?? 0
              : 0;
          final commentsCount = postData.containsKey('commentsCount')
              ? postData['commentsCount'] ?? 0
              : 0;
          final repostsCount = postData.containsKey('repostsCount')
              ? postData['repostsCount'] ?? 0
              : 0;
          final bookmarksCount = postData.containsKey('bookmarksCount')
              ? postData['bookmarksCount'] ?? 0
              : 0;

          await Future.wait([
            checkIfLiked(post.postId, currentUserId),
            checkIfBookmarked(post.postId, currentUserId),
            checkIfReposted(post.postId, currentUserId),
          ]);

          if (!_forYouPosts.any((p) => p.post.postId == post.postId)) {
            _forYouPosts.add(PostWithAuthor(
              post: post.copyWith(
                likes: likesCount,
                comments: commentsCount,
                repostsCount: repostsCount,
                bookmarksCount: bookmarksCount,
              ),
              author: author,
            ));
          }
        }

        _forYouHasMore = snapshot.docs.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error loading more For You posts: $e');
    }

    _isLoadingMoreForYou = false;
    notifyListeners();
  }

  Future<void> loadMoreFriendsFeed(String currentUserId) async {
    if (_isLoadingMoreFriends || !_friendsHasMore) return;

    _isLoadingMoreFriends = true;
    notifyListeners();

    try {
      final followingSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .get();

      final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      if (followingIds.isEmpty) {
        _friendsHasMore = false;
      } else {
        List<PostWithAuthor> newPosts = [];
        for (int i = 0; i < followingIds.length; i += 10) {
          final batch = followingIds.skip(i).take(10).toList();
          Query query = _firestore
              .collection('posts')
              .where('userId', whereIn: batch)
              .orderBy('createdAt', descending: true)
              .limit(_pageSize);

          if (_friendsLastDoc != null) {
            query = query.startAfterDocument(_friendsLastDoc!);
          }

          final snapshot = await query.get();
          if (snapshot.docs.isNotEmpty) {
            _friendsLastDoc = snapshot.docs.last;
            for (final doc in snapshot.docs) {
              final post =
                  PostModel.fromMap(doc.data() as Map<String, dynamic>);
              UserModel? author = _userCache[post.userId];
              if (author == null) {
                final authorDoc =
                    await _firestore.collection('users').doc(post.userId).get();
                if (authorDoc.exists && authorDoc.data() != null) {
                  author = UserModel.fromMap(authorDoc.data()!);
                  _cacheUser(post.userId, author);
                }
              }
              if (!_friendsPosts.any((p) => p.post.postId == post.postId)) {
                newPosts.add(PostWithAuthor(post: post, author: author));
              }
            }
          }
        }

        if (newPosts.isEmpty) {
          _friendsHasMore = false;
        } else {
          _friendsPosts.addAll(newPosts);
        }
      }
    } catch (e) {
      debugPrint('Error loading more Friends posts: $e');
    }

    _isLoadingMoreFriends = false;
    notifyListeners();
  }

  Future<void> loadMoreCampusFeed(String campus) async {
    if (_isLoadingMoreCampus || !_campusHasMore) return;

    _isLoadingMoreCampus = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('posts')
          .where('campus', isEqualTo: campus)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_campusLastDoc != null) {
        query = query.startAfterDocument(_campusLastDoc!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _campusHasMore = false;
      } else {
        _campusLastDoc = snapshot.docs.last;
        for (final doc in snapshot.docs) {
          final post = PostModel.fromMap(doc.data() as Map<String, dynamic>);
          UserModel? author = _userCache[post.userId];
          if (author == null) {
            final userDoc =
                await _firestore.collection('users').doc(post.userId).get();
            if (userDoc.exists && userDoc.data() != null) {
              author = UserModel.fromMap(userDoc.data()!);
              _cacheUser(post.userId, author);
            }
          }
          if (!_campusPosts.any((p) => p.post.postId == post.postId)) {
            _campusPosts.add(PostWithAuthor(post: post, author: author));
          }
        }

        _campusHasMore = snapshot.docs.length >= _pageSize;
      }
    } catch (e) {
      debugPrint('Error loading more Campus posts: $e');
    }

    _isLoadingMoreCampus = false;
    notifyListeners();
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
            .limit(_initialPageSize)
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
            int repostsCount = 0; //  NEW

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
                    .get(), //  NEW
              ]);

              likesCount = counts[0].count ?? 0;
              bookmarksCount = counts[1].count ?? 0;
              commentsCount = counts[2].count ?? 0;
              repostsCount = counts[3].count ?? 0; //  NEW
            } catch (e) {
              debugPrint('Error getting counts for ${post.postId}: $e');
            }

            // Initialize post state
            if (!_posts.containsKey(post.postId)) {
              _posts[post.postId] = PostState(
                likesCount: likesCount,
                bookmarksCount: bookmarksCount,
                repliesCount: commentsCount,
                repostsCount: repostsCount, //  NEW
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
        .limit(_initialPageSize)
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
                _cacheUser(post.userId, author);
              }
            } catch (e) {
              debugPrint('Error fetching user ${post.userId}: $e');
            }
          }

          // Get counts from denormalized fields instead of subcollection queries
          final likesCount = postData.containsKey('likesCount')
              ? postData['likesCount'] ?? 0
              : 0;
          final bookmarksCount = postData.containsKey('bookmarksCount')
              ? postData['bookmarksCount'] ?? 0
              : 0;
          final commentsCount = postData.containsKey('commentsCount')
              ? postData['commentsCount'] ?? 0
              : 0;
          final repostsCount = postData.containsKey('repostsCount')
              ? postData['repostsCount'] ?? 0
              : 0;

          // Initialize or update post state
          if (!_posts.containsKey(post.postId)) {
            _posts[post.postId] = PostState(
              likesCount: likesCount,
              bookmarksCount: bookmarksCount,
              repliesCount: commentsCount,
              repostsCount: repostsCount, //  NEW
            );
          } else {
            final currentState = _posts[post.postId]!;
            currentState.likesCount = likesCount;
            currentState.bookmarksCount = bookmarksCount;
            currentState.repliesCount = commentsCount;
            currentState.repostsCount = repostsCount; //  NEW
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
    return super.checkIfLiked(postId, userId);
  }

  // Check if current user bookmarked a post
  Future<bool> checkIfBookmarked(String postId, String userId) async {
    return super.checkIfBookmarked(postId, userId);
  }

  //  NEW: Check if current user reposted a post
  Future<bool> checkIfReposted(String postId, String userId) async {
    return super.checkIfReposted(postId, userId);
  }

  // Update like state with optimistic updates
  Future<void> toggleLike(
    String postId,
    String userId,
    String postAuthorId,
    NotifyProvider notifyProvider,
    UserModel? currentUser,
    String? postImageUrl,
  ) async {
    await super.toggleLikeInteraction(
      postId: postId,
      userId: userId,
      postAuthorId: postAuthorId,
      notifyProvider: notifyProvider,
      currentUser: currentUser,
      postImageUrl: postImageUrl,
      onLikeCompleted: () async {
        // Get post to extract tags
        final post = _forYouPosts.firstWhere(
          (p) => p.post.postId == postId,
          orElse: () => _friendsPosts.firstWhere(
            (p) => p.post.postId == postId,
            orElse: () => _campusPosts.firstWhere(
              (p) => p.post.postId == postId,
              orElse: () => PostWithAuthor(
                post: PostModel(
                  postId: '',
                  userId: '',
                  username: '',
                  userProfileImage: '',
                  content: '',
                  imageUrls: [],
                  likes: 0,
                  comments: 0,
                  shares: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          ),
        );

        if (post.post.postId.isNotEmpty) {
          // Track author engagement
          _engagementService.trackEngagedAuthor(userId, postAuthorId);

          // Track tag engagement
          final tags = post.post.tags.isNotEmpty
              ? post.post.tags
              : PostTaggingService.extractTags(post.post.content);
          if (tags.isNotEmpty) {
            _engagementService.trackEngagedTags(userId, tags);
          }

          // Track campus if available
          if (post.post.campus != null) {
            _engagementService.trackViewedCampus(userId, post.post.campus!);
          }
        }
      },
    );
  }

  // Update bookmark state with optimistic updates
  Future<void> toggleBookmark(String postId, String userId) async {
    await super.toggleBookmarkInteraction(postId: postId, userId: userId);
  }

  //  NEW: Toggle repost with optimistic updates
  Future<void> toggleRepost(String postId, String userId) async {
    await super.toggleRepostInteraction(postId: postId, userId: userId);
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
    _forYouPollingSubscription?.cancel();
    _friendsPollingSubscription?.cancel();
    _campusPollingSubscription?.cancel();
    super.dispose();
  }
}

//  UPDATED: PostState with repost support
class PostState implements PostInteractionState {
  int likesCount;
  int bookmarksCount;
  int repliesCount;
  int repostsCount; //  NEW
  bool isLiked;
  bool isBookmarked;
  bool isReposted; //  NEW

  PostState({
    this.likesCount = 0,
    this.bookmarksCount = 0,
    this.repliesCount = 0,
    this.repostsCount = 0, //  NEW
    this.isLiked = false,
    this.isBookmarked = false,
    this.isReposted = false, //  NEW
  });
}
