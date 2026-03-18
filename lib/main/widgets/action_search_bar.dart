import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';

enum ActionBarType {
  post, // For home screen - "What's happening?"
  search, // For search screens - with text input
  navigate, // For screens that navigate to a search page
}

class ActionSearchBar extends StatelessWidget {
  final ActionBarType type;
  final String hintText;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool showSuffixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const ActionSearchBar({
    super.key,
    this.type = ActionBarType.navigate,
    this.hintText = 'Search',
    this.leadingIcon,
    this.onTap,
    this.controller,
    this.onChanged,
    this.showSuffixIcon = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  /// Factory for home screen post bar
  factory ActionSearchBar.post({
    required VoidCallback onTap,
  }) {
    return ActionSearchBar(
      type: ActionBarType.post,
      hintText: "What's happening?",
      leadingIcon: Icons.camera_alt_outlined,
      onTap: onTap,
    );
  }

  /// Factory for search with text input
  factory ActionSearchBar.search({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String hintText = 'Search',
    bool showFilter = false,
    VoidCallback? onFilterTap,
  }) {
    return ActionSearchBar(
      type: ActionBarType.search,
      hintText: hintText,
      leadingIcon: IconlyLight.search,
      controller: controller,
      onChanged: onChanged,
      showSuffixIcon: showFilter,
      suffixIcon: IconlyLight.filter,
      onSuffixTap: onFilterTap,
    );
  }

  /// Factory for navigate to search screen
  factory ActionSearchBar.navigate({
    required VoidCallback onTap,
    String hintText = 'Search',
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return ActionSearchBar(
      type: ActionBarType.navigate,
      hintText: hintText,
      leadingIcon: IconlyLight.search,
      onTap: onTap,
      showSuffixIcon: suffixIcon != null,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: type != ActionBarType.search ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: appColors.buttonBorder,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: appColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon
            Icon(
              leadingIcon ?? IconlyLight.search,
              color: appColors.textLight,
              size: type == ActionBarType.post ? 25.sp : 22.sp,
            ),
            SizedBox(width: 12.w),

            // Content (Text or TextField)
            Expanded(
              child: _buildContent(context),
            ),

            // Suffix Icon (optional)
            if (showSuffixIcon && suffixIcon != null) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: appColors.textLight,
                  size: 20.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final appColors = context.appColors;

    if (type == ActionBarType.search) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextConstants.smallText.copyWith(
            color: appColors.textLight,
            fontSize: 14.sp,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextConstants.smallText.copyWith(
          color: appColors.textPrimary,
          fontSize: 14.sp,
        ),
        onChanged: onChanged,
      );
    }

    // For post and navigate types, show static text
    return Text(
      hintText,
      style: TextConstants.smallText.copyWith(
        fontSize: 14.sp,
        color: appColors.textLight,
      ),
    );
  }
}
