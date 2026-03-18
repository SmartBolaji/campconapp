import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/edit_event_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/manage_event_screen.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class EventBottomAction extends StatelessWidget {
  final EventModel event;
  final bool isOrganizer;
  final VoidCallback onPurchase;

  const EventBottomAction({
    Key? key,
    required this.event,
    required this.isOrganizer,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPastEvent = event.eventDate.isBefore(DateTime.now());
    final showTicketPurchase = event.sellOnCampcon &&
        !event.isFree &&
        !event.isSoldOut &&
        !isOrganizer;

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: _buildActionContent(
            context,
            eventProvider,
            isPastEvent,
            showTicketPurchase,
          ),
        );
      },
    );
  }

  Widget _buildActionContent(
    BuildContext context,
    EventProvider eventProvider,
    bool isPastEvent,
    bool showTicketPurchase,
  ) {
    // Organizer actions
    if (isOrganizer) {
      return _buildOrganizerActions();
    }

    // Past event
    if (isPastEvent) {
      return _buildPastEventAction();
    }

    // Ticket purchase flow
    if (showTicketPurchase) {
      return _buildTicketPurchaseActions(eventProvider);
    }

    // Sold out
    if (event.sellOnCampcon && event.isSoldOut) {
      return _buildSoldOutAction();
    }

    // Default: No bottom action for free/external events (attend is in AttendeeStatsCard)
    return const SizedBox.shrink();
  }

  Widget _buildOrganizerActions() {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Edit Event',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEventScreen(event: event),
                    ),
                  );
                },
                backgroundColor: AppTheme.buttonBorder,
                textColor: AppTheme.textPrimary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(
                text: 'Manage Event',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageEventScreen(event: event),
                    ),
                  );
                },
                backgroundColor: AppTheme.primary,
                textColor: AppTheme.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPastEventAction() {
    return CustomButton(
      text: 'Event Ended',
      onPressed: () {},
      backgroundColor: AppTheme.buttonBorder,
      textColor: AppTheme.textLight,
      useWidth: false,
    );
  }

  Widget _buildTicketPurchaseActions(EventProvider eventProvider) {
    final canPurchase = eventProvider.canPurchase;
    final quantity = eventProvider.ticketQuantity;
    final selectedTier = eventProvider.getSelectedTier(event);
    final unitPrice = selectedTier?.price ?? event.ticketPrice ?? 0;
    final totalPrice = unitPrice * quantity;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tickets available indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: event.availableTickets < 10
                ? AppTheme.warning.withValues(alpha: 0.1)
                : AppTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: event.availableTickets < 10
                  ? AppTheme.warning.withValues(alpha: 0.3)
                  : AppTheme.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(
                Ph.ticket,
                size: 16.sp,
                color: event.availableTickets < 10
                    ? AppTheme.warning
                    : AppTheme.success,
              ),
              SizedBox(width: 6.w),
              Text(
                '${event.availableTickets} tickets remaining',
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: event.availableTickets < 10
                      ? AppTheme.warning
                      : AppTheme.success,
                ),
              ),
            ],
          ),
        ),

        // Purchase button
        if (canPurchase)
          CustomButton(
            text: canPurchase
                ? 'Get $quantity Ticket${quantity > 1 ? 's' : ''} — ${_formatPrice(totalPrice)}'
                : 'Select Payment Method',
            onPressed: canPurchase ? onPurchase : () {},
            backgroundColor:
                canPurchase ? AppTheme.primary : AppTheme.buttonBorder,
            textColor: canPurchase ? AppTheme.white : AppTheme.textLight,
            icon: canPurchase ? Ph.shopping_cart : null,
            useWidth: false,
          ),
      ],
    );
  }

  Widget _buildSoldOutAction() {
    return CustomButton(
      text: 'Sold Out',
      onPressed: () {},
      backgroundColor: AppTheme.buttonBorder,
      textColor: AppTheme.textLight,
      useWidth: false,
    );
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
