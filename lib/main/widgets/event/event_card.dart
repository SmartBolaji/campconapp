import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/events/event_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final double imageHeight;
  final bool isInterested;
  final bool isAttending;
  final VoidCallback onInterested;
  final VoidCallback onAttending;

  const EventCard({
    Key? key,
    required this.event,
    required this.imageHeight,
    required this.isInterested,
    required this.isAttending,
    required this.onInterested,
    required this.onAttending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Determine border color based on event status
    Color? borderColor;
    double borderWidth = 0;

    if (event.isFree) {
      borderColor = AppTheme.success;
      borderWidth = 2;
    } else if (event.eventDate
        .isBefore(DateTime.now().add(const Duration(days: 7)))) {
      borderColor = AppTheme.primary;
      borderWidth = 2;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: EventDescription(event: event),
            duration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12.r),
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor!,
                  width: borderWidth,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Event Image with fixed height
            SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBackground,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.r)),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(11.r)),
                      child: event.imageFile != null
                          ? Image.file(
                              event.imageFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : event.imageUrl != null
                              ? Image.network(
                                  event.imageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(11.r)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Date Badge
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.eventDate.day.toString(),
                            style: TextConstants.boldText.copyWith(
                              fontSize: 16.sp,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            _getMonthShort(event.eventDate.month),
                            style: TextConstants.smallText.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Price Badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: event.isFree
                            ? AppTheme.success
                            : AppTheme.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: (event.isFree
                                    ? AppTheme.success
                                    : AppTheme.primary)
                                .withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        event.formattedPrice,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),

                  // Action Buttons
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: Ph.star_fill,
                          isActive: isInterested,
                          onTap: onInterested,
                        ),
                        SizedBox(width: 6.w),
                        _ActionButton(
                          icon: Ph.calendar_check_fill,
                          isActive: isAttending,
                          onTap: onAttending,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Event Details
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Event Title
                  Text(
                    event.title,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),

                  // Time
                  Row(
                    children: [
                      Iconify(
                        Ph.clock,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        event.formattedTime,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Iconify(
                        Ph.map_pin,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Stats
                  Row(
                    children: [
                      Iconify(
                        Ph.users,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${event.interestedCount} interested',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 10.sp,
                          color: AppTheme.textSecondary,
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
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Iconify(
        Ph.calendar_blank,
        size: 50.sp,
        color: AppTheme.textLight.withOpacity(0.5),
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Iconify(
          icon,
          size: 16.sp,
          color: isActive ? AppTheme.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
