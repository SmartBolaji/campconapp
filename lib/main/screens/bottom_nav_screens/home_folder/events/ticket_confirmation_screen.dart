import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TicketConfirmationScreen extends StatelessWidget {
  final EventModel event;
  final String ticketId;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final String? tierName;

  const TicketConfirmationScreen({
    super.key,
    required this.event,
    required this.ticketId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    this.tierName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Success icon
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Iconify(Ph.check_circle_fill,
                  size: 56.sp, color: AppTheme.success),
            ),
            SizedBox(height: 16.h),

            Text(
              'Purchase Successful!',
              style: TextConstants.boldText.copyWith(
                fontSize: 22.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your ticket has been confirmed',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),

            SizedBox(height: 32.h),

            // Ticket card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  // Event info
                  Text(
                    event.title,
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(Ph.calendar_blank,
                          size: 14.sp, color: AppTheme.textSecondary),
                      SizedBox(width: 4.w),
                      Text(
                        event.formattedDate,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Iconify(Ph.clock,
                          size: 14.sp, color: AppTheme.textSecondary),
                      SizedBox(width: 4.w),
                      Text(
                        event.formattedTime,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(Ph.map_pin,
                          size: 14.sp, color: AppTheme.textSecondary),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          event.location,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 13.sp,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Dashed divider
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          height: 1,
                          color: index.isEven
                              ? AppTheme.border
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // QR code
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: QrImageView(
                      data: ticketId,
                      version: QrVersions.auto,
                      size: 180.w,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Ticket reference
                  Text(
                    'Ticket ID',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SelectableText(
                    ticketId,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Ticket details
                  _buildDetailRow(
                    'Type',
                    tierName ?? 'General Admission',
                  ),
                  SizedBox(height: 6.h),
                  _buildDetailRow(
                    'Quantity',
                    '$quantity ticket${quantity > 1 ? 's' : ''}',
                  ),
                  SizedBox(height: 6.h),
                  _buildDetailRow(
                    'Total',
                    '₦${totalPrice.toStringAsFixed(0)}',
                  ),
                  SizedBox(height: 6.h),
                  _buildDetailRow('Payment', paymentMethod),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareTicket(context),
                    icon: Iconify(Ph.share_network,
                        size: 18.sp, color: AppTheme.textPrimary),
                    label: Text(
                      'Share Ticket',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.border),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextConstants.mediumText.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _shareTicket(BuildContext context) {
    final text = '''
🎫 My Ticket for ${event.title}

📅 ${event.formattedDate} at ${event.formattedTime}
📍 ${event.location}

Ticket ID: $ticketId
Type: ${tierName ?? 'General Admission'}
Quantity: $quantity

See you there! 🎉
''';
    Share.share(text);
  }
}
