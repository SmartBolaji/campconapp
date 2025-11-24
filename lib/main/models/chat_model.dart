// Placeholder for a real User class, containing basic info for chat participants



class ChatParticipant {
  final String id;
  final String name;
  final String avatarUrl;

  ChatParticipant({
    required this.id,
    required this.name,
    this.avatarUrl = '',
  });
}

// Represents a single message in a conversation
class MessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

// Represents a conversation displayed on the MessagesScreen
class ConversationModel {
  final String conversationId;
  final ChatParticipant recipient;
  final String productId; // Links the chat back to a product
  final MessageModel lastMessage;
  final int unreadCount;

  ConversationModel({
    required this.conversationId,
    required this.recipient,
    required this.productId,
    required this.lastMessage,
    required this.unreadCount,
  });
}
