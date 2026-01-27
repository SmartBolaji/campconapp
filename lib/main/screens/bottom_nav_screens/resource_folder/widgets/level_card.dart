// lib/main/widgets/resources/level_card.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';

Widget buildLevelCard(BuildContext context, String level, VoidCallback onTap,
    {bool showIcon = false}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding:
          EdgeInsets.only(top: 12.h, bottom: 12.h, left: 10.w, right: 10.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                IconlyBold.bookmark,
                color: AppTheme.primary,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(
            child: Text(
              level,
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 18.sp,
            color: AppTheme.textLight,
          ),
        ],
      ),
    ),
  );
}