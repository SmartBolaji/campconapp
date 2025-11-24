class Story {
  final String id;
  final String name;
  final String imageUrl;
  final bool hasStory;

  Story({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.hasStory,
  });
} 

class Post {
  final String id;
  final String userName;
  final String userAvatar;
  final String time;
  final String caption;
  final bool hasVideo;
  final String? videoThumbnail;

  Post({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.time,
    required this.caption,
    required this.hasVideo,
    this.videoThumbnail,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isSent;
  final String senderId;

  ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isSent,
    required this.senderId,
  });
}

class UserProfile {
  final String userId;
  final String name;
  final String? avatarUrl;
  final bool isOnline;

  UserProfile({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
  });
}