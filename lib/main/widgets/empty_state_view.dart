import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class EmptyStateView extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 28.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Iconify(
                icon,
                size: 42.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: TextConstants.medium(context).copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: appColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextConstants.small(context).copyWith(
                fontSize: 14.sp,
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // if (buttonText != null && onPressed != null) ...[
            //   SizedBox(height: 18.h),
            //   ElevatedButton(
            //     onPressed: onPressed,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppTheme.primary,
            //       foregroundColor: Colors.white,
            //       padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
            //     ),
            //     child: Text(buttonText!),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
