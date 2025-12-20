// lib/main/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  like,
  comment,
  reply,
  follow,
  marketplacePurchase,
  marketplaceInterest,
  eventInterested,
  eventAttending,
  mention,
  share,
}

class NotificationModel {
  final String id;
  final String recipientId;
  final String actorId;
  final String actorName;
  final String? actorProfileImage;
  final NotificationType type;
  final String title;
  final String body;
  final String? targetId; // postId, productId, eventId, etc.
  final String? targetType; // 'post', 'product', 'event', 'user'
  final String? imageUrl; // Optional image for context
  final Map<String, dynamic>? metadata; // Additional data
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.actorId,
    required this.actorName,
    this.actorProfileImage,
    required this.type,
    required this.title,
    required this.body,
    this.targetId,
    this.targetType,
    this.imageUrl,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      recipientId: map['recipientId'] ?? '',
      actorId: map['actorId'] ?? '',
      actorName: map['actorName'] ?? '',
      actorProfileImage: map['actorProfileImage'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.like,
      ),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      targetId: map['targetId'],
      targetType: map['targetType'],
      imageUrl: map['imageUrl'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'actorId': actorId,
      'actorName': actorName,
      'actorProfileImage': actorProfileImage,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'targetId': targetId,
      'targetType': targetType,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? actorId,
    String? actorName,
    String? actorProfileImage,
    NotificationType? type,
    String? title,
    String? body,
    String? targetId,
    String? targetType,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorProfileImage: actorProfileImage ?? this.actorProfileImage,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get formatted time
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}
