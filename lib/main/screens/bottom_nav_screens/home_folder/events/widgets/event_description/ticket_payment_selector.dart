import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class TicketPaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final String icon;

  const TicketPaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class TicketPaymentSelector extends StatelessWidget {
  const TicketPaymentSelector({Key? key}) : super(key: key);

  static const List<TicketPaymentMethod> paymentMethods = [
    // TicketPaymentMethod(
    //   id: 'card',
    //   title: 'Card Payment',
    //   subtitle: 'Pay with Debit/Credit Card',
    //   icon: Ph.credit_card,
    // ),
    TicketPaymentMethod(
      id: 'pay_online',
      title: 'Pay Online',
      subtitle: 'Secure online payment',
      icon: Ph.bank,
    ),
    TicketPaymentMethod(
      id: 'pay_at_venue',
      title: 'Pay at Venue',
      subtitle: 'Reserve now, pay at door',
      icon: Ph.map_pin,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final selectedMethod = eventProvider.selectedPaymentMethod;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Iconify(
                  Ph.credit_card,
                  size: 18.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Payment Method',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...paymentMethods.map((method) {
              final isSelected = selectedMethod == method.id;
              return _buildPaymentMethodCard(
                context,
                eventProvider,
                method,
                isSelected,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    EventProvider eventProvider,
    TicketPaymentMethod method,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => eventProvider.setPaymentMethod(method.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Iconify(
                method.icon,
                size: 22.sp,
                color: isSelected ? AppTheme.primary : AppTheme.textLight,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method.subtitle,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Iconify(
                  Ph.check,
                  color: AppTheme.white,
                  size: 14.sp,
                ),
              )
            else
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.border,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
