import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ProductPriceInfo extends StatelessWidget {
  final Product product;
  final ProductProvider provider;

  const ProductPriceInfo({
    Key? key,
    required this.product,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextConstants.boldText.copyWith(
            fontSize: 22.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Show wage type for services
        if (!product.isItem && product.wageType != null) ...[
          _buildWageTypeChip(),
          SizedBox(height: 12.h),
        ],

        // Price with discount
        _buildPriceRow(),

        // Stock info for items
        if (product.isItem && product.stock != null) ...[
          SizedBox(height: 12.h),
          _buildStockInfo(),
        ],
      ],
    );
  }

  Widget _buildWageTypeChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(
            _getWageIcon(product.wageType!),
            size: 16.sp,
            color: AppTheme.primary,
          ),
          SizedBox(width: 8.w),
          Text(
            _getWageTypeDisplay(product.wageType!),
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        // Current price (with quantity for items)
        if (product.isItem) ...[
          Text(
            provider.quantity > 1
                ? '${product.formattedPrice} × ${provider.quantity}'
                : product.formattedPrice,
            style: TextConstants.mediumText.copyWith(
              fontSize: product.discount != null ? 20.sp : 18.sp,
              fontWeight:
                  product.discount != null ? FontWeight.bold : FontWeight.w600,
              color: product.discount != null
                  ? AppTheme.success
                  : AppTheme.textSecondary,
            ),
          ),
          if (provider.quantity > 1) ...[
            SizedBox(width: 8.w),
            Text(
              '= ${_formatPrice(provider.totalPrice)}',
              style: TextConstants.boldText.copyWith(
                fontSize: 20.sp,
                color: AppTheme.primary,
              ),
            ),
          ],
        ] else ...[
          // Service price with wage label
          Text(
            product.priceLabel ?? product.formattedPrice,
            style: TextConstants.boldText.copyWith(
              fontSize: 20.sp,
              color: AppTheme.primary,
            ),
          ),
        ],

        // Original price (if discounted)
        if (product.discount != null && product.discount! > 0) ...[
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.originalPriceFormatted,
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textLight,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppTheme.textLight,
                  decorationThickness: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${product.discount!.toInt()}% OFF',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStockInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: product.stock! > 0
            ? AppTheme.primary.withValues(alpha: 0.05)
            : AppTheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: product.stock! > 0
              ? AppTheme.primary.withValues(alpha: 0.3)
              : AppTheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(
            Ph.package,
            size: 16.sp,
            color: product.stock! > 0 ? AppTheme.primary : AppTheme.error,
          ),
          SizedBox(width: 8.w),
          Text(
            product.stock! > 0 ? '${product.stock} in stock' : 'Out of stock',
            style: TextConstants.mediumText.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: product.stock! > 0 ? AppTheme.primary : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
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
