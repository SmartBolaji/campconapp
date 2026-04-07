import 'dart:math' as math;
import 'package:campcon/main/provider/post_interaction_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:campcon/main/models/post_with_author_model.dart';
import 'package:campcon/main/services/algorithm/user_engagement_service.dart';

/// Service to score and rank posts based on user preferences and engagement
class PostScoringService {
  static const double _recencyWeight = 0.65; // 65% - Recency is paramount
  static const double _engagementWeight = 0.20; // 20%
  static const double _personalizationWeight = 0.15; // 15%
  static const int _scoreDecayHours = 168; // 1 week

  /// Score and sort posts based on user preferences
  /// Prioritizes fresh posts while rewarding engagement
  /// Penalizes posts the user has already interacted with (liked, bookmarked, etc.)
  List<PostWithAuthor> scoreAndSortPosts(
    List<PostWithAuthor> posts,
    String currentUserId,
    UserPersonalizationData? personalizationData, {
    required Map<String, PostInteractionState> postStates,
  }) {
    if (personalizationData == null) return posts;

    final now = DateTime.now();

    final scoredPosts = posts.map((postWithAuthor) {
      final score = _scorePost(
        postWithAuthor,
        now,
        personalizationData,
        postStates,
      );
      return _ScoredPost(postWithAuthor, score);
    }).toList();

    // Sort by score (highest first), then by date for equal scores
    scoredPosts.sort((a, b) {
      final compare = b.score.compareTo(a.score);
      if (compare != 0) return compare;
      return b.post.post.createdAt.compareTo(a.post.post.createdAt);
    });

    debugPrint(
      '📊 PostScoringService: Scored ${scoredPosts.length} posts. Top 3 scores: '
      '${scoredPosts.take(3).map((s) => s.score.toStringAsFixed(2)).join(", ")}',
    );

    return scoredPosts.map((s) => s.post).toList();
  }

  /// Calculate engagement score (0-1)
  double _getEngagementScore(PostWithAuthor postWithAuthor) {
    final post = postWithAuthor.post;
    final totalEngagement = (post.likesCount) +
        ((post.commentsCount) * 2) +
        ((post.repostsCount) * 3) +
        ((post.bookmarksCount) * 1.5);

    // Normalize to 0-1 using logarithmic scale
    // Assume 50 interactions is excellent, 10 is good
    return (_naturalLog(math.max(totalEngagement + 1, 1)) / _naturalLog(50))
        .clamp(0.0, 1.0);
  }

  /// Calculate recency score (0-1) with time decay
  double _getRecencyScore(PostWithAuthor postWithAuthor, DateTime now) {
    final post = postWithAuthor.post;
    final hoursSincePost = now.difference(post.createdAt).inHours;

    // Linear decay over _scoreDecayHours
    if (hoursSincePost >= _scoreDecayHours) return 0.0;
    return 1.0 - (hoursSincePost / _scoreDecayHours);
  }

  /// Calculate personalization score (0-1)
  double _getPersonalizationScore(
    PostWithAuthor postWithAuthor,
    UserPersonalizationData personalizationData,
  ) {
    final post = postWithAuthor.post;
    var score = 0.0;

    // Tag matching (40% of personalization score)
    if (post.tags.isNotEmpty) {
      final matchedTags = post.tags
          .where((tag) => personalizationData.allRelevantTags.contains(tag))
          .length;
      score += (matchedTags / post.tags.length) * 0.4;
    }

    // Author matching (30% of personalization score)
    if (postWithAuthor.author?.uid != null &&
        personalizationData.engagedAuthors
            .contains(postWithAuthor.author!.uid)) {
      score += 0.3;
    }

    // Campus matching (30% of personalization score)
    if (post.campus != null &&
        personalizationData.viewedCampuses.contains(post.campus)) {
      score += 0.3;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Calculate final score for a post
  double _scorePost(
    PostWithAuthor postWithAuthor,
    DateTime now,
    UserPersonalizationData personalizationData,
    Map<String, PostInteractionState> postStates,
  ) {
    final engagement = _getEngagementScore(postWithAuthor);
    final recency = _getRecencyScore(postWithAuthor, now);
    final personalization = _getPersonalizationScore(
      postWithAuthor,
      personalizationData,
    );

    // Check if user has already interacted with this post
    final postState = postStates[postWithAuthor.post.postId];
    final hasInteracted = postState != null &&
        (postState.isLiked || postState.isBookmarked || postState.isReposted);

    // Weighted combination
    var finalScore = (recency * _recencyWeight) +
        (engagement * _engagementWeight) +
        (personalization * _personalizationWeight);

    // Penalize posts user has already interacted with (massive penalty to push down)
    if (hasInteracted) {
      finalScore *= 0.3; // Reduce score to 30% of original value
      debugPrint(
        '⬇️ Post ${postWithAuthor.post.postId} penalized (user already interacted). Score: $finalScore',
      );
    }

    debugPrint(
      '📈 Post ${postWithAuthor.post.postId}: '
      'recency=$recency, engagement=$engagement, personalization=$personalization, '
      'hasInteracted=$hasInteracted, final=$finalScore',
    );

    return finalScore;
  }
}

/// Helper class for scoring posts
class _ScoredPost {
  final PostWithAuthor post;
  final double score;

  _ScoredPost(this.post, this.score);
}

// Natural logarithm helper
double _naturalLog(double x) {
  return math.log(x) / math.log(2.718281828459045);
}
