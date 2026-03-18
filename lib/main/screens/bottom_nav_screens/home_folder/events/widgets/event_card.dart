import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/event_description.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final double imageHeight;
  final bool isAttending;
  final bool isOwner;
  final VoidCallback onAttending;

  const EventCard({
    Key? key,
    required this.event,
    required this.imageHeight,
    required this.isAttending,
    this.isOwner = false,
    required this.onAttending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // border: borderWidth > 0
          //     ? Border.all(
          //         color: borderColor!,
          //         width: borderWidth,
          //       )
          //     : null,
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
                              ? CachedNetworkImage(
                                  imageUrl: event.imageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  cacheManager: CustomCacheManager(),
                                  placeholder: (context, url) => Container(
                                    color: AppTheme.primaryBackground,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
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
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  //  Owner Badge (top left, before date badge)
                  if (isOwner)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Iconify(
                              Ph.crown_fill,
                              size: 12.sp,
                              color: AppTheme.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Your Event',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Date Badge (adjusted position if owner)
                  Positioned(
                    top: isOwner
                        ? 42.h
                        : 8.h, //  Move down if owner badge exists
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
                            color: Colors.black.withValues(alpha: 0.2),
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
                  (isOwner)
                      ? const SizedBox.shrink()
                      : Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: event.isFree
                                  ? AppTheme.success
                                  : event.isSoldOut
                                      ? AppTheme.error
                                      : AppTheme.primary
                                          .withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: event.sellOnCampcon && !event.isFree
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!event.isSoldOut) ...[
                                        // SizedBox(height: 2.h),
                                        Text(
                                          '${event.availableTickets} left',
                                          style:
                                              TextConstants.smallText.copyWith(
                                            fontSize: 10.sp,
                                            color: AppTheme.white
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          'SOLD OUT',
                                          style:
                                              TextConstants.smallText.copyWith(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                    ],
                                  )
                                : Text(
                                    event.formattedPrice,
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.white,
                                    ),
                                  ),
                          ),
                        ),

                  // Action Buttons
                  // Positioned(
                  //   bottom: 8.h,
                  //   right: 8.w,
                  //   child: Row(
                  //     children: [
                  //       _ActionButton(
                  //         icon: Ph.star_fill,
                  //         isActive: isInterested,
                  //         onTap: onInterested,
                  //       ),
                  //       SizedBox(width: 6.w),
                  //       _ActionButton(
                  //         icon: Ph.calendar_check_fill,
                  //         isActive: isAttending,
                  //         onTap: onAttending,
                  //       ),
                  //     ],
                  //   ),
                  // ),
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

                  // Price
                  Row(
                    children: [
                      Iconify(
                        Ph.ticket,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        event.isFree ? 'Free' : event.formattedPrice,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

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
        color: AppTheme.textLight.withValues(alpha: 0.5),
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
