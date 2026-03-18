import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class FullBioSheet extends StatelessWidget {
  final UserModel user;

  const FullBioSheet({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
          child: Column(
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

              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    backgroundImage: user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null ||
                            user.profileImageUrl!.isEmpty
                        ? Iconify(
                            Ph.user,
                            size: 24.sp,
                            color: AppTheme.primary,
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name ?? "No Name",
                                style: TextConstants.mediumText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isProfessional) ...[
                              SizedBox(width: 4.w),
                              Iconify(Ph.star_fill,
                                  size: 14.r, color: const Color(0xFFFFD700)),
                            ],
                          ],
                        ),
                        Text(
                          "@${user.username}",
                          style: TextConstants.smallText.copyWith(
                            color: AppTheme.textLight,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Divider
              Container(
                height: 1,
                color: AppTheme.border,
              ),

              SizedBox(height: 24.h),

              // Full Bio
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    user.aboutMe ?? '',
                    style: TextConstants.mediumText.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.6,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
