import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class EventHeroImage extends StatelessWidget {
  final EventModel event;

  const EventHeroImage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Image
        Container(
          height: 280.h,
          width: double.infinity,
          color: AppTheme.buttonBorder,
          child: _buildImage(),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),

        // Date Badge (Top Left)
        Positioned(
          top: 16.h,
          left: 16.w,
          child: _buildDateBadge(),
        ),

        // Status Badges (Top Right)
        Positioned(
          top: 16.h,
          right: 16.w,
          child: _buildStatusBadges(),
        ),

        // Price Badge (Bottom Right)
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: _buildPriceBadge(),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (event.imageFile != null) {
      return Image.file(
        event.imageFile!,
        fit: BoxFit.cover,
      );
    } else if (event.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: event.imageUrl!,
        fit: BoxFit.cover,
        cacheManager: CustomCacheManager(),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            Ph.calendar_blank,
            size: 80.sp,
            color: AppTheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'No image available',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            event.eventDate.day.toString(),
            style: TextConstants.boldText.copyWith(
              fontSize: 24.sp,
              color: AppTheme.primary,
            ),
          ),
          Text(
            _getMonthShort(event.eventDate.month),
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sold Out Badge
        if (event.sellOnCampcon && event.isSoldOut)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.x_circle,
                  color: AppTheme.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'SOLD OUT',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),

        // Low Tickets Warning
        if (event.sellOnCampcon &&
            !event.isSoldOut &&
            event.availableTickets < 10 &&
            event.availableTickets > 0) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.warning,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.warning,
                  color: AppTheme.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Only ${event.availableTickets} left!',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: event.isFree
            ? AppTheme.success
            : AppTheme.primary.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: (event.isFree ? AppTheme.success : AppTheme.primary)
                .withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(
            Ph.ticket,
            color: AppTheme.white,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            event.formattedPrice,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
          ),
        ],
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
