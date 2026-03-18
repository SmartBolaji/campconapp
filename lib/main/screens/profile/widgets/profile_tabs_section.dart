import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTabsSection extends StatelessWidget {
  const ProfileTabsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
        color: AppTheme.surface,
      ),
      child: TabBar(
        dividerColor: AppTheme.border,
        dividerHeight: 1.h,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 2,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: TextConstants.smallText.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextConstants.smallText,
        tabs: const [
          Tab(text: "Posts"),
          Tab(text: 'Reposts'),
          Tab(text: "Media"),
          Tab(text: "Saved"),
        ],
      ),
    );
  }
}
