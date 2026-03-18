import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/poll_provider.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/widgets/format_time.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/image_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/poll_display_widget.dart';
import 'package:campcon/main/services/cache.dart'; //  Add this import
import 'package:cached_network_image/cached_network_image.dart'; //  Add this import
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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

  void _navigateToProfile(BuildContext context) {
    final initialUserData = author ??
        UserModel(
          uid: post.userId,
          email: '',
          username: post.username,
          name: post.username,
          profileImageUrl: '',
          phoneNumber: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ProfileScreen(
          userId: post.userId,
          initialUserData: initialUserData,
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = post.imageUrls.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final displayName = author?.name ?? post.username;
    final displayImage = author?.profileImageUrl ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: appColors.surface,
          border: Border(
            bottom: BorderSide(
              color: appColors.border,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16.w, index == 0 ? 18.h : 12.h, 16.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Clickable Avatar with CachedNetworkImage
                  GestureDetector(
                    onTap: () => _navigateToProfile(context),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: appColors.primaryBackground,
                      backgroundImage: displayImage.isNotEmpty
                          ? CachedNetworkImageProvider(
                              displayImage,
                              cacheManager: CustomCacheManager(),
                            )
                          : null,
                      child: displayImage.isEmpty
                          ? Iconify(
                              Ph.user,
                              size: 20.sp,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //  Clickable Name
                            Flexible(
                              child: GestureDetector(
                                onTap: () => _navigateToProfile(context),
                                child: Text(
                                  displayName,
                                  style: TextConstants.medium(context).copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: appColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '·',
                              style: TextConstants.small(context).copyWith(
                                fontSize: 14.sp,
                                color: appColors.textLight,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              formatDateTime(post.createdAt),
                              style: TextConstants.small(context).copyWith(
                                fontSize: 13.sp,
                                color: appColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        if (post.content.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            post.content,
                            style: TextConstants.medium(context).copyWith(
                              fontSize: 14.sp,
                              color: appColors.textPrimary,
                              height: 1.4,
                            ),
                            maxLines: 5,
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
                      color: appColors.textLight,
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
            // Poll widget
            if (post.poll != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: PollDisplayWidget(
                  poll: post.poll!,
                  postId: post.postId,
                  currentUserId: currentUserId,
                  onVote: (optionId) {
                    context.read<PollProvider>().votePoll(
                          postId: post.postId,
                          optionId: optionId,
                          userId: currentUserId,
                          currentPoll: post.poll!,
                        );
                  },
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
                    context: context,
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: FeatherIcons.repeat,
                    count: postState.repostsCount,
                    onTap: onRepost,
                    isActive: postState.isReposted,
                    activeColor: colorScheme.primary,
                    context: context,
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: postState.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    count: postState.likesCount,
                    onTap: onLike,
                    isActive: postState.isLiked,
                    activeColor: colorScheme.error,
                    context: context,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onShare,
                    child: Icon(
                      FeatherIcons.send,
                      size: 18.sp,
                      color: appColors.textLight,
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
                          ? colorScheme.primary
                          : appColors.textLight,
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
    required BuildContext context,
    bool isActive = false,
    Color? activeColor,
  }) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isActive
                ? (activeColor ?? Theme.of(context).colorScheme.primary)
                : appColors.textLight,
          ),
          if (count > 0) ...[
            SizedBox(width: 6.w),
            Text(
              _formatCount(count),
              style: TextConstants.small(context).copyWith(
                fontSize: 12.sp,
                color: isActive
                    ? (activeColor ?? Theme.of(context).colorScheme.primary)
                    : appColors.textLight,
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
