import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to track and manage user engagement for personalized feeds.
/// Maintains lists with max 30 items each - newer items replace older ones.
class UserEngagementService {
  static const int maxListSize = 30;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add tags to user's engaged tags (from liked/commented posts)
  Future<void> trackEngagedTags(String userId, List<String> tags) async {
    if (userId.isEmpty || tags.isEmpty) return;

    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<String> currentTags =
            List<String>.from(userDoc.data()?['engagedTags'] ?? []);

        // Add new tags at the beginning (most recent first)
        for (final tag in tags) {
          // Remove if already exists to move to front
          currentTags.remove(tag);
          currentTags.insert(0, tag);
        }

        // Trim to max size
        if (currentTags.length > maxListSize) {
          currentTags = currentTags.sublist(0, maxListSize);
        }

        transaction.update(userRef, {'engagedTags': currentTags});
      });

      debugPrint('✅ Tracked engaged tags: $tags');
    } catch (e) {
      debugPrint('❌ Error tracking engaged tags: $e');
    }
  }

  /// Add author to user's engaged authors (from liked/commented posts)
  Future<void> trackEngagedAuthor(String userId, String authorId) async {
    if (userId.isEmpty || authorId.isEmpty || userId == authorId) return;

    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<String> currentAuthors =
            List<String>.from(userDoc.data()?['engagedAuthors'] ?? []);

        // Remove if already exists to move to front
        currentAuthors.remove(authorId);
        currentAuthors.insert(0, authorId);

        // Trim to max size
        if (currentAuthors.length > maxListSize) {
          currentAuthors = currentAuthors.sublist(0, maxListSize);
        }

        transaction.update(userRef, {'engagedAuthors': currentAuthors});
      });

      debugPrint('✅ Tracked engaged author: $authorId');
    } catch (e) {
      debugPrint('❌ Error tracking engaged author: $e');
    }
  }

  /// Add search term to user's search history
  Future<void> trackSearchTerm(String userId, String searchTerm) async {
    if (userId.isEmpty || searchTerm.trim().isEmpty) return;

    final term = searchTerm.trim().toLowerCase();

    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<String> currentHistory =
            List<String>.from(userDoc.data()?['searchHistory'] ?? []);

        // Remove if already exists to move to front
        currentHistory.remove(term);
        currentHistory.insert(0, term);

        // Trim to max size
        if (currentHistory.length > maxListSize) {
          currentHistory = currentHistory.sublist(0, maxListSize);
        }

        transaction.update(userRef, {'searchHistory': currentHistory});
      });

      debugPrint('✅ Tracked search term: $term');
    } catch (e) {
      debugPrint('❌ Error tracking search term: $e');
    }
  }

  /// Add campus to user's viewed campuses
  Future<void> trackViewedCampus(String userId, String campus) async {
    if (userId.isEmpty || campus.trim().isEmpty) return;

    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) return;

        List<String> currentCampuses =
            List<String>.from(userDoc.data()?['viewedCampuses'] ?? []);

        // Remove if already exists to move to front
        currentCampuses.remove(campus);
        currentCampuses.insert(0, campus);

        // Trim to max size
        if (currentCampuses.length > maxListSize) {
          currentCampuses = currentCampuses.sublist(0, maxListSize);
        }

        transaction.update(userRef, {'viewedCampuses': currentCampuses});
      });

      debugPrint('✅ Tracked viewed campus: $campus');
    } catch (e) {
      debugPrint('❌ Error tracking viewed campus: $e');
    }
  }

  /// Get user's personalization data for feed algorithm
  Future<UserPersonalizationData?> getPersonalizationData(String userId) async {
    if (userId.isEmpty) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data()!;
      return UserPersonalizationData(
        interests: List<String>.from(data['interests'] ?? []),
        engagedTags: List<String>.from(data['engagedTags'] ?? []),
        engagedAuthors: List<String>.from(data['engagedAuthors'] ?? []),
        searchHistory: List<String>.from(data['searchHistory'] ?? []),
        viewedCampuses: List<String>.from(data['viewedCampuses'] ?? []),
        campus: data['campus'],
        school: data['school'],
        level: data['level'],
        department: data['department'],
      );
    } catch (e) {
      debugPrint('❌ Error getting personalization data: $e');
      return null;
    }
  }

  /// Extract tags from post content using keyword matching
  static List<String> extractTagsFromContent(
      String content, List<String> availableTags) {
    final contentLower = content.toLowerCase();
    final extractedTags = <String>[];

    for (final tag in availableTags) {
      if (contentLower.contains(tag.toLowerCase())) {
        extractedTags.add(tag);
      }
    }

    return extractedTags;
  }
}

/// Data class for user personalization preferences
class UserPersonalizationData {
  final List<String> interests;
  final List<String> engagedTags;
  final List<String> engagedAuthors;
  final List<String> searchHistory;
  final List<String> viewedCampuses;
  final String? campus;
  final String? school;
  final String? level;
  final String? department;

  UserPersonalizationData({
    required this.interests,
    required this.engagedTags,
    required this.engagedAuthors,
    required this.searchHistory,
    required this.viewedCampuses,
    this.campus,
    this.school,
    this.level,
    this.department,
  });

  /// Get all relevant tags for querying (combined and deduplicated)
  List<String> get allRelevantTags {
    final allTags = <String>{};
    allTags.addAll(interests);
    allTags.addAll(engagedTags);
    // Add search terms that match known categories
    allTags.addAll(searchHistory.take(10)); // Only recent searches
    return allTags.toList();
  }

  /// Check if user has enough data for personalization
  bool get hasPersonalizationData {
    return interests.isNotEmpty ||
        engagedTags.isNotEmpty ||
        engagedAuthors.isNotEmpty;
  }
}
