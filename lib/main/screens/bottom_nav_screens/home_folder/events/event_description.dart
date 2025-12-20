import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isOrganizer = currentUserId == widget.event.organizerId;

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final isInterested = eventProvider.isInterested(widget.event.id);
        final isAttending = eventProvider.isAttending(widget.event.id);

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(eventProvider),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEventImage(),
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEventTitle(),
                              SizedBox(height: 16.h),
                              _buildEventDetails(),
                              SizedBox(height: 24.h),
                              _buildDescription(),
                              SizedBox(height: 24.h),
                              _buildOrganizerInfo(),
                              SizedBox(height: 24.h),
                              _buildAttendeeStats(),
                              if (widget.event.ticketLink != null &&
                                  widget.event.ticketLink!.isNotEmpty) ...[
                                SizedBox(height: 24.h),
                                _buildTicketInfo(),
                              ],
                              SizedBox(height: 80.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomAction(
                  isOrganizer,
                  isInterested,
                  isAttending,
                  eventProvider,
                  currentUserId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.arrow_left,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Event Details',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _shareEvent(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.share_network,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage() {
    return Stack(
      children: [
        Container(
          height: 280.h,
          width: double.infinity,
          color: AppTheme.buttonBorder,
          child: widget.event.imageFile != null
              ? Image.file(
                  widget.event.imageFile!,
                  fit: BoxFit.cover,
                )
              : widget.event.imageUrl != null
                  ? Image.network(
                      widget.event.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        // Date Badge
        Positioned(
          top: 16.h,
          left: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.event.eventDate.day.toString(),
                  style: TextConstants.boldText.copyWith(
                    fontSize: 24.sp,
                    color: AppTheme.primary,
                  ),
                ),
                Text(
                  _getMonthShort(widget.event.eventDate.month),
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Price Badge
        Positioned(
          bottom: 16.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: widget.event.isFree
                  ? AppTheme.success
                  : AppTheme.primary.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: (widget.event.isFree
                          ? AppTheme.success
                          : AppTheme.primary)
                      .withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  Ph.ticket,
                  color: AppTheme.white,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.event.formattedPrice,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            Ph.calendar_blank,
            size: 80.sp,
            color: AppTheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'No image available',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event.title,
          style: TextConstants.boldText.copyWith(
            fontSize: 24.sp,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Iconify(
                _getCategoryIcon(widget.event.category),
                size: 14.sp,
                color: AppTheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                widget.event.category,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Ph.calendar_blank,
            label: 'Date',
            value: widget.event.formattedDate,
            valueColor: AppTheme.textPrimary,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Ph.clock,
            label: 'Time',
            value: widget.event.formattedTime,
            valueColor: AppTheme.textPrimary,
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Ph.map_pin,
            label: 'Location',
            value: widget.event.location,
            valueColor: AppTheme.textPrimary,
            onTap: () => _openMaps(),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            icon: Ph.graduation_cap,
            label: 'School',
            value: widget.event.school,
            valueColor: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String label,
    required String value,
    required Color valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Iconify(
              icon,
              size: 20.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Iconify(
              Ph.arrow_square_out,
              size: 18.sp,
              color: AppTheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final shouldShowMore = widget.event.description.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Event',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedCrossFade(
          firstChild: Text(
            widget.event.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.event.description,
            style: TextConstants.smallText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (shouldShowMore) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Read more',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrganizerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organizer',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Iconify(
                  Ph.user_circle,
                  color: AppTheme.primary,
                  size: 32.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.organizerName,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Event Organizer',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to organizer profile or contact
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Iconify(
                    Ph.chat_circle_dots,
                    color: AppTheme.primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Ph.star,
              label: 'Interested',
              value: widget.event.interestedCount.toString(),
              color: AppTheme.warning,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: AppTheme.border,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Ph.calendar_check,
              label: 'Attending',
              value: widget.event.attendingCount.toString(),
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              size: 20.sp,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              value,
              style: TextConstants.boldText.copyWith(
                fontSize: 20.sp,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(
                Ph.ticket,
                color: AppTheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Get Tickets',
                style: TextConstants.boldText.copyWith(
                  fontSize: 16.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => _openTicketLink(),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.event.ticketLink!,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Iconify(
                    Ph.arrow_square_out,
                    color: AppTheme.primary,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    bool isOrganizer,
    bool isInterested,
    bool isAttending,
    EventProvider eventProvider,
    String currentUserId,
  ) {
    final isPastEvent = widget.event.eventDate.isBefore(DateTime.now());

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isOrganizer
          ? Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit Event',
                    onPressed: () {
                      // TODO: Implement edit
                    },
                    backgroundColor: AppTheme.buttonBorder,
                    textColor: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: 'View Stats',
                    onPressed: () {
                      // TODO: Implement stats
                    },
                    backgroundColor: AppTheme.primary,
                    textColor: AppTheme.white,
                  ),
                ),
              ],
            )
          : isPastEvent
              ? CustomButton(
                  text: 'Event Ended',
                  onPressed: () {},
                  backgroundColor: AppTheme.buttonBorder,
                  textColor: AppTheme.textLight,
                )
              : widget.event.sellOnCampcon && !widget.event.isFree
                  // ✅ Show Purchase Button if selling on CampCon
                  ? Column(
                      children: [
                        if (!widget.event.isSoldOut) ...[
                          // Stock indicator
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: widget.event.availableTickets < 10
                                  ? AppTheme.warning.withOpacity(0.1)
                                  : AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: widget.event.availableTickets < 10
                                    ? AppTheme.warning.withOpacity(0.3)
                                    : AppTheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Iconify(
                                  Ph.ticket,
                                  size: 16.sp,
                                  color: widget.event.availableTickets < 10
                                      ? AppTheme.warning
                                      : AppTheme.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '${widget.event.availableTickets} tickets available',
                                  style: TextConstants.smallText.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: widget.event.availableTickets < 10
                                        ? AppTheme.warning
                                        : AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Purchase button
                        CustomButton(
                          text: widget.event.isSoldOut
                              ? 'Sold Out'
                              : 'Buy Ticket - ${widget.event.formattedPrice}',
                          onPressed: widget.event.isSoldOut
                              ? () {}
                              : () {
                                  // TODO: Implement ticket purchase
                                  _showPurchaseDialog();
                                },
                          backgroundColor: widget.event.isSoldOut
                              ? AppTheme.buttonBorder
                              : AppTheme.primary,
                          textColor: widget.event.isSoldOut
                              ? AppTheme.textLight
                              : AppTheme.white,
                          icon: Ph.shopping_cart,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: isInterested ? 'Interested ✓' : 'Interested',
                            onPressed: currentUserId.isNotEmpty
                                ? () => eventProvider.toggleInterested(
                                      widget.event.id,
                                      currentUserId,
                                    )
                                : () {},
                            backgroundColor: isInterested
                                ? AppTheme.warning.withOpacity(0.2)
                                : AppTheme.buttonBorder,
                            textColor: isInterested
                                ? AppTheme.warning
                                : AppTheme.textPrimary,
                            icon: Ph.star,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomButton(
                            text: isAttending ? 'Attending ✓' : 'Attend',
                            onPressed: currentUserId.isNotEmpty
                                ? () => eventProvider.toggleAttending(
                                      widget.event.id,
                                      currentUserId,
                                    )
                                : () {},
                            backgroundColor: isAttending
                                ? AppTheme.success
                                : AppTheme.primary,
                            textColor: AppTheme.white,
                            icon: Ph.calendar_check,
                          ),
                        ),
                      ],
                    ),
    );
  }

  // ✅ Add purchase dialog method
  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Ticket'),
        content: Text(
          'Ticket purchase functionality coming soon!\n\n'
          'You\'ll be able to securely purchase tickets for '
          '${widget.event.formattedPrice} through CampCon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getMonthShort(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Ph.music_notes;
      case 'sports':
        return Ph.football;
      case 'academic':
        return Ph.graduation_cap;
      case 'social':
        return Ph.users_three;
      case 'workshop':
        return Ph.chalkboard_teacher;
      case 'party':
        return Ph.confetti;
      case 'competition':
        return Ph.trophy;
      default:
        return Ph.calendar_blank;
    }
  }

  void _shareEvent() {
    final text = '''
${widget.event.title}

📅 ${widget.event.formattedDate} at ${widget.event.formattedTime}
📍 ${widget.event.location}
${widget.event.isFree ? '🎟️ Free Entry' : '🎟️ ${widget.event.formattedPrice}'}

${widget.event.description}
    ''';

    Share.share(text, subject: widget.event.title);
  }

  void _openMaps() async {
    final query = Uri.encodeComponent(widget.event.location);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening maps'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _openTicketLink() async {
    if (widget.event.ticketLink == null || widget.event.ticketLink!.isEmpty) {
      return;
    }

    final url = Uri.parse(widget.event.ticketLink!);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open ticket link'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid ticket link'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
