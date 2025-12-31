// lib/main/services/notification_helper.dart
import 'package:campcon/main/models/notification_model.dart';
import 'package:campcon/main/provider/notify_provider.dart';

class NotificationHelper {
  // Varibale 
  static NotifyProvider? notifyProvider;
  /// Create a like notification
  static Future<void> createLikeNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String postId,
    String? postImageUrl,
  }) async {
    await notifyProvider!.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.like,
      title: 'New Like',
      body: 'liked your post',
      targetId: postId,
      targetType: 'post',
      imageUrl: postImageUrl,
    );
  }

  /// Create a comment notification
  static Future<void> createCommentNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String postId,
    String? postImageUrl,
    String? commentText,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.comment,
      title: 'New Comment',
      body:
          'commented on your post${commentText != null ? ": \"${commentText.length > 30 ? "${commentText.substring(0, 30)}..." : commentText}\"" : ""}',
      targetId: postId,
      targetType: 'post',
      imageUrl: postImageUrl,
      metadata: {'commentText': commentText},
    );
  }

  /// Create a follow notification
  static Future<void> createFollowNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.follow,
      title: 'New Follower',
      body: 'started following you',
      targetId: actorId,
      targetType: 'user',
    );
  }

  /// Create a marketplace interest notification
  static Future<void> createMarketplaceInterestNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String productId,
    required String productName,
    String? productImageUrl,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.marketplaceInterest,
      title: 'Marketplace Interest',
      body: 'is interested in "$productName"',
      targetId: productId,
      targetType: 'product',
      imageUrl: productImageUrl,
    );
  }

  /// Create an event interested notification
  static Future<void> createEventInterestedNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String eventId,
    required String eventTitle,
    String? eventImageUrl,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.eventInterested,
      title: 'Event Interest',
      body: 'is interested in "$eventTitle"',
      targetId: eventId,
      targetType: 'event',
      imageUrl: eventImageUrl,
    );
  }

  /// Create an event attending notification
  static Future<void> createEventAttendingNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String eventId,
    required String eventTitle,
    String? eventImageUrl,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.eventAttending,
      title: 'Event Attendance',
      body: 'is attending "$eventTitle"',
      targetId: eventId,
      targetType: 'event',
      imageUrl: eventImageUrl,
    );
  }

  /// Create a mention notification
  static Future<void> createMentionNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String postId,
    String? postImageUrl,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.mention,
      title: 'New Mention',
      body: 'mentioned you in a post',
      targetId: postId,
      targetType: 'post',
      imageUrl: postImageUrl,
    );
  }

  /// Create a share notification
  static Future<void> createShareNotification({
    required NotifyProvider notifyProvider,
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorProfileImage,
    required String postId,
    String? postImageUrl,
  }) async {
    await notifyProvider.createNotification(
      recipientId: recipientId,
      actorId: actorId,
      actorName: actorName,
      actorProfileImage: actorProfileImage,
      type: NotificationType.share,
      title: 'Post Shared',
      body: 'shared your post',
      targetId: postId,
      targetType: 'post',
      imageUrl: postImageUrl,
    );
  }
}
