import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class OrderSummarySheet extends StatelessWidget {
  final String productName;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final PickupCenterModel pickupCenter;
  final String paymentMethod;
  final String? orderNotes;
  final ProductProvider productProvider;
  final String buyerId;

  const OrderSummarySheet({
    Key? key,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.pickupCenter,
    required this.paymentMethod,
    this.orderNotes,
    required this.productProvider,
    required this.buyerId,
  }) : super(key: key);

  /// Show the order summary as a bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required String productName,
    required int quantity,
    required String unitPrice,
    required String totalPrice,
    required PickupCenterModel pickupCenter,
    required String paymentMethod,
    String? orderNotes,
    required ProductProvider productProvider,
    required String buyerId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderSummarySheet(
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        pickupCenter: pickupCenter,
        paymentMethod: paymentMethod,
        orderNotes: orderNotes,
        productProvider: productProvider,
        buyerId: buyerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(
                Ph.shopping_cart,
                color: AppTheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Confirm Order',
                style: TextConstants.boldText.copyWith(
                  fontSize: 20.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Order details
          _buildOrderDetail('Item', productName),
          _buildOrderDetail('Quantity', '$quantity'),
          _buildOrderDetail('Unit Price', unitPrice),
          _buildOrderDetail('Total', totalPrice, isTotal: true),

          Divider(color: AppTheme.border, height: 24.h),

          // Pickup center details
          _buildPickupCenterSection(),

          Divider(color: AppTheme.border, height: 24.h),

          _buildOrderDetail(
            'Payment',
            paymentMethod == 'online' ? 'Pay Online' : 'Pay on Pickup',
          ),

          // Order notes (if any)
          if (orderNotes != null && orderNotes!.isNotEmpty) ...[
            Divider(color: AppTheme.border, height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notes:',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                orderNotes!,
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],

          SizedBox(height: 24.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.border),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Confirm Order',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildPickupCenterSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(
                Ph.map_pin,
                size: 18.sp,
                color: AppTheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pickup Location',
                style: TextConstants.smallText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            pickupCenter.name,
            style: TextConstants.mediumText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            pickupCenter.fullAddress,
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Iconify(
                Ph.phone,
                size: 14.sp,
                color: AppTheme.textLight,
              ),
              SizedBox(width: 4.w),
              Text(
                pickupCenter.phoneNumber,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(width: 16.w),
              Iconify(
                Ph.clock,
                size: 14.sp,
                color: AppTheme.textLight,
              ),
              SizedBox(width: 4.w),
              Text(
                pickupCenter.operatingHours,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    // Close the bottom sheet
    Navigator.pop(context);

    // Place the order
    bool success = await productProvider.placeOrder(buyerId);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Iconify(
                  Ph.check_circle,
                  color: AppTheme.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                const Expanded(
                  child: Text('Order placed successfully!'),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        // Navigate back to marketplace
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.error ?? 'Failed to place order'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    }
  }

  Widget _buildOrderDetail(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 15.sp : 14.sp,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextConstants.mediumText.copyWith(
                fontWeight: FontWeight.w600,
                color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
                fontSize: isTotal ? 16.sp : 14.sp,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
