import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/widgets/role_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';

class UserResultTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final bool showAsListTile;

  const UserResultTile({
    super.key,
    required this.user,
    required this.onTap,
    this.showAsListTile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showAsListTile) {
      return _buildListTile(context);
    }
    return _buildCompactTile(context);
  }

  // Compact horizontal scrollable version
  Widget _buildCompactTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ProfileScreen(userId: user.uid),
          ),
        );
      },
      child: SizedBox(
        width: 80.w,
        child: Column(
          children: [
            // Avatar
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBackground,
                image: user.profileImageUrl != null
                    ? DecorationImage(
                        image:
                            CachedNetworkImageProvider(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.profileImageUrl == null
                  ? Center(
                      child: Iconify(
                        Ph.user,
                        size: 28.sp,
                        color: AppTheme.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 8.h),
            // Name with badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    user.name ?? user.username,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (user.role.isNotEmpty) ...[
                  SizedBox(width: 2.w),
                  RoleBadge(
                    size: 12.sp,
                    role: user.role,
                  ),
                ],
              ],
            ),
            // Username
            Text(
              '@${user.username}',
              style: TextConstants.smallText.copyWith(
                fontSize: 11.sp,
                color: AppTheme.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // List tile version
  Widget _buildListTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ProfileScreen(userId: user.uid),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBackground,
                image: user.profileImageUrl != null
                    ? DecorationImage(
                        image:
                            CachedNetworkImageProvider(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.profileImageUrl == null
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
                  Row(
                    children: [
                      Text(
                        user.name ?? user.username,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (user.role.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        RoleBadge(
                          size: 14.sp,
                          role: user.role,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '@${user.username}',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
