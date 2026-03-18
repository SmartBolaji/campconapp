import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class SearchIdleView extends StatelessWidget {
  final List<String> recentSearches;
  final List<String> trendingSearches;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onTrendingTap;

  const SearchIdleView({
    super.key,
    required this.recentSearches,
    required this.trendingSearches,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearRecent,
    required this.onTrendingTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (recentSearches.isNotEmpty) ...[
            _buildSectionHeader(
              'Recent',
              showClear: true,
              onClear: onClearRecent,
            ),
            SizedBox(height: 12.h),
            ...recentSearches.map((query) => _RecentSearchTile(
                  query: query,
                  onTap: () => onRecentTap(query),
                  onRemove: () => onRecentRemove(query),
                )),
            SizedBox(height: 24.h),
          ],

          // Trending searches
          if (trendingSearches.isNotEmpty) ...[
            _buildSectionHeader('Trending'),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: trendingSearches
                  .map((query) => _TrendingChip(
                        query: query,
                        onTap: () => onTrendingTap(query),
                      ))
                  .toList(),
            ),
          ],

          // Quick tips
          if (recentSearches.isEmpty && trendingSearches.isEmpty)
            _buildEmptySearchTips(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {bool showClear = false, VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        if (showClear)
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear all',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySearchTips() {
    return Column(
      children: [
        SizedBox(height: 60.h),
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryBackground,
            shape: BoxShape.circle,
          ),
          child: Iconify(
            Ph.magnifying_glass,
            size: 40.sp,
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Start searching',
          style: TextConstants.mediumText.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Type something to find what you\'re looking for',
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchTile({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              IconlyLight.time_circle,
              size: 20.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                query,
                style: TextConstants.smallText.copyWith(
                  fontSize: 15.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.close,
                  size: 18.sp,
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const _TrendingChip({
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Iconify(
              Ph.trend_up,
              size: 16.sp,
              color: AppTheme.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              query,
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
