// lib/main/widgets/notification/notification_tabbar.dart
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationTabBar extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;

  const NotificationTabBar({
    Key? key,
    required this.selectedTab,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            NotificationTab(
              title: 'All',
              index: 0,
              isSelected: selectedTab == 0,
              onTap: onTabChanged,
            ),
            SizedBox(width: 30.w),
            NotificationTab(
              title: 'Likes',
              index: 1,
              isSelected: selectedTab == 1,
              onTap: onTabChanged,
            ),
            SizedBox(width: 30.w),
            NotificationTab(
              title: 'Comments',
              index: 2,
              isSelected: selectedTab == 2,
              onTap: onTabChanged,
            ),
            SizedBox(width: 30.w),
            NotificationTab(
              title: 'Follows',
              index: 3,
              isSelected: selectedTab == 3,
              onTap: onTabChanged,
            ),
            SizedBox(width: 30.w),
            NotificationTab(
              title: 'Marketplace',
              index: 4,
              isSelected: selectedTab == 4,
              onTap: onTabChanged,
            ),
            SizedBox(width: 30.w),
            NotificationTab(
              title: 'Events',
              index: 5,
              isSelected: selectedTab == 5,
              onTap: onTabChanged,
            ),
            // SizedBox(width: 20.w),
            // NotificationTab(
            //   title: 'Mentions',
            //   index: 6,
            //   isSelected: selectedTab == 6,
            //   onTap: onTabChanged,
            // ),
            // SizedBox(width: 20.w),
            // NotificationTab(
            //   title: 'Shares',
            //   index: 7,
            //   isSelected: selectedTab == 7,
            //   onTap: onTabChanged,
            // ),
          ],
        ),
      ),
    );
  }
}

class NotificationTab extends StatelessWidget {
  final String title;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const NotificationTab({
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
            width: title.length * 8.w,
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
