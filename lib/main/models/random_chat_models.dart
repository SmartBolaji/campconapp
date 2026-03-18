/// Models for the anonymous Random Shot (random chat) feature.
/// These are intentionally separate from [ChatMessage] in message_model.dart
/// (which handles regular DMs) to avoid naming conflicts.

class RandomChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isSent;
  final String senderId;

  RandomChatMessage({
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
