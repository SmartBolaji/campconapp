import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isItem;
  final VoidCallback onAddPressed;

  const EmptyStateWidget({
    Key? key,
    required this.isItem,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w), // ✅ Reduced from 32.w
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isItem
                    ? Icons.shopping_bag_outlined
                    : Icons.home_repair_service_outlined,
                size: 64.sp, // ✅ Reduced from 80.sp
                color: AppTheme.primary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 20.h), // ✅ Reduced from 24.h
            Text(
              isItem ? 'No Items Yet' : 'No Services Yet',
              style: TextConstants.boldText.copyWith(
                fontSize: 18.sp, // ✅ Reduced from 20.sp
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 10.h), // ✅ Reduced from 12.h
            Text(
              isItem
                  ? 'Be the first to list an item\nin the marketplace!'
                  : 'Be the first to offer a service\nin the marketplace!',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp, // ✅ Reduced from 14.sp
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h), // ✅ Reduced from 32.h
            GestureDetector(
              onTap: onAddPressed,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 28.w, vertical: 12.h), // ✅ Reduced padding
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        color: AppTheme.white,
                        size: 18.sp), // ✅ Reduced from 20.sp
                    SizedBox(width: 8.w),
                    Text(
                      isItem ? 'Post an Item' : 'Offer a Service',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp, // ✅ Reduced from 16.sp
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
