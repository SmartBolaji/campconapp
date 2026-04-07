import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campcon/main/models/poll_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String userProfileImage;
  final String content;
  final List<String> imageUrls;
  final int likes;
  final int comments;
  final int shares;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int bookmarksCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? campus;
  final List<String> tags;
  final PollModel? poll;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.content,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    required this.shares,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.bookmarksCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.campus,
    this.tags = const [],
    this.poll,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    // Safely extract list fields, filtering out non-string values
    List<String> extractStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.where((item) => item is String).cast<String>().toList();
      }
      return [];
    }

    // Safely extract string fields
    String extractString(dynamic value) {
      if (value is String) return value;
      if (value is num) return value.toString();
      return '';
    }

    return PostModel(
      postId: extractString(map['postId']),
      userId: extractString(map['userId']),
      username: extractString(map['username']),
      userProfileImage: extractString(map['userProfileImage']),
      content: extractString(map['content']),
      imageUrls: extractStringList(map['imageUrls']),
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      comments: (map['comments'] as num?)?.toInt() ?? 0,
      shares: (map['shares'] as num?)?.toInt() ?? 0,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      repostsCount: (map['repostsCount'] as num?)?.toInt() ?? 0,
      bookmarksCount: (map['bookmarksCount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] is String
              ? (map['createdAt'] as String)
              : DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] is String
              ? (map['updatedAt'] as String)
              : DateTime.now().toIso8601String()),
      campus: extractString(map['campus']),
      tags: extractStringList(map['tags']),
      poll: map['poll'] != null && map['poll'] is Map
          ? PollModel.fromMap(map['poll'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'content': content,
      'imageUrls': imageUrls,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'bookmarksCount': bookmarksCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'campus': campus,
      'tags': tags,
      'poll': poll?.toMap(),
    };
  }

  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userProfileImage,
    String? content,
    List<String>? imageUrls,
    int? likes,
    int? comments,
    int? shares,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    int? bookmarksCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? campus,
    List<String>? tags,
    PollModel? poll,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      campus: campus ?? this.campus,
      tags: tags ?? this.tags,
      poll: poll ?? this.poll,
    );
  }
}
