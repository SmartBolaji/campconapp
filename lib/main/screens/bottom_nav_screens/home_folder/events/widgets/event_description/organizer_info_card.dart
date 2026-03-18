import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class OrganizerInfoCard extends StatelessWidget {
  final String organizerName;
  final String? organizerImageUrl;
  final String? organizerBio;
  final bool isLoading;
  final VoidCallback? onMessageTap;
  final VoidCallback? onProfileTap;

  const OrganizerInfoCard({
    Key? key,
    required this.organizerName,
    this.organizerImageUrl,
    this.organizerBio,
    this.isLoading = false,
    this.onMessageTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organizer',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        isLoading ? _buildLoadingState() : _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 28.r,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              backgroundImage:
                  organizerImageUrl != null && organizerImageUrl!.isNotEmpty
                      ? NetworkImage(organizerImageUrl!)
                      : null,
              child: organizerImageUrl == null || organizerImageUrl!.isEmpty
                  ? Iconify(
                      Ph.user,
                      color: AppTheme.primary,
                      size: 28.sp,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Iconify(
                    //   Ph.shield_check,
                    //   size: 14.sp,
                    //   color: AppTheme.success,
                    // ),
                    // SizedBox(width: 4.w),
                    Text(
                      'Event Organizer',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  organizerName,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (organizerBio != null && organizerBio!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    organizerBio!,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // if (onMessageTap != null)
          //   GestureDetector(
          //     onTap: onMessageTap,
          //     child: Container(
          //       padding: EdgeInsets.all(8.w),
          //       decoration: BoxDecoration(
          //         color: AppTheme.background,
          //         borderRadius: BorderRadius.circular(8.r),
          //       ),
          //       child: Iconify(
          //         Ph.chat_circle_dots,
          //         color: AppTheme.primary,
          //         size: 20.sp,
          //       ),
          //     ),
          //   )
          // else if (onProfileTap != null)
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.arrow_right,
                color: AppTheme.textSecondary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppTheme.buttonBorder,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBorder,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 16.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBorder,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
