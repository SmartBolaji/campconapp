import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class CreateEventPricing extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController ticketStockController;
  final TextEditingController ticketLinkController;

  const CreateEventPricing({
    Key? key,
    required this.priceController,
    required this.ticketStockController,
    required this.ticketLinkController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Pricing toggle section
            _buildPricingToggle(provider),

            // Ticket stock section (sell on campcon)
            if (!provider.isFree) ...[
              SizedBox(height: 20.h),
              _buildTicketStockSection(provider),
            ],

            // External ticket link (only if NOT selling on campcon)
            if (!provider.sellOnCampcon || provider.isFree) ...[
              SizedBox(height: 16.h),
              _buildTicketLinkSection(provider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPricingToggle(EventCreateProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: provider.isFree
            ? AppTheme.success.withValues(alpha: 0.05)
            : AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: provider.isFree
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(
                Ph.ticket,
                size: 20.sp,
                color: provider.isFree ? AppTheme.success : AppTheme.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Pricing',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      provider.isFree
                          ? 'Free entry for all attendees'
                          : 'Paid tickets required',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isFree,
                onChanged: (value) {
                  provider.toggleIsFree(value);
                  if (value) {
                    priceController.clear();
                  }
                },
                activeColor: AppTheme.success,
              ),
            ],
          ),
          if (!provider.isFree && !provider.hasMultipleTiers) ...[
            SizedBox(height: 16.h),
            Text(
              'Ticket Price *',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    '₦',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter ticket price',
                        hintStyle: TextConstants.smallText.copyWith(
                          color: AppTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color: AppTheme.textLight,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'This price will be used if no external ticket link is provided',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketStockSection(EventCreateProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: provider.sellOnCampcon
            ? AppTheme.primary.withValues(alpha: 0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: provider.sellOnCampcon
              ? AppTheme.primary.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.storefront,
                size: 20.sp,
                color: provider.sellOnCampcon
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Tickets via Campcon',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      provider.sellOnCampcon
                          ? 'Enable in-app ticket sales — attendees can purchase securely on Campcon.'
                          : 'Manage ticket sales externally. Paste the external purchase link below if you have one.',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.sellOnCampcon,
                onChanged: (value) {
                  provider.toggleSellOnCampcon(value);
                  if (!value) {
                    ticketStockController.clear();
                  }
                },
                activeColor: AppTheme.primary,
              ),
            ],
          ),
          if (provider.sellOnCampcon && !provider.hasMultipleTiers) ...[
            SizedBox(height: 16.h),

            // Info box
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: AppTheme.success,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Attendees will purchase tickets through Campcon and you\'ll receive payouts (minus any platform or payment processing fees).',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Ticket quantity input
            Row(
              children: [
                Text(
                  'Ticket Quantity *',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                children: [
                  Iconify(
                    Ph.ticket,
                    size: 20.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: ticketStockController,
                      keyboardType: TextInputType.number,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Enter number of tickets available (e.g. 100)',
                        hintStyle: TextConstants.smallText.copyWith(
                          color: AppTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketLinkSection(EventCreateProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket Link (Optional)',
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    provider.isFree
                        ? 'Provide a registration or RSVP link so attendees can sign up (e.g. Google Forms, Typeform).'
                        : 'Paste the external ticket URL (Eventbrite, Selar, etc.) so attendees can purchase tickets.',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.buttonBorder,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: TextField(
              controller: ticketLinkController,
              keyboardType: TextInputType.url,
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: provider.isFree
                    ? 'https://forms.google.com/...'
                    : 'https://eventbrite.com/your-event',
                hintStyle: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
