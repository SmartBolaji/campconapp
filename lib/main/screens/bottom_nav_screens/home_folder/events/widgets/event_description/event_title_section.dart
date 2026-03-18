import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class EventTitleSection extends StatelessWidget {
  final EventModel event;

  const EventTitleSection({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Title
        Text(
          event.title,
          style: TextConstants.boldText.copyWith(
            fontSize: 24.sp,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        SizedBox(height: 12.h),

        // Category & Ticket Info Row
        Row(
          children: [
            // Category Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Iconify(
                    _getCategoryIcon(event.category),
                    size: 14.sp,
                    color: AppTheme.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    event.category,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Tickets Available Badge (for sellOnCampcon)
            if (event.sellOnCampcon && !event.isFree && !event.isSoldOut)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: event.availableTickets < 10
                      ? AppTheme.warning.withValues(alpha: 0.1)
                      : AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: event.availableTickets < 10
                        ? AppTheme.warning.withValues(alpha: 0.3)
                        : AppTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(
                      Ph.ticket,
                      size: 14.sp,
                      color: event.availableTickets < 10
                          ? AppTheme.warning
                          : AppTheme.success,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${event.availableTickets} left',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: event.availableTickets < 10
                            ? AppTheme.warning
                            : AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Ph.music_notes;
      case 'sports':
        return Ph.football;
      case 'academic':
        return Ph.graduation_cap;
      case 'social':
        return Ph.users_three;
      case 'workshop':
        return Ph.chalkboard_teacher;
      case 'party':
        return Ph.confetti;
      case 'competition':
        return Ph.trophy;
      default:
        return Ph.calendar_blank;
    }
  }
}
