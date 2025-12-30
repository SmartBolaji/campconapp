import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Profile state
  UserModel? _profileUser;
  bool _isLoading = true;
  String? _errorMessage;

  // Follow state
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  // Bio state
  bool _isBioExpanded = false;
  bool _isBioLong = false;

  // Current user ID (for comparison)
  String? _currentUserId;

  // ========== Posts Tab State ==========
  List<PostWithAuthorProfile> _userPosts = [];
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;
  DocumentSnapshot? _lastPostDoc;
  static const int _postsPageSize = 10;

  // ========== Reposts Tab State ==========
  List<PostWithAuthorProfile> _userReposts = [];
  bool _isLoadingReposts = false;
  bool _hasMoreReposts = true;
  DocumentSnapshot? _lastRepostDoc;

  // ========== Media Tab State ==========
  List<PostWithAuthorProfile> _userMedia = [];
  bool _isLoadingMedia = false;
  bool _hasMoreMedia = true;
  DocumentSnapshot? _lastMediaDoc;

  // ========== Saved Tab State ==========
  List<PostWithAuthorProfile> _savedPosts = [];
  bool _isLoadingSaved = false;
  bool _hasMoreSaved = true;
  DocumentSnapshot? _lastSavedDoc;

  // ========== Post States (for likes, bookmarks) ==========
  final Map<String, ProfilePostState> _postStates = {};

  // Getters
  UserModel? get profileUser => _profileUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  bool get isFollowing => _isFollowing;
  bool get isFollowLoading => _isFollowLoading;
  bool get isBioExpanded => _isBioExpanded;
  bool get isBioLong => _isBioLong;

  // Posts getters
  List<PostWithAuthorProfile> get userPosts => _userPosts;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get hasMorePosts => _hasMorePosts;

  // Reposts getters
  List<PostWithAuthorProfile> get userReposts => _userReposts;
  bool get isLoadingReposts => _isLoadingReposts;
  bool get hasMoreReposts => _hasMoreReposts;

  // Media getters
  List<PostWithAuthorProfile> get userMedia => _userMedia;
  bool get isLoadingMedia => _isLoadingMedia;
  bool get hasMoreMedia => _hasMoreMedia;

  // Saved getters
  List<PostWithAuthorProfile> get savedPosts => _savedPosts;
  bool get isLoadingSaved => _isLoadingSaved;
  bool get hasMoreSaved => _hasMoreSaved;

  bool get isCurrentUser =>
      _currentUserId != null &&
      _profileUser != null &&
      _currentUserId == _profileUser!.uid;

  /// Check if user has a bio
  bool get hasBio =>
      _profileUser != null &&
      _profileUser!.aboutMe != null &&
      _profileUser!.aboutMe!.isNotEmpty;

  /// Get post state
  ProfilePostState getPostState(String postId) {
    if (!_postStates.containsKey(postId)) {
      _postStates[postId] = ProfilePostState();
    }
    return _postStates[postId]!;
  }

  /// Initialize profile with optional initial data
  void initProfile({
    UserModel? initialUserData,
    required String? currentUserId,
  }) {
    _currentUserId = currentUserId;

    if (initialUserData != null) {
      _profileUser = initialUserData;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile
  Future<void> loadUserProfile({
    String? userId,
    UserModel? initialUserData,
    required String? currentUserId,
    required FollowProvider followProvider,
  }) async {
    _currentUserId = currentUserId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String targetUserId =
          userId ?? initialUserData?.uid ?? currentUserId ?? '';

      if (targetUserId.isEmpty) {
        _errorMessage = 'User not logged in or ID not provided.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Determine if we need to fetch from Firestore
      bool needsFetch =
          initialUserData == null || targetUserId == currentUserId;

      if (needsFetch) {
        if (targetUserId == currentUserId && initialUserData != null) {
          _profileUser = initialUserData;
        } else if (targetUserId != currentUserId && initialUserData != null) {
          _profileUser = initialUserData;
        } else {
          // Fetch from Firestore
          DocumentSnapshot doc =
              await _firestore.collection('users').doc(targetUserId).get();

          if (doc.exists && doc.data() != null) {
            _profileUser =
                UserModel.fromMap(doc.data() as Map<String, dynamic>);
          } else {
            _errorMessage = 'User profile not found.';
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      } else {
        _profileUser = initialUserData;
      }

      // Load follow counts
      final counts = await followProvider.getFollowCounts(targetUserId);
      _followersCount = counts['followers']!;
      _followingCount = counts['following']!;

      // Check if current user follows this profile
      if (targetUserId != currentUserId && currentUserId != null) {
        _isFollowing = await followProvider.checkIfFollowing(
          currentUserId,
          targetUserId,
        );
      }

      _isLoading = false;
      notifyListeners();

      // Load initial posts
      loadUserPosts();
    } catch (e) {
      _errorMessage = 'Error loading profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== POSTS TAB ==========
  Future<void> loadUserPosts({bool refresh = false}) async {
    if (_profileUser == null) return;
    if (_isLoadingPosts && !refresh) return;
    if (!_hasMorePosts && !refresh) return;

    if (refresh) {
      _userPosts.clear();
      _lastPostDoc = null;
      _hasMorePosts = true;
    }

    _isLoadingPosts = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('posts')
          .where('userId', isEqualTo: _profileUser!.uid)
          .orderBy('createdAt', descending: true)
          .limit(_postsPageSize);

      if (_lastPostDoc != null) {
        query = query.startAfterDocument(_lastPostDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMorePosts = false;
      } else {
        _lastPostDoc = snapshot.docs.last;

        for (var doc in snapshot.docs) {
          final post = PostModel.fromMap(doc.data() as Map<String, dynamic>);

          // Initialize post state
          await _initializePostState(post.postId);

          _userPosts.add(PostWithAuthorProfile(
            post: post,
            author: _profileUser,
          ));
        }

        if (snapshot.docs.length < _postsPageSize) {
          _hasMorePosts = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading user posts: $e');
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  // ========== REPOSTS TAB ==========
  Future<void> loadUserReposts({bool refresh = false}) async {
    if (_profileUser == null) return;
    if (_isLoadingReposts && !refresh) return;
    if (!_hasMoreReposts && !refresh) return;

    if (refresh) {
      _userReposts.clear();
      _lastRepostDoc = null;
      _hasMoreReposts = true;
    }

    _isLoadingReposts = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('users')
          .doc(_profileUser!.uid)
          .collection('reposts')
          .orderBy('timestamp', descending: true)
          .limit(_postsPageSize);

      if (_lastRepostDoc != null) {
        query = query.startAfterDocument(_lastRepostDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreReposts = false;
      } else {
        _lastRepostDoc = snapshot.docs.last;

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final postRef = data['postRef'] as DocumentReference?;

          if (postRef != null) {
            final postDoc = await postRef.get();
            if (postDoc.exists) {
              final post =
                  PostModel.fromMap(postDoc.data() as Map<String, dynamic>);

              // Get original author
              UserModel? author;
              if (post.userId != _profileUser!.uid) {
                final authorDoc =
                    await _firestore.collection('users').doc(post.userId).get();
                if (authorDoc.exists) {
                  author = UserModel.fromMap(
                      authorDoc.data() as Map<String, dynamic>);
                }
              } else {
                author = _profileUser;
              }

              await _initializePostState(post.postId);

              _userReposts.add(PostWithAuthorProfile(
                post: post,
                author: author,
                repostedBy: _profileUser,
              ));
            }
          }
        }

        if (snapshot.docs.length < _postsPageSize) {
          _hasMoreReposts = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading user reposts: $e');
    }

    _isLoadingReposts = false;
    notifyListeners();
  }

  // ========== MEDIA TAB ==========
  Future<void> loadUserMedia({bool refresh = false}) async {
    if (_profileUser == null) return;
    if (_isLoadingMedia && !refresh) return;
    if (!_hasMoreMedia && !refresh) return;

    if (refresh) {
      _userMedia.clear();
      _lastMediaDoc = null;
      _hasMoreMedia = true;
    }

    _isLoadingMedia = true;
    notifyListeners();

    try {
      // Get posts with images
      Query query = _firestore
          .collection('posts')
          .where('userId', isEqualTo: _profileUser!.uid)
          .orderBy('createdAt', descending: true)
          .limit(_postsPageSize * 2); // Fetch more since we filter

      if (_lastMediaDoc != null) {
        query = query.startAfterDocument(_lastMediaDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreMedia = false;
      } else {
        _lastMediaDoc = snapshot.docs.last;

        int addedCount = 0;
        for (var doc in snapshot.docs) {
          final post = PostModel.fromMap(doc.data() as Map<String, dynamic>);

          // Only include posts with images
          if (post.imageUrls.isNotEmpty) {
            await _initializePostState(post.postId);

            _userMedia.add(PostWithAuthorProfile(
              post: post,
              author: _profileUser,
            ));
            addedCount++;
          }
        }

        if (snapshot.docs.length < _postsPageSize * 2 || addedCount == 0) {
          _hasMoreMedia = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading user media: $e');
    }

    _isLoadingMedia = false;
    notifyListeners();
  }

  // ========== SAVED TAB ==========
  Future<void> loadSavedPosts({bool refresh = false}) async {
    if (_profileUser == null) return;
    // Only current user can see their saved posts
    if (!isCurrentUser) return;
    if (_isLoadingSaved && !refresh) return;
    if (!_hasMoreSaved && !refresh) return;

    if (refresh) {
      _savedPosts.clear();
      _lastSavedDoc = null;
      _hasMoreSaved = true;
    }

    _isLoadingSaved = true;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('users')
          .doc(_profileUser!.uid)
          .collection('bookmarks')
          .orderBy('timestamp', descending: true)
          .limit(_postsPageSize);

      if (_lastSavedDoc != null) {
        query = query.startAfterDocument(_lastSavedDoc!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreSaved = false;
      } else {
        _lastSavedDoc = snapshot.docs.last;

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final postRef = data['postRef'] as DocumentReference?;

          if (postRef != null) {
            final postDoc = await postRef.get();
            if (postDoc.exists) {
              final post =
                  PostModel.fromMap(postDoc.data() as Map<String, dynamic>);

              // Get author
              UserModel? author;
              final authorDoc =
                  await _firestore.collection('users').doc(post.userId).get();
              if (authorDoc.exists) {
                author =
                    UserModel.fromMap(authorDoc.data() as Map<String, dynamic>);
              }

              await _initializePostState(post.postId);

              _savedPosts.add(PostWithAuthorProfile(
                post: post,
                author: author,
              ));
            }
          }
        }

        if (snapshot.docs.length < _postsPageSize) {
          _hasMoreSaved = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading saved posts: $e');
    }

    _isLoadingSaved = false;
    notifyListeners();
  }

  // ========== POST STATE MANAGEMENT ==========
  Future<void> _initializePostState(String postId) async {
    if (_currentUserId == null) return;

    try {
      // Check if liked
      final likeDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(_currentUserId)
          .get();

      // Check if bookmarked
      final bookmarkDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(_currentUserId)
          .get();

      // Check if reposted
      final repostDoc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('reposts')
          .doc(postId)
          .get();

      // Get counts
      final likesSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .count()
          .get();

      final commentsSnapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .count()
          .get();

      // Get post for shares/reposts count
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final repostsCount = postDoc.data()?['shares'] ?? 0;

      _postStates[postId] = ProfilePostState(
        likesCount: likesSnapshot.count ?? 0,
        repliesCount: commentsSnapshot.count ?? 0,
        repostsCount: repostsCount,
        isLiked: likeDoc.exists,
        isBookmarked: bookmarkDoc.exists,
        isReposted: repostDoc.exists,
      );
    } catch (e) {
      debugPrint('Error initializing post state: $e');
      _postStates[postId] = ProfilePostState();
    }
  }

  /// Toggle like
  Future<void> toggleLike(String postId, String postOwnerId) async {
    if (_currentUserId == null) return;

    final state = getPostState(postId);
    final wasLiked = state.isLiked;

    // Optimistic update
    state.isLiked = !wasLiked;
    state.likesCount =
        (state.likesCount + (wasLiked ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final likeDoc = _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(_currentUserId);

      if (wasLiked) {
        await likeDoc.delete();
      } else {
        await likeDoc.set({
          'likedBy': _firestore.collection('users').doc(_currentUserId),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Revert on error
      state.isLiked = wasLiked;
      state.likesCount =
          (state.likesCount + (wasLiked ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('Error toggling like: $e');
    }
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(String postId) async {
    if (_currentUserId == null) return;

    final state = getPostState(postId);
    final wasBookmarked = state.isBookmarked;

    // Optimistic update
    state.isBookmarked = !wasBookmarked;
    notifyListeners();

    try {
      final bookmarkDoc = _firestore
          .collection('posts')
          .doc(postId)
          .collection('bookmarks')
          .doc(_currentUserId);

      final userBookmarkDoc = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('bookmarks')
          .doc(postId);

      if (wasBookmarked) {
        await bookmarkDoc.delete();
        await userBookmarkDoc.delete();
      } else {
        await bookmarkDoc.set({
          'bookmarkedby': _firestore.collection('users').doc(_currentUserId),
          'timestamp': FieldValue.serverTimestamp(),
        });
        await userBookmarkDoc.set({
          'postRef': _firestore.collection('posts').doc(postId),
          'type': 'media',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Revert on error
      state.isBookmarked = wasBookmarked;
      notifyListeners();
      debugPrint('Error toggling bookmark: $e');
    }
  }

  /// Toggle repost
  Future<void> toggleRepost(String postId) async {
    if (_currentUserId == null) return;

    final state = getPostState(postId);
    final wasReposted = state.isReposted;

    // Optimistic update
    state.isReposted = !wasReposted;
    state.repostsCount =
        (state.repostsCount + (wasReposted ? -1 : 1)).clamp(0, 999999999);
    notifyListeners();

    try {
      final userRepostDoc = _firestore
          .collection('users')
          .doc(_currentUserId)
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
      state.isReposted = wasReposted;
      state.repostsCount =
          (state.repostsCount + (wasReposted ? 1 : -1)).clamp(0, 999999999);
      notifyListeners();
      debugPrint('Error toggling repost: $e');
    }
  }

  /// Refresh profile (for pull-to-refresh or after edit)
  Future<void> refreshProfile({
    required FollowProvider followProvider,
    UserModel? updatedCurrentUser,
  }) async {
    if (_profileUser == null) return;

    if (isCurrentUser && updatedCurrentUser != null) {
      _profileUser = updatedCurrentUser;
      notifyListeners();
    }

    final counts = await followProvider.getFollowCounts(_profileUser!.uid);
    _followersCount = counts['followers']!;
    _followingCount = counts['following']!;
    notifyListeners();
  }

  /// Toggle follow/unfollow
  Future<void> toggleFollow({
    required FollowProvider followProvider,
  }) async {
    if (_currentUserId == null || _profileUser == null) return;
    if (_isFollowLoading) return;

    _isFollowLoading = true;
    notifyListeners();

    final success = await followProvider.toggleFollow(
      _currentUserId!,
      _profileUser!.uid,
    );

    if (success) {
      _isFollowing = !_isFollowing;
      _followersCount += _isFollowing ? 1 : -1;
    }

    _isFollowLoading = false;
    notifyListeners();
  }

  /// Set bio length state
  void setBioLong(bool isLong) {
    if (_isBioLong != isLong) {
      _isBioLong = isLong;
      notifyListeners();
    }
  }

  /// Toggle bio expanded state
  void toggleBioExpanded() {
    _isBioExpanded = !_isBioExpanded;
    notifyListeners();
  }

  /// Clear profile state
  void clearProfile() {
    _profileUser = null;
    _isLoading = true;
    _errorMessage = null;
    _followersCount = 0;
    _followingCount = 0;
    _isFollowing = false;
    _isFollowLoading = false;
    _isBioExpanded = false;
    _isBioLong = false;
    _currentUserId = null;

    // Clear posts state
    _userPosts.clear();
    _isLoadingPosts = false;
    _hasMorePosts = true;
    _lastPostDoc = null;

    // Clear reposts state
    _userReposts.clear();
    _isLoadingReposts = false;
    _hasMoreReposts = true;
    _lastRepostDoc = null;

    // Clear media state
    _userMedia.clear();
    _isLoadingMedia = false;
    _hasMoreMedia = true;
    _lastMediaDoc = null;

    // Clear saved state
    _savedPosts.clear();
    _isLoadingSaved = false;
    _hasMoreSaved = true;
    _lastSavedDoc = null;

    // Clear post states
    _postStates.clear();
  }

  /// Update profile user
  void updateProfileUser(UserModel user) {
    _profileUser = user;
    notifyListeners();
  }
}

// ========== HELPER CLASSES ==========
class PostWithAuthorProfile {
  final PostModel post;
  final UserModel? author;
  final UserModel? repostedBy; // For reposts

  PostWithAuthorProfile({
    required this.post,
    this.author,
    this.repostedBy,
  });
}

class ProfilePostState {
  int likesCount;
  int repliesCount;
  int repostsCount; // ✅ NEW
  bool isLiked;
  bool isBookmarked;
  bool isReposted; // ✅ NEW

  ProfilePostState({
    this.likesCount = 0,
    this.repliesCount = 0,
    this.repostsCount = 0, // ✅ NEW
    this.isLiked = false,
    this.isBookmarked = false,
    this.isReposted = false, // ✅ NEW
  });
}
