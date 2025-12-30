import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileButton({
    Key? key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.buttonBorder,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.border,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
