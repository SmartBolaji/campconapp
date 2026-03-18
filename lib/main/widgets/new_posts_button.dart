import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';

/// ✅ Twitter/X-style "New posts available" button
/// Shows count of new posts and loads them when tapped
class NewPostsButton extends StatelessWidget {
  final int newPostsCount;
  final bool isLoading;
  final VoidCallback onPressed;

  const NewPostsButton({
    super.key,
    required this.newPostsCount,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if no new posts
    if (newPostsCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Material(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.surface),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_upward,
                    size: 16.sp,
                    color: AppTheme.surface,
                  ),
                SizedBox(width: 8.w),
                Text(
                  isLoading
                      ? 'Loading...'
                      : 'New post${newPostsCount == 1 ? '' : 's'} • $newPostsCount',
                  style: TextStyle(
                    color: AppTheme.surface,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
