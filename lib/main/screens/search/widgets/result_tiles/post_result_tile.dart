import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostResultTile extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  
  const PostResultTile({
    super.key,
    required this.post,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        // Navigate to post detail
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                // Avatar
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBackground,
                    image: post.userProfileImage.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(post.userProfileImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: post.userProfileImage.isEmpty
                      ? Center(
                          child: Iconify(
                            Ph.user,
                            size: 18.sp,
                            color: AppTheme.primary,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 10.w),
                // Name & time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Content
            Text(
              post.content,
              style: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Image preview
            if (post.imageUrls.isNotEmpty) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrls.first,
                  height: 120.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.background,
                  ),
                ),
              ),
            ],
            
            // Stats
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildStat(Ph.heart, post.likes.toString()),
                SizedBox(width: 16.w),
                _buildStat(Ph.chat_circle, post.comments.toString()),
                SizedBox(width: 16.w),
                _buildStat(Ph.share, post.shares.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String icon, String count) {
    return Row(
      children: [
        Iconify(
          icon,
          size: 16.sp,
          color: AppTheme.textLight,
        ),
        SizedBox(width: 4.w),
        Text(
          count,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }
}