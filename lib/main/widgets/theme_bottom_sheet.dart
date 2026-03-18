import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

void showThemeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'Choose Theme',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    'Select how you\'d like the app to look',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Theme options
                  _buildThemeOption(
                    context: context,
                    icon: Ph.sun,
                    iconColor: Colors.orange,
                    label: 'Light Mode',
                    description: 'Use bright theme',
                    isSelected: themeProvider.themeMode == ThemeMode.light,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.light);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 12.h),

                  _buildThemeOption(
                    context: context,
                    icon: Ph.moon,
                    iconColor: Colors.amber,
                    label: 'Dark Mode',
                    description: 'Use dark theme',
                    isSelected: themeProvider.themeMode == ThemeMode.dark,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.dark);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 12.h),

                  _buildThemeOption(
                    context: context,
                    icon: Ph.device_mobile,
                    iconColor: AppTheme.primary,
                    label: 'System Default',
                    description: 'Follow device settings',
                    isSelected: themeProvider.themeMode == ThemeMode.system,
                    onTap: () {
                      themeProvider.setThemeMode(ThemeMode.system);
                      Navigator.pop(context);
                    },
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildThemeOption({
  required BuildContext context,
  required String icon,
  required Color iconColor,
  required String label,
  required String description,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color:
            isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Iconify(
                icon,
                color: iconColor,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Iconify(
                  Ph.check,
                  color: Colors.white,
                  size: 14.sp,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
