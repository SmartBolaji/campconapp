import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/models/report_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/widgets/event_description/widgets.dart';
import 'package:campcon/main/widgets/report_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
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
      Provider.of<EventProvider>(context, listen: false).resetTicketPurchase();
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
          backgroundColor: AppTheme.surface,
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
                                onMessageTap: isOrganizer
                                    ? null
                                    : () {
                                        // TODO: Navigate to chat
                                      },
                              ),
                              SizedBox(height: 24.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  ReportBottomSheet.show(
                                    context: context,
                                    targetTitle: widget.event.title,

                                    reportType: ReportType.event,
                                    targetId: widget.event.id,
                                    targetDescription: widget
                                            .event.description.isNotEmpty
                                        ? widget.event.description.length > 50
                                            ? '${widget.event.description.substring(0, 50)}...'
                                            : widget.event.description
                                        : 'Event by ${widget.event.organizerName}',
                                    targetImageUrl:
                                        widget.event.imageUrl?.isNotEmpty ??
                                                false
                                            ? widget.event.imageUrl!
                                            : null,
                                    reporterId: widget.event.organizerId,
                                    // Replace with actual user ID
                                    reporterName: FirebaseAuth.instance
                                            .currentUser!.displayName ??
                                        'Anonymous User', // Replace with actual user name
                                    school: widget.event.school,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.primary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        child: Iconify(
                                          Ph.warning_circle,
                                          size: 20.sp,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Report Event',
                                        style:
                                            TextConstants.mediumText.copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                EventBottomAction(
                  event: widget.event,
                  isOrganizer: isOrganizer,
                  onPurchase: () => _showOrderSummary(
                    eventProvider,
                    currentUserId,
                    currentUserName,
                  ),
                ),
                SizedBox(height: 20),
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
        color: AppTheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.15),
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
                  color: AppTheme.primary.withOpacity(0.1),
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

          // Ticket Quantity Selector (uses Consumer internally)
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
    final unitPrice = widget.event.ticketPrice ?? 0;
    final totalPrice = unitPrice * eventProvider.ticketQuantity;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
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
                '${widget.event.formattedPrice} × ${eventProvider.ticketQuantity}',
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
    final totalPrice =
        (widget.event.ticketPrice ?? 0) * eventProvider.ticketQuantity;
    TicketOrderSummary.show(
      context,
      event: widget.event,
      quantity: eventProvider.ticketQuantity,
      paymentMethod: eventProvider.selectedPaymentMethod!,
      totalPrice: totalPrice,
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
    final success = await eventProvider.processPurchase(
      eventId: widget.event.id,
      userId: currentUserId,
      userName: currentUserName,
      totalPrice: totalPrice,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Iconify(Ph.check_circle, color: AppTheme.white),
              SizedBox(width: 8.w),
              Text(
                'Ticket purchase successful!',
                style: TextConstants.mediumText.copyWith(
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reset is handled by the provider after successful purchase
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
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
