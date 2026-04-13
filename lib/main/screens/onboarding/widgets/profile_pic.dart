import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  void _showImageSourceOptions(BuildContext context, AuthProvider provider) {
    CustomBottomSheet.show(
      context: context,
      height: 0.45,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Profile Picture',
              style: TextConstants.mediumText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),

            // Take Photo option
            _ImageSourceOption(
              icon: Icons.camera_alt,
              title: 'Take a Photo',
              subtitle: 'Use your camera',
              onTap: () async {
                Navigator.pop(context);
                await provider.pickProfileImage(fromCamera: true);
              },
            ),

            SizedBox(height: 12.h),

            // Choose from Gallery option
            _ImageSourceOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select from your photos',
              onTap: () async {
                Navigator.pop(context);
                await provider.pickProfileImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final googleProfileImageUrl =
            authProvider.currentUser?.profileImageUrl?.trim() ?? '';
        final hasGoogleProfileImage = googleProfileImageUrl.isNotEmpty;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceOptions(context, authProvider),
              child: Stack(
                children: [
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBackground.withValues(alpha: 0.3),
                      border: Border.all(
                        color: AppTheme.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: authProvider.profileImage != null
                        ? Container(
                            width: 120.w,
                            height: 120.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(authProvider.profileImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : hasGoogleProfileImage
                            ? Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(googleProfileImageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Iconify(
                                Ph.user,
                                size: 50.sp,
                                color: AppTheme.primary,
                              ),
                  ),

                  // Camera icon overlay
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                        border: Border.all(
                          color: AppTheme.surface,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18.sp,
                        color: AppTheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              authProvider.profileImage != null || hasGoogleProfileImage
                  ? "Tap to change photo"
                  : "Set your profile picture",
              style: TextConstants.smallText.copyWith(
                // fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            // SizedBox(height: 8.h),
            // Text(
            //   "This helps your friends recognize you",
            //   style: TextConstants.smallText.copyWith(
            //     color: AppTheme.textSecondary,
            //     fontSize: 12.sp,
            //   ),
            // ),
          ],
        );
      },
    );
  }
}

// Reusable Image Source Option Widget
class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12.sp,
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
}
