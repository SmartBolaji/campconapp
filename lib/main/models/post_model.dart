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
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.content,
    required this.imageUrls,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.createdAt,
    required this.updatedAt,
  });

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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      shares: map['shares'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
