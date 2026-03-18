import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PickupLocationSelector extends StatelessWidget {
  final ProductProvider provider;

  const PickupLocationSelector({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pickup Location',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (provider.isLoadingPickupCenters) {
      return _buildLoadingState();
    }

    if (!provider.hasPickupCenters) {
      return _buildEmptyState();
    }

    return _buildPickupCentersList();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Loading pickup centers...',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Iconify(
            Ph.warning_circle,
            size: 24.sp,
            color: AppTheme.error,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Pickup Centers Available',
                  style: TextConstants.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Please try again later or contact support',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCentersList() {
    return Column(
      children: provider.approvedPickupCenters.map((center) {
        final isSelected = provider.selectedPickupCenter?.id == center.id;
        return _buildPickupCenterCard(center, isSelected);
      }).toList(),
    );
  }

  Widget _buildPickupCenterCard(PickupCenterModel center, bool isSelected) {
    return GestureDetector(
      onTap: () => provider.setPickupLocation(center.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.05)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildTypeIcon(center.type),
            SizedBox(width: 12.w),
            Expanded(child: _buildCenterDetails(center)),
            SizedBox(width: 12.w),
            if (isSelected)
              Iconify(
                Ph.check_circle_fill,
                color: AppTheme.primary,
                size: 22.sp,
              )
            else
              _buildRadioIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return Container(
      width: 22.w,
      height: 22.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTypeIcon(PickupCenterType type) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: _getTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Iconify(
          _getTypeIcon(type),
          size: 20.sp,
          color: _getTypeColor(type),
        ),
      ),
    );
  }

  Widget _buildCenterDetails(PickupCenterModel center) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                center.name,
                style: TextConstants.smallText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (center.rating > 0) ...[
              SizedBox(width: 4.w),
              Row(
                children: [
                  Iconify(
                    Ph.star_fill,
                    size: 12.sp,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    center.rating.toStringAsFixed(1),
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          center.fullAddress,
          style: TextConstants.smallText.copyWith(
            fontSize: 11.sp,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            _buildInfoChip(Ph.clock, center.operatingHours),
            SizedBox(width: 8.w),
            _buildInfoChip(Ph.calendar, center.operatingDaysDisplay),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(
            icon,
            size: 10.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeIcon(PickupCenterType type) {
    switch (type) {
      case PickupCenterType.shop:
        return Ph.storefront;
      case PickupCenterType.warehouse:
        return Ph.house;
      case PickupCenterType.individual:
        return Ph.house;
    }
  }

  Color _getTypeColor(PickupCenterType type) {
    switch (type) {
      case PickupCenterType.shop:
        return AppTheme.success;
      case PickupCenterType.warehouse:
        return Colors.purple;
      case PickupCenterType.individual:
        return Colors.orange;
    }
  }
}
