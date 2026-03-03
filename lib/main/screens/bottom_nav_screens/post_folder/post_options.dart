import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/report_model.dart';
import 'package:campcon/main/widgets/report_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class PostOptionsWidget {
  static void showPostOptions({
    required BuildContext context,
    required bool isMyPost,
    required String postId,
    required PostModel post,
    required VoidCallback onDelete,
    required VoidCallback onShare,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  'Post Options',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 20.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (isMyPost) ...[
                _buildOption(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete Post',
                  description: 'Remove this post permanently',
                  color: AppTheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
              _buildOption(
                context,
                icon: Icons.link_outlined,
                title: 'Copy Link',
                description: 'Share post link to clipboard',
                color: AppTheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(
                    ClipboardData(text: 'https://campcon.app/post/$postId'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
              ),
              _buildOption(
                context,
                icon: Icons.share_outlined,
                title: 'Share Post',
                description: 'Share via other apps',
                color: AppTheme.info,
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              if (!isMyPost)
                _buildOption(
                  context,
                  icon: Icons.report_outlined,
                  title: 'Report Post',
                  description: 'Report inappropriate content',
                  color: AppTheme.warning,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigator.pop(context);
                    // _showReportDialog(context);
                    ReportBottomSheet.show(
                      context: context,
                      targetTitle: post.username,

                      reportType: ReportType.post,
                      targetId: post.postId,
                      targetDescription: post.content.isNotEmpty
                          ? post.content.length > 50
                              ? '${post.content.substring(0, 50)}...'
                              : post.content
                          : 'Post by ${post.username}',
                      targetImageUrl: post.imageUrls.isNotEmpty
                          ? post.imageUrls.first
                          : null,
                      reporterId: post.userId,
                      // Replace with actual user ID
                      reporterName:
                          FirebaseAuth.instance.currentUser!.displayName ??
                              'Anonymous User', // Replace with actual user name
                      school:
                          post.campus ?? "", // Replace with actual school name
                    );
                  },
                ),
              _buildOption(
                context,
                icon: Icons.cancel_outlined,
                title: 'Cancel',
                description: 'Close this menu',
                color: AppTheme.textLight,
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  static void showShareOptions({
    required BuildContext context,
    required String postId,
    String? postContent,
  }) {
    final String shareText = postContent != null && postContent.isNotEmpty
        ? '$postContent\n\nCheck out this post on Campcon: https://campcon.app/post/$postId'
        : 'Check out this post on Campcon: https://campcon.app/post/$postId';

    Share.share(shareText);
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.border.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

  static void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text(
          'Report Post',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Thank you for helping keep our community safe. We will review this post.',
          style:
              TextConstants.smallText.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Post reported. Thank you!',
                    style: TextConstants.smallText
                        .copyWith(color: AppTheme.textPrimary),
                  ),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text('Report',
                style: TextConstants.smallText.copyWith(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class CommentOptionsWidget {
  static void showCommentOptions({
    required BuildContext context,
    required String commentId,
    required VoidCallback onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.25,
        maxChildSize: 0.6,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Comment Options',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildOption(
                      context,
                      icon: Icons.delete_outline,
                      title: 'Delete Comment',
                      description: 'Remove this comment permanently',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                    ),
                    _buildOption(
                      context,
                      icon: Icons.cancel_outlined,
                      title: 'Cancel',
                      description: 'Close this menu',
                      color: Colors.grey,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
