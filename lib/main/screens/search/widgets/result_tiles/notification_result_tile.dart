import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/notification_model.dart';
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
        // Handle notification tap
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: notification.isRead ? AppTheme.surface : AppTheme.primaryBackground,
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
      case 'like':
        return Ph.heart;
      case 'comment':
        return Ph.chat_circle;
      case 'follow':
        return Ph.user_plus;
      case 'message':
        return Ph.envelope;
      case 'order':
        return Ph.shopping_bag;
      default:
        return Ph.bell;
    }
  }
}