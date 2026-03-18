// lib/main/widgets/resources/faculty_card.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';

class FacultyCard extends StatelessWidget {
  final String faculty;
  final VoidCallback onTap;
  final bool showIcon;

  const FacultyCard({
    Key? key,
    required this.faculty,
    required this.onTap,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(top: 14.h, bottom: 14.h, left: 10.w, right: 10.w),
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
                  IconlyBold.folder,
                  color: AppTheme.primary,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty of',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    faculty,
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Icon(
            //   Icons.arrow_forward_ios,
            //   size: 16.sp,
            //   color: AppTheme.textLight,
            // ),
          ],
        ),
      ),
    );
  }
}
