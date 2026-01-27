import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;
  final SearchContext context;

  const SearchEmptyState({
    super.key,
    required this.query,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                shape: BoxShape.circle,
              ),
              child: Iconify(
                _getIcon(),
                size: 48.sp,
                color: AppTheme.textLight,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              'No results found',
              style: TextConstants.mediumText.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'We couldn\'t find anything for '),
                  TextSpan(
                    text: '"$query"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Suggestions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Iconify(
                        Ph.lightbulb,
                        size: 18.sp,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Tips',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ..._getSuggestions().map((tip) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 13.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIcon() {
    switch (this.context) {
      case SearchContext.home:
        return Ph.newspaper;
      case SearchContext.messaging:
        return Ph.chat_circle;
      case SearchContext.resources:
        return Ph.files;
      case SearchContext.notifications:
        return Ph.bell;
      case SearchContext.market:
        return Ph.storefront;
    }
  }

  List<String> _getSuggestions() {
    switch (this.context) {
      case SearchContext.home:
        return [
          'Check your spelling',
          'Try more general keywords',
          'Search for usernames or hashtags',
        ];
      case SearchContext.messaging:
        return [
          'Check the spelling of the name',
          'Try searching for username',
          'Make sure the person has an account',
        ];
      case SearchContext.resources:
        return [
          'Try a different course code',
          'Use broader terms like "notes" or "past questions"',
          'Check if the resource type filter is correct',
        ];
      case SearchContext.notifications:
        return [
          'Search for specific keywords',
          'Try a different time period',
        ];
      case SearchContext.market:
        return [
          'Try different product names',
          'Use category filters',
          'Search for seller names',
        ];
    }
  }
}
