import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final String? icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool? useWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.useWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(25.r),
      child: Container(
        width: useWidth == true ? 200.w : null,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Container(
          width: double.infinity,
          height: 50.h,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Iconify(
                  icon!,
                  color: textColor,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
              ],
              Text(
                text,
                style: TextConstants.smallText.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
