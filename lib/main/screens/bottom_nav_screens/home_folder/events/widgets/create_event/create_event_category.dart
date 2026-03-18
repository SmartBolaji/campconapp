import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class CreateEventCategory extends StatelessWidget {
  const CreateEventCategory({Key? key}) : super(key: key);

  static const List<String> eventCategories = [
    'Music',
    'Sports',
    'Academic',
    'Social',
    'Workshop',
    'Party',
    'Competition',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category *',
              style: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: provider.selectedCategory,
                  hint: Text(
                    'Select category',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  icon: Iconify(
                    Ph.caret_down,
                    color: AppTheme.textLight,
                    size: 20.sp,
                  ),
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    color: AppTheme.textPrimary,
                  ),
                  dropdownColor: AppTheme.surface,
                  items: eventCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => provider.setSelectedCategory(value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
