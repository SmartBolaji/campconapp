import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class AttendeeStatsCard extends StatelessWidget {
  final EventModel event;
  final String currentUserId;
  final String currentUserName;
  final bool isOrganizer;

  const AttendeeStatsCard({
    Key? key,
    required this.event,
    required this.currentUserId,
    required this.currentUserName,
    this.isOrganizer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final isAttending = eventProvider.isAttending(event.id);
        final isPastEvent = event.eventDate.isBefore(DateTime.now());

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              // Stats Row
              Row(
                children: [
                  // Attending Count
                  Expanded(
                    child: _buildStatItem(
                      icon: Ph.users,
                      label: 'Attending',
                      value: event.attendingCount.toString(),
                      color: AppTheme.primary,
                    ),
                  ),

                  // Tickets Sold (only for sellOnCampcon)
                  if (event.sellOnCampcon && !event.isFree) ...[
                    Container(
                      width: 1,
                      height: 40.h,
                      color: AppTheme.border,
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Ph.ticket,
                        label: 'Tickets Sold',
                        value: event.soldTickets.toString(),
                        color: AppTheme.success,
                      ),
                    ),
                  ],

                  // Available Tickets (only for sellOnCampcon)
                  if (event.sellOnCampcon &&
                      !event.isFree &&
                      !event.isSoldOut) ...[
                    Container(
                      width: 1,
                      height: 40.h,
                      color: AppTheme.border,
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Ph.ticket,
                        label: 'Available',
                        value: event.availableTickets.toString(),
                        color: event.availableTickets < 10
                            ? AppTheme.warning
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              // Attend Button (only for non-organizers and non-past events)
              if (!isOrganizer && !isPastEvent
                  // &&
                  // (event.isFree || !event.sellOnCampcon)
                  ) ...[
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: currentUserId.isNotEmpty
                      ? () => eventProvider.toggleAttending(
                            event.id,
                            currentUserId,
                            currentUserName,
                          )
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isAttending
                          ? AppTheme.success.withValues(alpha: 0.1)
                          : AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isAttending
                            ? AppTheme.success.withValues(alpha: 0.3)
                            : AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(
                          isAttending ? Ph.check_circle_fill : Ph.calendar_plus,
                          size: 20.sp,
                          color:
                              isAttending ? AppTheme.success : AppTheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isAttending ? "You're Attending!" : "I'm Attending",
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isAttending
                                ? AppTheme.success
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Already attending indicator for paid events
              if (!isOrganizer &&
                  !isPastEvent &&
                  event.sellOnCampcon &&
                  !event.isFree &&
                  isAttending) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(
                        Ph.check_circle_fill,
                        size: 20.sp,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "You have a ticket!",
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              size: 20.sp,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              value,
              style: TextConstants.boldText.copyWith(
                fontSize: 20.sp,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
