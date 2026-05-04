import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class AdminProductCard extends StatelessWidget {
  final Product product;
  final bool isActionLoading;
  final VoidCallback? onDelete;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.isActionLoading,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final images = product.allImageUrls;
    final hasDiscount = product.discount != null &&
        product.discount! > 0 &&
        product.discountedPrice != null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              bottomLeft: Radius.circular(14.r),
            ),
            child: images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: images.first,
                    width: 100.w,
                    height: 130.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 100.w,
                      height: 130.h,
                      color: AppTheme.border,
                    ),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + type badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _typeBadge(),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Category
                  Row(
                    children: [
                      Iconify(Ph.tag, size: 11.r, color: AppTheme.textLight),
                      SizedBox(width: 4.w),
                      Text(
                        product.category,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Description
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),

                  SizedBox(height: 8.h),

                  // Price row
                  Row(
                    children: [
                      Text(
                        product.isItem
                            ? product.formattedPrice
                            : (product.priceLabel ?? product.formattedPrice),
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              hasDiscount ? AppTheme.success : AppTheme.primary,
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          product.originalPriceFormatted,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '-${product.discount!.toStringAsFixed(0)}%',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Stats row
                  Row(
                    children: [
                      if (product.isItem && product.stock != null)
                        _stockBadge(product.stock!),
                      if (product.averageRating != null &&
                          product.averageRating! > 0)
                        Padding(
                          padding: EdgeInsets.only(
                              left: product.isItem && product.stock != null
                                  ? 6.w
                                  : 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Iconify(Ph.star,
                                  size: 11.r, color: AppTheme.warning),
                              SizedBox(width: 3.w),
                              Text(
                                product.averageRating!.toStringAsFixed(1),
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 11.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (product.reviewCount != null &&
                                  product.reviewCount! > 0) ...[
                                Text(
                                  ' (${product.reviewCount})',
                                  style: TextConstants.smallText.copyWith(
                                    fontSize: 10.sp,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Footer: seller + location + delete
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // _metaRow(
                            //   Ph.user_circle,
                            //   product.sellerId.length > 14
                            //       ? '${product.sellerId.substring(0, 14)}…'
                            //       : product.sellerId,
                            // ),
                            if (product.location.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 3.h),
                                child: _metaRow(Ph.map_pin, product.location),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: isActionLoading
                            ? null
                            : () => _confirmDelete(context),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isActionLoading
                                ? AppTheme.border
                                : AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Iconify(
                            Ph.trash,
                            size: 15.r,
                            color: isActionLoading
                                ? AppTheme.textLight
                                : AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100.w,
      height: 130.h,
      color: AppTheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            product.isItem ? Ph.shopping_bag : Ph.briefcase,
            size: 28.r,
            color: AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  Widget _typeBadge() {
    final color = product.isItem ? AppTheme.info : AppTheme.primary;
    final icon = product.isItem ? Ph.shopping_bag : Ph.briefcase;
    final label = product.isItem ? 'Item' : 'Service';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, size: 10.r, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockBadge(int stock) {
    final color = stock == 0
        ? AppTheme.error
        : stock <= 5
            ? AppTheme.warning
            : AppTheme.success;
    final label = stock == 0
        ? 'Out of stock'
        : stock <= 5
            ? 'Low: $stock left'
            : 'In stock: $stock';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: TextConstants.smallText.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _metaRow(String icon, String text) {
    return Row(
      children: [
        Iconify(icon, size: 11.r, color: AppTheme.textLight),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              color: AppTheme.textLight,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete ${product.isItem ? 'Item' : 'Service'}?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          '"${product.name}" will be permanently removed from the marketplace.',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: Text(
              'Delete',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
