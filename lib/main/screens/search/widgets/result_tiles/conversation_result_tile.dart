import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ConversationResultTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const ConversationResultTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userData = conversation['userData'] as Map<String, dynamic>;
    final name = userData['name'] ?? userData['username'] ?? 'User';
    final profileUrl = userData['profileImageUrl'];
    final lastMessage = conversation['lastMessage'] ?? '';
    final unreadCount = conversation['unreadCount'] ?? 0;

    return GestureDetector(
      onTap: () {
        onTap();
        // Navigate to chat
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBackground,
                image: profileUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(profileUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profileUrl == null
                  ? Center(
                      child: Iconify(
                        Ph.user,
                        size: 24.sp,
                        color: AppTheme.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 15.sp,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lastMessage,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: unreadCount > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Unread badge
            if (unreadCount > 0)
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
