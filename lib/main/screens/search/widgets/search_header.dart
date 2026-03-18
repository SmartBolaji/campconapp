import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;
  final bool showFilter;
  final VoidCallback? onFilterTap;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
    this.showFilter = false,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Iconify(
                Ph.arrow_left,
                size: 24.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Search field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(
                    IconlyLight.search,
                    size: 20.sp,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextConstants.smallText.copyWith(
                          fontSize: 15.sp,
                          color: AppTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.textLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 16.w),
                ],
              ),
            ),
          ),

          // Filter button
          if (showFilter) ...[
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.buttonBorder,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Icon(
                  IconlyLight.filter,
                  size: 20.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
