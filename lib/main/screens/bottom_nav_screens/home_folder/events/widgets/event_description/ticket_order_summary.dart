import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class TicketOrderSummary extends StatelessWidget {
  final EventModel event;
  final int quantity;
  final String paymentMethod;
  final double totalPrice;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isProcessing;

  const TicketOrderSummary({
    Key? key,
    required this.event,
    required this.quantity,
    required this.paymentMethod,
    required this.totalPrice,
    required this.onConfirm,
    required this.onCancel,
    this.isProcessing = false,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    required EventModel event,
    required int quantity,
    required String paymentMethod,
    required double totalPrice,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketOrderSummary(
        event: event,
        quantity: quantity,
        paymentMethod: paymentMethod,
        totalPrice: totalPrice,
        onConfirm: onConfirm,
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
              // Container(
              //   padding: EdgeInsets.all(12.w),
              //   decoration: BoxDecoration(
              //     color: AppTheme.primary.withOpacity(0.1),
              //     shape: BoxShape.circle,
              //   ),
              //   child: Iconify(
              //     Ph.ticket,
              //     color: AppTheme.primary,
              //     size: 24.sp,
              //   ),
              // ),
              // SizedBox(width: 12.w),
              Text(
                'Confirm Purchase',
                style: TextConstants.boldText.copyWith(
                  fontSize: 20.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Event Info Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    color: AppTheme.buttonBorder,
                    child: event.imageUrl != null
                        ? Image.network(
                            event.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextConstants.boldText.copyWith(
                          fontSize: 15.sp,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Iconify(
                            Ph.calendar_blank,
                            size: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            event.formattedDate,
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Iconify(
                            Ph.map_pin,
                            size: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
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

          SizedBox(height: 20.h),

          // Order Details
          _buildOrderDetail('Ticket Type', 'General Admission'),
          _buildOrderDetail(
              'Quantity', '$quantity ticket${quantity > 1 ? 's' : ''}'),
          _buildOrderDetail('Unit Price', event.formattedPrice),
          _buildOrderDetail('Payment', _getPaymentMethodDisplay()),

          Divider(color: AppTheme.border, height: 24.h),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextConstants.boldText.copyWith(
                  fontSize: 16.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _formatPrice(totalPrice),
                style: TextConstants.boldText.copyWith(
                  fontSize: 20.sp,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.border),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
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
                flex: 2,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Iconify(
                              Ph.lock_simple,
                              color: AppTheme.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Pay Now',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 16.sp,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Security Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(
                Ph.shield_check,
                size: 16.sp,
                color: AppTheme.success,
              ),
              SizedBox(width: 6.w),
              Text(
                'Secure payment powered by Paystack',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Iconify(
        Ph.calendar_blank,
        size: 24.sp,
        color: AppTheme.textLight,
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplay() {
    switch (paymentMethod) {
      // case 'card':
      //   return 'Card Payment';
      case 'pay_online':
        return 'Pay Online';
      case 'pay_at_venue':
        return 'Pay at Venue';
      default:
        return paymentMethod;
    }
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
