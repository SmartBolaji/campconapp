import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ServiceInfoCard extends StatelessWidget {
  final String? wageType;

  const ServiceInfoCard({
    Key? key,
    this.wageType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.info,
                color: AppTheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Service Information',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Wage Type Info
          if (wageType != null) ...[
            _buildInfoRow(
              icon: _getWageIcon(wageType!),
              label: 'Rate',
              value: _getWageTypeDisplay(wageType!),
            ),
            SizedBox(height: 8.h),
          ],

          _buildInfoRow(
            icon: Ph.clock,
            label: 'Duration',
            value: 'Discuss with provider',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            icon: Ph.shield_check,
            label: 'Protection',
            value: 'Secure escrow available',
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            icon: Ph.chat_circle_dots,
            label: 'Contact',
            value: 'Message to discuss details',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Iconify(
          icon,
          size: 16.sp,
          color: AppTheme.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getWageIcon(String wageType) {
    switch (wageType) {
      case 'hourly':
        return Ph.clock;
      case 'daily':
        return Ph.calendar;
      case 'weekly':
        return Ph.calendar_check;
      case 'monthly':
        return Ph.calendar_blank;
      case 'onetime':
        return Ph.currency_circle_dollar;
      default:
        return Ph.clock;
    }
  }

  String _getWageTypeDisplay(String wageType) {
    switch (wageType) {
      case 'hourly':
        return 'Hourly Rate';
      case 'daily':
        return 'Daily Rate';
      case 'weekly':
        return 'Weekly Rate';
      case 'monthly':
        return 'Monthly Rate';
      case 'onetime':
        return 'One-time Fee';
      default:
        return 'Payment';
    }
  }
}
