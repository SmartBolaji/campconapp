import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class AdminPostCard extends StatelessWidget {
  final PostModel post;
  final bool isActionLoading;
  final VoidCallback? onDelete;

  const AdminPostCard({
    super.key,
    required this.post,
    required this.isActionLoading,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(post.userProfileImage, post.username),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${post.username}',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Iconify(Ph.clock, size: 11.r, color: AppTheme.textLight),
                          SizedBox(width: 3.w),
                          Text(
                            _timeAgo(post.createdAt),
                            style: TextConstants.smallText.copyWith(
                              fontSize: 11.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                          if (post.campus != null && post.campus!.isNotEmpty) ...[
                            Text(
                              '  ·  ',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                post.campus!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 11.sp,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: isActionLoading ? null : () => _confirmDelete(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isActionLoading
                          ? AppTheme.border
                          : AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Iconify(
                      Ph.trash,
                      size: 16.r,
                      color: isActionLoading ? AppTheme.textLight : AppTheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (post.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: post.tags.take(5).map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 10.sp,
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
            ),

          if (post.imageUrls.isNotEmpty)
            SizedBox(
              height: 88.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                itemCount: post.imageUrls.length.clamp(0, 5),
                separatorBuilder: (_, __) => SizedBox(width: 6.w),
                itemBuilder: (context, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrls[i],
                        width: 78.w,
                        height: 78.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 78.w,
                          height: 78.h,
                          color: AppTheme.border,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 78.w,
                          height: 78.h,
                          color: AppTheme.background,
                          child: Iconify(Ph.image, size: 24.r, color: AppTheme.textLight),
                        ),
                      ),
                    ),
                    if (i == 4 && post.imageUrls.length > 5)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text(
                              '+${post.imageUrls.length - 5}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          if (post.imageUrls.isNotEmpty) SizedBox(height: 10.h),

          if (post.poll != null)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(Ph.chart_bar, size: 14.r, color: AppTheme.info),
                    SizedBox(width: 6.w),
                    Text(
                      'Contains poll',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        color: AppTheme.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
            child: Row(
              children: [
                _stat(Ph.heart, post.likesCount),
                SizedBox(width: 14.w),
                _stat(Ph.chat_circle, post.commentsCount),
                SizedBox(width: 14.w),
                _stat(Ph.repeat, post.repostsCount),
                SizedBox(width: 14.w),
                _stat(Ph.bookmark_simple, post.bookmarksCount),
                const Spacer(),
                Text(
                  post.postId.length > 12
                      ? '${post.postId.substring(0, 12)}…'
                      : post.postId,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 10.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String username) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 38.w,
          height: 38.w,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsAvatar(username),
        ),
      );
    }
    return _initialsAvatar(username);
  }

  Widget _initialsAvatar(String name) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _stat(String icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Iconify(icon, size: 13.r, color: AppTheme.textLight),
        SizedBox(width: 4.w),
        Text(
          _fmt(count),
          style: TextConstants.smallText.copyWith(
            fontSize: 11.sp,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Post?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently remove the post by @${post.username}. This cannot be undone.',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text(
              'Delete',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
