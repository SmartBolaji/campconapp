import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/ticket_confirmation_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/widgets/event_description/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:share_plus/share_plus.dart';

class EventDescription extends StatefulWidget {
  final EventModel event;

  const EventDescription({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDescription> createState() => _EventDescriptionState();
}

class _EventDescriptionState extends State<EventDescription> {
  @override
  void initState() {
    super.initState();
    // Reset ticket purchase state when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.resetTicketPurchase();
      eventProvider.fetchRelatedEvents(widget.event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final currentUserName = authProvider.currentUser?.username ?? '';
    final isOrganizer = currentUserId == widget.event.organizerId;

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Determine if we should show the ticket purchase flow
        final showTicketPurchase = widget.event.sellOnCampcon &&
            !widget.event.isFree &&
            !widget.event.isSoldOut &&
            !isOrganizer;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: EventBottomAction(
            event: widget.event,
            isOrganizer: isOrganizer,
            onPurchase: () => _showOrderSummary(
              eventProvider,
              currentUserId,
              currentUserName,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                EventHeader(onShare: _shareEvent),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Image with Date and Price Badges
                        EventHeroImage(event: widget.event),

                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Category
                              EventTitleSection(event: widget.event),
                              SizedBox(height: 20.h),

                              // Event Details Card (Date, Time, Location, School)
                              EventDetailsCard(event: widget.event),
                              SizedBox(height: 24.h),

                              // Description
                              EventDescriptionSection(
                                description: widget.event.description,
                              ),
                              SizedBox(height: 24.h),

                              // Organizer Info
                              OrganizerInfoCard(
                                organizerName: widget.event.organizerName,
                                onProfileTap: () {
                                  NavigationHelper.openProfile(
                                    context,
                                    widget.event.organizerId,
                                  );
                                },
                                onMessageTap: isOrganizer
                                    ? null
                                    : () {
                                        NavigationHelper.openChat(
                                          context,
                                          otherUserId: widget.event.organizerId,
                                        );
                                      },
                              ),
                              SizedBox(height: 24.h),

                              // Stats with Attend Button
                              AttendeeStatsCard(
                                event: widget.event,
                                currentUserId: currentUserId,
                                currentUserName: currentUserName,
                                isOrganizer: isOrganizer,
                              ),

                              // Ticket Purchase Section (for sellOnCampcon events)
                              if (showTicketPurchase) ...[
                                SizedBox(height: 24.h),
                                _buildTicketPurchaseSection(eventProvider),
                              ],

                              // External Ticket Link (for external ticket events)
                              if (!widget.event.sellOnCampcon &&
                                  widget.event.ticketLink != null &&
                                  widget.event.ticketLink!.isNotEmpty) ...[
                                SizedBox(height: 24.h),
                                TicketInfoCard(
                                  ticketLink: widget.event.ticketLink,
                                ),
                              ],

                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),

                        // Related Events section
                        _buildRelatedEvents(eventProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketPurchaseSection(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Iconify(
                  Ph.shopping_cart,
                  color: AppTheme.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Your Tickets',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Secure your spot now',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Ticket Tier Selector (for multi-tier events)
          if (widget.event.hasMultipleTiers) ...[
            TicketTierSelector(event: widget.event),
            SizedBox(height: 20.h),
          ],

          // Ticket Quantity Selector (uses Consumer internally)
          if (!widget.event.hasMultipleTiers)
            TicketQuantitySelector(event: widget.event),
          if (widget.event.hasMultipleTiers)
            TicketQuantitySelector(event: widget.event),

          SizedBox(height: 20.h),

          // Payment Method Selector (uses Consumer internally)
          const TicketPaymentSelector(),

          SizedBox(height: 20.h),

          // Order Summary Preview
          _buildOrderPreview(eventProvider),
        ],
      ),
    );
  }

  Widget _buildOrderPreview(EventProvider eventProvider) {
    final selectedTier = eventProvider.getSelectedTier(widget.event);
    final unitPrice = selectedTier?.price ?? widget.event.ticketPrice ?? 0;
    final totalPrice = unitPrice * eventProvider.ticketQuantity;
    final tierName = selectedTier?.name ?? 'General Admission';
    final formattedUnit =
        selectedTier?.formattedPrice ?? widget.event.formattedPrice;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          if (widget.event.hasMultipleTiers) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket Type',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  tierName,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '$formattedUnit × ${eventProvider.ticketQuantity}',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: AppTheme.border),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextConstants.boldText.copyWith(
                  fontSize: 16.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _formatPrice(totalPrice),
                style: TextConstants.boldText.copyWith(
                  fontSize: 18.sp,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderSummary(
    EventProvider eventProvider,
    String currentUserId,
    String currentUserName,
  ) {
    final selectedTier = eventProvider.getSelectedTier(widget.event);
    final unitPrice = selectedTier?.price ?? widget.event.ticketPrice ?? 0;
    final totalPrice = unitPrice * eventProvider.ticketQuantity;
    TicketOrderSummary.show(
      context,
      event: widget.event,
      quantity: eventProvider.ticketQuantity,
      paymentMethod: eventProvider.selectedPaymentMethod!,
      totalPrice: totalPrice,
      tierName: selectedTier?.name,
      tierPrice: selectedTier?.price,
      onConfirm: () {
        Navigator.pop(context);
        _processPurchase(
            eventProvider, totalPrice, currentUserId, currentUserName);
      },
    );
  }

  Future<void> _processPurchase(
    EventProvider eventProvider,
    double totalPrice,
    String currentUserId,
    String currentUserName,
  ) async {
    final quantity = eventProvider.ticketQuantity;
    final paymentMethod = eventProvider.selectedPaymentMethod ?? 'N/A';
    final selectedTier = eventProvider.getSelectedTier(widget.event);

    final ticketId = await eventProvider.processPurchase(
      eventId: widget.event.id,
      userId: currentUserId,
      userName: currentUserName,
      totalPrice: totalPrice,
    );

    if (!mounted) return;

    if (ticketId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketConfirmationScreen(
            event: widget.event,
            ticketId: ticketId,
            quantity: quantity,
            totalPrice: totalPrice,
            paymentMethod: paymentMethod,
            tierName: selectedTier?.name,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _buildRelatedEvents(EventProvider provider) {
    if (provider.isLoadingRelated) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (_, __) => Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonBorder,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.relatedEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Similar Events',
            style: TextConstants.boldText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 230.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: provider.relatedEvents.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final event = provider.relatedEvents[index];
              return _buildRelatedEventCard(event);
            },
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildRelatedEventCard(EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDescription(event: event),
          ),
        );
      },
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: event.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppTheme.buttonBorder,
                          child: Center(
                            child: Iconify(
                              Ph.calendar_blank,
                              size: 32.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppTheme.buttonBorder,
                          child: Center(
                            child: Iconify(
                              Ph.calendar_blank,
                              size: 32.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.buttonBorder,
                        child: Center(
                          child: Iconify(
                            Ph.calendar_blank,
                            size: 32.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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
                        size: 12.sp,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.formattedDate,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    event.isFree ? 'Free' : event.formattedPrice,
                    style: TextConstants.boldText.copyWith(
                      fontSize: 13.sp,
                      color: event.isFree ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareEvent() {
    final text = '''
${widget.event.title}

📅 ${widget.event.formattedDate} at ${widget.event.formattedTime}
📍 ${widget.event.location}
${widget.event.isFree ? '🎟️ Free Entry' : '🎟️ ${widget.event.formattedPrice}'}

${widget.event.description}

Get tickets on CampCon!
    ''';

    Share.share(text, subject: widget.event.title);
  }

  String _formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }
}
