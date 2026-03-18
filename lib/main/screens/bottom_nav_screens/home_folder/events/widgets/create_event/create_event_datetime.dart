import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:campcon/main/widgets/themed_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateEventDateTime extends StatelessWidget {
  const CreateEventDateTime({Key? key}) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final provider = Provider.of<EventCreateProvider>(context, listen: false);

    final picked = await ThemedPickers.showDate(
      context,
      initialDate: provider.selectedDate,
    );

    if (picked != null) {
      provider.setSelectedDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final provider = Provider.of<EventCreateProvider>(context, listen: false);

    final picked = await ThemedPickers.showTime(
      context,
      initialTime: provider.selectedTime,
    );

    if (picked != null) {
      provider.setSelectedTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Iconify(
                    Ph.calendar_blank,
                    size: 20.sp,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Event Date & Time *',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.buttonBorder,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(provider.selectedDate!),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 13.sp,
                                color: provider.selectedDate == null
                                    ? AppTheme.textLight
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Iconify(
                              Ph.calendar,
                              size: 18.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.buttonBorder,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.selectedTime == null
                                  ? 'Select Time'
                                  : provider.selectedTime!.format(context),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 13.sp,
                                color: provider.selectedTime == null
                                    ? AppTheme.textLight
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Iconify(
                              Ph.clock,
                              size: 18.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
