import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'message_model.g.dart'; // Will be generated

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  final String messageId;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final int timestamp;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final bool edited;

  @HiveField(8)
  final bool deleted;

  @HiveField(9)
  final Map<String, dynamic>? replyTo; // <-- Add this line

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
    this.edited = false,
    this.deleted = false,
    this.replyTo, // <-- Add this line
  });

  // Convert from Firestore document
  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    // Handle different timestamp formats (Firestore Timestamp or serialized Map)
    int timestampMillis = 0;

    if (data['timestamp'] is Timestamp) {
      // Direct Firestore timestamp
      timestampMillis = (data['timestamp'] as Timestamp).millisecondsSinceEpoch;
    } else if (data['timestamp'] is Map) {
      // Serialized timestamp from cache
      final timestampMap = data['timestamp'] as Map;
      if (timestampMap.containsKey('_seconds')) {
        final seconds = timestampMap['_seconds'] as int;
        final nanoseconds = timestampMap['_nanoseconds'] as int? ?? 0;
        timestampMillis = seconds * 1000 + (nanoseconds ~/ 1000000);
      }
    } else if (data['timestamp'] is int) {
      // Direct milliseconds value
      timestampMillis = data['timestamp'] as int;
    }

    return ChatMessage(
      messageId: data['messageId'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: timestampMillis,
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      edited: data['edited'] ?? false,
      deleted: data['deleted'] ?? false,
      replyTo: data['replyTo'], // <-- Add this line
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp),
      'isRead': isRead,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'edited': edited,
      'deleted': deleted,
      if (replyTo != null) 'replyTo': replyTo, // <-- Add this line
    };
  }
}
