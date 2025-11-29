import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/widgets/format_time.dart';
import 'package:campcon/main/widgets/posts/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;
  final UserModel? author;
  final PostState postState;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onMoreOptions;
  final int index;

  const PostWidget({
    super.key,
    required this.post,
    this.author,
    required this.postState,
    required this.currentUserId,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onRepost,
    this.onShare,
    this.onBookmark,
    this.onMoreOptions,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = post.imageUrls.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;

    final displayName = author?.name ?? post.username;
    final displayImage = author?.profileImageUrl ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.border,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16.w, index == 0 ? 20.h : 12.h, 16.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppTheme.primaryBackground,
                    backgroundImage: displayImage.isNotEmpty
                        ? NetworkImage(displayImage)
                        : null,
                    child: displayImage.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 20.sp,
                            color: AppTheme.primary,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: TextConstants.mediumText.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '·',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 14.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              formatDateTime(post.createdAt),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 13.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        if (post.content.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            post.content,
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 14.sp,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onMoreOptions,
                    child: Icon(
                      Icons.more_horiz,
                      size: 20.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImages) ...[
              if (post.imageUrls.length == 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: ImagePageViewWidget(
                      imageUrls: post.imageUrls,
                      showFullScreenButton: false,
                      isLiked: postState.isLiked,
                      onLike: onLike ?? () {},
                      width: screenWidth - 32.w,
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: ImagePageViewWidget(
                    imageUrls: post.imageUrls,
                    showFullScreenButton: false,
                    isLiked: postState.isLiked,
                    onLike: onLike ?? () {},
                    width: screenWidth,
                  ),
                ),
              SizedBox(height: 12.h),
            ],
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: FeatherIcons.messageCircle,
                    count: postState.repliesCount,
                    onTap: onComment,
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: FeatherIcons.repeat,
                    count: post.shares,
                    onTap: onRepost,
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: postState.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    count: postState.likesCount,
                    onTap: onLike,
                    isActive: postState.isLiked,
                    activeColor: AppTheme.error,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onShare,
                    child: Icon(
                      FeatherIcons.send,
                      size: 18.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: onBookmark,
                    child: Icon(
                      postState.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 20.sp,
                      color: postState.isBookmarked
                          ? AppTheme.primary
                          : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback? onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isActive
                ? (activeColor ?? AppTheme.primary)
                : AppTheme.textLight,
          ),
          if (count > 0) ...[
            SizedBox(width: 6.w),
            Text(
              _formatCount(count),
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: isActive
                    ? (activeColor ?? AppTheme.primary)
                    : AppTheme.textLight,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
