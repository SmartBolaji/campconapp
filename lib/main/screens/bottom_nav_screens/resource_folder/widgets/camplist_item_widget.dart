import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CamplistItemWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final int taskCount;
  final bool showIcon;

  const CamplistItemWidget({
    Key? key,
    required this.category,
    required this.onTap,
    this.taskCount = 0,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = category['icon'] as IconData;
    final label = category['label'] as String;
    final subtitle = category['subtitle'] as String;
    final color = category['color'] as Color;

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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextConstants.smallText.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                      if (taskCount > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$taskCount',
                            style: TextConstants.smallText.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    taskCount > 0
                        ? '$taskCount task${taskCount > 1 ? 's' : ''}'
                        : subtitle,
                    style: TextConstants.smallText.copyWith(
                      color: taskCount > 0 ? color : AppTheme.textLight,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
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
