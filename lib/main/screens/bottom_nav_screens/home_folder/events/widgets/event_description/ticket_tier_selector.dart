import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class TicketTierSelector extends StatelessWidget {
  final EventModel event;

  const TicketTierSelector({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!event.hasMultipleTiers || event.ticketTiers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Iconify(Ph.stack, size: 18.sp, color: AppTheme.primary),
                SizedBox(width: 8.w),
                Text(
                  'Select Ticket Type',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...event.ticketTiers.asMap().entries.map((entry) {
              final index = entry.key;
              final tier = entry.value;
              final isSelected = provider.selectedTierIndex == index;
              final isAvailable = !tier.isSoldOut;

              return GestureDetector(
                onTap: isAvailable ? () => provider.selectTier(index) : null,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.05)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : isAvailable
                              ? AppTheme.border
                              : AppTheme.error.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Selection indicator
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textLight,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: 14.w),

                      // Tier info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tier.name,
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isAvailable
                                          ? AppTheme.textPrimary
                                          : AppTheme.textLight,
                                    ),
                                  ),
                                ),
                                Text(
                                  tier.formattedPrice,
                                  style: TextConstants.boldText.copyWith(
                                    fontSize: 16.sp,
                                    color: isAvailable
                                        ? AppTheme.primary
                                        : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                            if (tier.description.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                tier.description,
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 13.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                if (tier.isSoldOut)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'SOLD OUT',
                                      style: TextConstants.smallText.copyWith(
                                        fontSize: 10.sp,
                                        color: AppTheme.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    '${tier.available} remaining',
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 12.sp,
                                      color: tier.available < 10
                                          ? AppTheme.error
                                          : AppTheme.textLight,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
