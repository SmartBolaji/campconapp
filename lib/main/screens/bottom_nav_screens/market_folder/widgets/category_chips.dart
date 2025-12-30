import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.currentCategories.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final category = provider.currentCategories[index];
              final isSelected = provider.selectedCategory == category;

              return _CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () => provider.changeCategory(category),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
