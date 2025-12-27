import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ProfileOptions {
  /// Show profile options menu for other users
  static void show(
    BuildContext context, {
    required String? userName,
    VoidCallback? onShare,
    VoidCallback? onCopyLink,
    VoidCallback? onReport,
    VoidCallback? onBlock,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Share Profile
              _OptionItem(
                icon: Ph.share_network,
                label: 'Share Profile',
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
              ),

              // Copy Profile Link
              _OptionItem(
                icon: Ph.link,
                label: 'Copy Profile Link',
                onTap: () {
                  Navigator.pop(context);
                  onCopyLink?.call();
                },
              ),

              // Report User
              _OptionItem(
                icon: Ph.flag,
                label: 'Report User',
                onTap: () {
                  Navigator.pop(context);
                  onReport?.call();
                },
              ),

              // Block User
              _OptionItem(
                icon: Ph.prohibit,
                label: 'Block User',
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation(context, userName, onBlock);
                },
                isDestructive: true,
              ),

              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  /// Show block confirmation dialog
  static void _showBlockConfirmation(
    BuildContext context,
    String? userName,
    VoidCallback? onBlock,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Block ${userName ?? 'User'}?',
            style: TextConstants.mediumText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'They won\'t be able to find your profile, posts, or message you. They won\'t be notified that you blocked them.',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onBlock?.call();
              },
              child: Text(
                'Block',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Option item widget for the bottom sheet
class _OptionItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        child: Row(
          children: [
            Iconify(
              icon,
              size: 22.sp,
              color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
