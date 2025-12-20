// lib/main/widgets/resources/faculty_card.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';

class FacultyCard extends StatelessWidget {
  final String faculty;
  final VoidCallback onTap;

  const FacultyCard({
    Key? key,
    required this.faculty,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(top: 12.h, bottom: 12.h, left: 10.w, right: 10.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          // borderRadius: BorderRadius.circular(12.r),
          border: Border(bottom: BorderSide(color: AppTheme.border)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.03),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          children: [
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
            Expanded(
              child: Text(
                faculty,
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
}
