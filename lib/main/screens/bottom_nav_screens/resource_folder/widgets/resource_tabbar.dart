// lib/main/widgets/resources/resource_tabbar.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResourceTabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const ResourceTabBar({
    Key? key,
    required this.selectedTab,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTab(
            title: 'Resource',
            index: 0,
            isSelected: selectedTab == 0,
            onTap: onTabChanged,
          ),
          // SizedBox(width: 30.w),
          // CustomTab(
          //   title: 'Camplist',
          //   index: 1,
          //   isSelected: selectedTab == 1,
          //   onTap: onTabChanged,
          // ),
        ],
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  final String title;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const CustomTab({
    Key? key,
    required this.title,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextConstants.smallText.copyWith(
              fontSize: 15.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? Constants.primaryDark : Constants.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 3.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: isSelected ? Constants.primaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
