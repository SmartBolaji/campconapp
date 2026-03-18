import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.text,
    this.icon,
    this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath!,
                    width: 24.w,
                    height: 24.h,
                  )
                else if (icon != null)
                  Icon(icon, size: 24.sp, color: appColors.textPrimary),
                SizedBox(width: 10.w),
                Text(
                  text,
                  style: TextConstants.small(context).copyWith(
                    color: appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
