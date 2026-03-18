import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsCard extends StatelessWidget {
  final EventModel event;

  const EventDetailsCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context: context,
            icon: Ph.calendar_blank,
            label: 'Date',
            value: event.formattedDate,
            valueColor: AppTheme.textPrimary,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            context: context,
            icon: Ph.clock,
            label: 'Time',
            value: event.formattedTime,
            valueColor: AppTheme.textPrimary,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            context: context,
            icon: Ph.map_pin,
            label: 'Location',
            value: event.location,
            valueColor: AppTheme.primary,
            onTap: () => _openMaps(context),
            isLink: true,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            context: context,
            icon: Ph.graduation_cap,
            label: 'School',
            value: event.school,
            valueColor: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Iconify(
              icon,
              size: 20.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                    decoration: isLink ? TextDecoration.underline : null,
                    decorationColor: valueColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Iconify(
              Ph.arrow_square_out,
              size: 18.sp,
              color: AppTheme.primary,
            ),
        ],
      ),
    );
  }

  void _openMaps(BuildContext context) async {
    final query = Uri.encodeComponent(event.location);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening maps'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
