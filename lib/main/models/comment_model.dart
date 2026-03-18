import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final bool isVerified;
  final String text;
  final DateTime createdAt;
  final List<String> likes;
  final String? replyTo; // parent comment ID
  final String? replyToUsername;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar = '',
    this.isVerified = false,
    required this.text,
    required this.createdAt,
    this.likes = const [],
    this.replyTo,
    this.replyToUsername,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      commentId: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'User',
      userAvatar: map['userAvatar'] ?? '',
      isVerified: map['isVerified'] ?? false,
      text: map['text'] ?? map['comment'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['created'] is Timestamp
              ? (map['created'] as Timestamp).toDate()
              : DateTime.now()),
      likes: List<String>.from(map['likes'] ?? []),
      replyTo: map['replyTo'],
      replyToUsername: map['replyToUsername'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'isVerified': isVerified,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': likes,
      'replyTo': replyTo,
      'replyToUsername': replyToUsername,
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    bool? isVerified,
    String? text,
    DateTime? createdAt,
    List<String>? likes,
    String? replyTo,
    String? replyToUsername,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      isVerified: isVerified ?? this.isVerified,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      replyTo: replyTo ?? this.replyTo,
      replyToUsername: replyToUsername ?? this.replyToUsername,
    );
  }
}
