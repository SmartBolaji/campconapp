import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/notification_model.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationResultTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationResultTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        _handleNotificationTap(context);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppTheme.surface
              : AppTheme.primaryBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Iconify(
                _getNotificationIcon(),
                size: 20.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    timeago.format(notification.createdAt),
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Ph.heart;
      case NotificationType.comment:
      case NotificationType.reply:
        return Ph.chat_circle;
      case NotificationType.follow:
        return Ph.user_plus;
      case NotificationType.mention:
      case NotificationType.share:
        return Ph.envelope;
      case NotificationType.marketplacePurchase:
      case NotificationType.marketplaceInterest:
        return Ph.shopping_bag;
      case NotificationType.eventInterested:
      case NotificationType.eventAttending:
        return Ph.calendar_blank;
    }
  }

  void _handleNotificationTap(BuildContext context) {
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.reply:
        // Navigate to post
        if (notification.targetId != null) {
          NavigationHelper.openPostView(context, notification.targetId!);
        }
        break;
      case NotificationType.follow:
        // Navigate to user profile
        if (notification.actorId != null) {
          NavigationHelper.openProfile(context, notification.actorId!);
        }
        break;
      case NotificationType.mention:
      case NotificationType.share:
        // Navigate to post if available
        if (notification.targetId != null) {
          NavigationHelper.openPostView(context, notification.targetId!);
        }
        break;
      case NotificationType.marketplacePurchase:
      case NotificationType.marketplaceInterest:
        // Navigate to product if available
        if (notification.targetId != null) {
          NavigationHelper.openProduct(context, notification.targetId!);
        }
        break;
      case NotificationType.eventInterested:
      case NotificationType.eventAttending:
        // Navigate to event if available
        if (notification.targetId != null) {
          NavigationHelper.openEvent(context, notification.targetId!);
        }
        break;
    }
  }
}
