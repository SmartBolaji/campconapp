import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class QuantitySelector extends StatelessWidget {
  final ProductProvider provider;
  final int? stock;

  const QuantitySelector({
    Key? key,
    required this.provider,
    this.stock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxQuantity = stock ?? 99;
    final isOutOfStock = maxQuantity <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quantity',
              style: TextConstants.boldText.copyWith(
                fontSize: 16.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            if (stock != null)
              Text(
                'Max: $maxQuantity',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        if (isOutOfStock)
          _buildOutOfStockMessage()
        else
          _buildQuantityControls(maxQuantity),
      ],
    );
  }

  Widget _buildOutOfStockMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Iconify(
            Ph.warning,
            color: AppTheme.error,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'This item is currently out of stock',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(int maxQuantity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: provider.decrementQuantity,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: provider.quantity > 1
                    ? AppTheme.primary
                    : AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.minus,
                color:
                    provider.quantity > 1 ? AppTheme.white : AppTheme.textLight,
                size: 16.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${provider.quantity}',
                style: TextConstants.boldText.copyWith(
                  fontSize: 18.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: provider.quantity < maxQuantity
                ? provider.incrementQuantity
                : null,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: provider.quantity < maxQuantity
                    ? AppTheme.primary
                    : AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.plus,
                color: provider.quantity < maxQuantity
                    ? AppTheme.white
                    : AppTheme.textLight,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
