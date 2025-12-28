import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PaymentMethodSelector extends StatelessWidget {
  final ProductProvider provider;

  const PaymentMethodSelector({
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
        ...provider.paymentMethods.map((method) {
          final isSelected = provider.selectedPaymentMethod == method.id;
          return _buildPaymentMethodCard(method, isSelected);
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, bool isSelected) {
    return GestureDetector(
      onTap: () => provider.setPaymentMethod(method.id),
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
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                method.id == 'online' ? Ph.credit_card : Ph.money,
                size: 20.sp,
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
              Iconify(
                Ph.check_circle_fill,
                color: AppTheme.primary,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
