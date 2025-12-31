import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class TicketQuantitySelector extends StatelessWidget {
  final EventModel event;

  const TicketQuantitySelector({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxQuantity = event.availableTickets.clamp(0, 10); // Max 10 per order
    final isOutOfStock = event.isSoldOut;

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final quantity = eventProvider.ticketQuantity;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Iconify(
                  Ph.ticket,
                  size: 18.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Number of Tickets',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Max ${maxQuantity > 10 ? 10 : maxQuantity}',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (isOutOfStock)
              _buildSoldOutMessage()
            else
              _buildQuantityControls(
                  context, eventProvider, quantity, maxQuantity),
          ],
        );
      },
    );
  }

  Widget _buildSoldOutMessage() {
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
            Ph.x_circle,
            color: AppTheme.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sold Out',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.error,
                  ),
                ),
                Text(
                  'This event is no longer accepting ticket purchases.',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.error.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    EventProvider eventProvider,
    int quantity,
    int maxQuantity,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Ticket type info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Iconify(
                  Ph.ticket,
                  color: AppTheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General Admission',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      event.formattedPrice,
                      style: TextConstants.boldText.copyWith(
                        fontSize: 16.sp,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Quantity controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quantity',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: Ph.minus,
                      onTap: quantity > 1
                          ? () => eventProvider.decrementTicketQuantity()
                          : null,
                      isEnabled: quantity > 1,
                    ),
                    Container(
                      width: 50.w,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: TextConstants.boldText.copyWith(
                          fontSize: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Ph.plus,
                      onTap: quantity < maxQuantity
                          ? () =>
                              eventProvider.incrementTicketQuantity(maxQuantity)
                          : null,
                      isEnabled: quantity < maxQuantity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required String icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Iconify(
          icon,
          size: 18.sp,
          color: isEnabled ? AppTheme.primary : AppTheme.textLight,
        ),
      ),
    );
  }
}
