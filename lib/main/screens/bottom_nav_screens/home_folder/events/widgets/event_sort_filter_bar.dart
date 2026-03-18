import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class EventSortFilterBar extends StatelessWidget {
  const EventSortFilterBar({Key? key}) : super(key: key);

  String _filterLabel(EventProvider provider) {
    final hasSort = provider.sortBy != 'Upcoming';
    final hasCategory = provider.selectedCategory != 'All';

    if (hasSort && hasCategory) {
      return '${provider.sortBy} · ${provider.selectedCategory}';
    } else if (hasSort) {
      return provider.sortBy;
    } else if (hasCategory) {
      return provider.selectedCategory;
    }
    return 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                  onTap: () => _showOptions(context, provider),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Iconify(
                          Ph.funnel_bold,
                          size: 14.sp,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: 4.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 160.w),
                          child: Text(
                            _filterLabel(provider),
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16.sp,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  )
                  // : Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Iconify(
                  //       Ph.funnel_bold,
                  //       size: 16.sp,
                  //       color: AppTheme.primary,
                  //     ),
                  //     SizedBox(width: 4.w),
                  //     Text(
                  //       'All',
                  //       style: TextConstants.smallText.copyWith(
                  //         fontSize: 13.sp,
                  //         fontWeight: FontWeight.w600,
                  //         color: AppTheme.textPrimary,
                  //       ),
                  //     ),
                  //     SizedBox(width: 2.w),
                  //     Icon(
                  //       Icons.keyboard_arrow_down,
                  //       size: 16.sp,
                  //       color: AppTheme.textLight,
                  //     ),
                  //   ],
                  // ),
                  ),
            ],
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, EventProvider provider) {
    String tempSort = provider.sortBy;
    String tempCategory = provider.selectedCategory;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasChanges = tempSort != 'Upcoming' || tempCategory != 'All';

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag indicator
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: AppTheme.border,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),

                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sort & Filter',
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (hasChanges)
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempSort = 'Upcoming';
                                  tempCategory = 'All';
                                });
                              },
                              child: Text(
                                'Reset',
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Scrollable content
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Sort section
                            Text(
                              'Sort by',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ...provider.sortOptions.map((option) {
                              return _OptionTile(
                                title: option,
                                isSelected: tempSort == option,
                                onTap: () {
                                  setSheetState(() => tempSort = option);
                                },
                              );
                            }),

                            SizedBox(height: 8.h),
                            Divider(color: AppTheme.border, thickness: 1),
                            SizedBox(height: 8.h),

                            // Category section
                            Text(
                              'Category',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ...provider.eventCategories.map((option) {
                              return _OptionTile(
                                title: option,
                                isSelected: tempCategory == option,
                                onTap: () {
                                  setSheetState(() => tempCategory = option);
                                },
                              );
                            }),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),

                      // Done button
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                provider.changeSortBy(tempSort);
                                provider.changeCategory(tempCategory);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Done',
                                style: TextConstants.mediumText.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primary,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
