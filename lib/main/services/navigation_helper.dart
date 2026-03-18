import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/models/notification_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/event_description.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/market_cart.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/product_description.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_view_widget.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/screens/profile/my_sales/sales_screen.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigationHelper {
  NavigationHelper._();

  // ── Post / Comments ──────────────────────────────────────────────
  static void openPostComments(BuildContext context, String postId) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: PostCommentsScreen(postId: postId),
      ),
    );
  }

  // ── Post View (for notifications like 'liked your post') ──────────
  static Future<void> openPostView(
    BuildContext context,
    String postId, {
    bool focusComment = false,
  }) async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists || !context.mounted) return;

      final post = PostModel.fromMap(postDoc.data()!);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      // Fetch author data
      UserModel? author;
      try {
        final authorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(post.userId)
            .get();
        if (authorDoc.exists) {
          author = UserModel.fromMap(authorDoc.data()!);
        }
      } catch (e) {
        debugPrint('NavigationHelper.openPostView fetch author error: $e');
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PostViewScreen(
            post: post,
            author: author,
            currentUserId: currentUser.uid,
            focusComment: focusComment,
          ),
        ),
      );
    } catch (e) {
      debugPrint('NavigationHelper.openPostView error: $e');
    }
  }

  // ── Profile ──────────────────────────────────────────────────────
  static void openProfile(BuildContext context, String userId) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ProfileScreen(userId: userId),
      ),
    );
  }

  // ── Chat / Message ───────────────────────────────────────────────
  /// Opens a chat with another user.
  /// If [otherUser] is provided, it is used directly.
  /// Otherwise the user document is fetched from Firestore via [otherUserId].
  static Future<void> openChat(
    BuildContext context, {
    String? otherUserId,
    UserModel? otherUser,
    String? defaultMessage,
  }) async {
    UserModel? user = otherUser;

    if (user == null && otherUserId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();
        if (doc.exists) {
          user = UserModel.fromMap(doc.data()!);
        }
      } catch (e) {
        debugPrint('NavigationHelper.openChat fetch error: $e');
      }
    }

    if (user == null || !context.mounted) return;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: Message(
          uid: user.uid,
          profileImg: user.profileImageUrl ?? '',
          name: user.username,
          fcmToken: user.fcmToken ?? '',
          defaultMessage: defaultMessage,
        ),
      ),
    );
  }

  // ── Product / Marketplace ────────────────────────────────────────
  static Future<void> openProduct(
      BuildContext context, String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('marketplace')
          .doc(productId)
          .get();
      if (!doc.exists || !context.mounted) return;
      final product = Product.fromJson(doc.data()!);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: ProductDecription(product: product),
        ),
      );
    } catch (e) {
      debugPrint('NavigationHelper.openProduct error: $e');
    }
  }

  // ── Event ────────────────────────────────────────────────────────
  static Future<void> openEvent(BuildContext context, String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();
      if (!doc.exists || !context.mounted) return;
      final event = EventModel.fromJson(doc.data()!);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: EventDescription(event: event),
        ),
      );
    } catch (e) {
      debugPrint('NavigationHelper.openEvent error: $e');
    }
  }

  // ── Orders / Market Cart ─────────────────────────────────────────
  static void openOrders(BuildContext context) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const MarketCartScreen(),
      ),
    );
  }

  // ── Seller Orders (Sales Screen) ─────────────────────────────────
  static void openSellerOrders(
    BuildContext context, {
    String? productId,
    String? productName,
  }) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: SalesScreen(
          filterProductId: productId,
          filterProductName: productName,
        ),
      ),
    );
  }

  // ── Notification-based routing ───────────────────────────────────
  static Future<void> handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    final targetId = notification.targetId;
    final targetType = notification.targetType;
    final actorId = notification.actorId;

    switch (targetType) {
      case 'post':
      case 'comment':
      case 'share':
      case 'reply':
      case 'mention':
        if (targetId!.isNotEmpty) {
          // For 'like' notifications, open post view; for others, open comments
          if (notification.type == NotificationType.like) {
            await openPostView(context, targetId);
          } else {
            openPostComments(context, targetId);
          }
        }
        break;

      case 'follow':
      case 'user':
        if (actorId.isNotEmpty) {
          openProfile(context, actorId);
        }
        break;

      case 'product':
      case 'order':
      case 'marketplacePurchase':
      case 'marketplaceInterest':
        if (targetId!.isNotEmpty) {
          await openProduct(context, targetId);
        } else {
          openOrders(context);
        }
        break;

      case 'event':
      case 'eventInterested':
      case 'eventAttending':
        if (targetId!.isNotEmpty) {
          await openEvent(context, targetId);
        }
        break;

      case 'message':
        if (actorId.isNotEmpty && context.mounted) {
          await openChat(context, otherUserId: actorId);
        }
        break;

      default:
        debugPrint('Unhandled notification targetType: $targetType');
    }
  }
}
