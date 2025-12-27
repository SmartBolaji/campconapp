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

  bool get isCurrentUser =>
      _currentUserId != null &&
      _profileUser != null &&
      _currentUserId == _profileUser!.uid;

  /// Check if user has a bio
  bool get hasBio =>
      _profileUser != null &&
      _profileUser!.aboutMe != null &&
      _profileUser!.aboutMe!.isNotEmpty;

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
          // Use current user data from auth provider
          _profileUser = initialUserData;
        } else if (targetUserId != currentUserId && initialUserData != null) {
          // Use provided initial data for other users
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
    } catch (e) {
      _errorMessage = 'Error loading profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh profile (for pull-to-refresh or after edit)
  Future<void> refreshProfile({
    required FollowProvider followProvider,
    UserModel? updatedCurrentUser,
  }) async {
    if (_profileUser == null) return;

    // If viewing own profile and updated user provided, use it
    if (isCurrentUser && updatedCurrentUser != null) {
      _profileUser = updatedCurrentUser;
      notifyListeners();
    }

    // Refresh follow counts
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

  /// Set bio length state (called from UI after measuring)
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

  /// Clear profile state (call when disposing)
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
    // Don't call notifyListeners here as widget might be disposed
  }

  /// Update profile user (after edit)
  void updateProfileUser(UserModel user) {
    _profileUser = user;
    notifyListeners();
  }
}
