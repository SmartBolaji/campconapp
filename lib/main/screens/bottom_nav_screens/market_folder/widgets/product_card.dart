import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/product_decription.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductGridView extends StatelessWidget {
  final List<Product> products;

  const ProductGridView({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: EdgeInsets.all(20.w),
      physics: const AlwaysScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          // ✅ Vary image height based on position for visual interest
          imageHeight: _calculateImageHeight(index),
        );
      },
    );
  }

  // ✅ Calculate dynamic image height for variety
  double _calculateImageHeight(int index) {
    // Create visual interest with varying heights
    if (index % 7 == 0) return 180.h; // Tallest
    if (index % 5 == 0) return 160.h; // Tall
    if (index % 3 == 0) return 140.h; // Medium
    return 120.h; // Default/Short
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double imageHeight;
  final bool showOwnerBadge; // NEW

  const ProductCard({
    Key? key,
    required this.product,
    required this.imageHeight,
    this.showOwnerBadge = false, // NEW - default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Determine border color based on stock and discount
    Color? borderColor;
    double borderWidth = 0;

    if (product.discount != null && product.discount! > 0) {
      // Discounted items get green border
      borderColor = AppTheme.success;
      borderWidth = 2;
    } else if (product.stock != null &&
        product.stock! > 0 &&
        product.stock! <= 3) {
      // Low stock items get warning border
      borderColor = AppTheme.error.withOpacity(0.9);
      borderWidth = 2;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ProductDecription(product: product),
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
          mainAxisSize: MainAxisSize.min, // ✅ Only take needed space
          children: [
            // Product Image with fixed height
            SizedBox(
              height: imageHeight, // ✅ Fixed height based on index
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
                      child: product.imageFile != null
                          ? Image.file(
                              product.imageFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : product.imageUrl != null
                              ? Image.network(
                                  product.imageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                    ),
                  ),

                  // ✅ Gradient overlay for better badge visibility
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

                  // Discount Badge
                  if (product.discount != null && product.discount! > 0)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.success.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${product.discount!.toInt()}% OFF',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),

                  // Stock Badge
                  if (product.stock != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStockBadgeColor(),
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: _getStockBadgeColor().withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (product.stock! <= 3 && product.stock! > 0)
                              Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Icon(
                                  Icons.warning_rounded,
                                  size: 12.sp,
                                  color: AppTheme.white,
                                ),
                              ),
                            Text(
                              _getStockText(),
                              style: TextConstants.smallText.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Wage Type Badge for Services
                  if (!product.isItem && product.wageType != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getWageTypeLabel(product.wageType!),
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),

                  // Owner Badge
                  if (showOwnerBadge)
                    Positioned(
                      top: 8.w,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Your listing',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details - ✅ Compact and flexible
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    product.name,
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

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Current Price
                      Expanded(
                        child: Text(
                          product.priceLabel ?? product.formattedPrice,
                          style: TextConstants.smallText.copyWith(
                            fontSize: product.discount != null ? 14.sp : 13.sp,
                            fontWeight: product.discount != null
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: product.discount != null
                                ? AppTheme.success
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Original Price (if discounted)
                      if (product.discount != null && product.discount! > 0)
                        Text(
                          product.originalPriceFormatted,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 10.sp,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppTheme.textLight,
                            decorationThickness: 2,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Location
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Iconify(
                        Ph.map_pin,
                        size: 12.sp,
                        color: AppTheme.textLight,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          product.location,
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
        product.isItem ? Ph.shopping_bag : Ph.briefcase,
        size: 50.sp,
        color: AppTheme.textLight.withOpacity(0.5),
      ),
    );
  }

  // ✅ Get stock badge color based on stock level
  Color _getStockBadgeColor() {
    if (product.stock == null || product.stock! == 0) {
      return AppTheme.error.withOpacity(0.9);
    } else if (product.stock! <= 3) {
      return AppTheme.error.withOpacity(0.9);
    } else {
      return AppTheme.primary.withOpacity(0.9);
    }
  }

  // ✅ Get stock text based on stock level
  String _getStockText() {
    if (product.stock == null || product.stock! == 0) {
      return 'Out of stock';
    } else if (product.stock! == 1) {
      return 'Last one!';
    } else if (product.stock! <= 3) {
      return 'Only ${product.stock} left';
    } else {
      return '${product.stock} left';
    }
  }

  String _getWageTypeLabel(String wageType) {
    switch (wageType) {
      case 'hourly':
        return 'Hourly';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'onetime':
        return 'One-time';
      default:
        return wageType;
    }
  }
}
