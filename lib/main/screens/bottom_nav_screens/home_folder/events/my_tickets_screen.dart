import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Text('Please sign in to view tickets',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              Iconify(Ph.arrow_left, color: AppTheme.textPrimary, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Tickets',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserTickets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _buildTicketCard(context, tickets[index]);
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserTickets(String userId) async {
    try {
      // Query all events for tickets belonging to this user
      // We need to collectionGroup query across all events' tickets subcollections
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('purchasedAt', descending: true)
          .get();

      final tickets = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Fetch the parent event for display data
        final eventId = data['eventId'] as String?;
        if (eventId != null) {
          final eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();
          if (eventDoc.exists) {
            final eventData = eventDoc.data()!;
            data['eventTitle'] = eventData['title'] ?? '';
            data['eventDate'] = eventData['eventDate'];
            data['eventTime'] = eventData['eventTime'];
            data['eventLocation'] = eventData['location'] ?? '';
            data['eventImage'] = eventData['imageUrl'];
          }
        }

        tickets.add(data);
      }

      return tickets;
    } catch (e) {
      debugPrint('Error fetching user tickets: $e');
      return [];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(Ph.ticket, size: 60.sp, color: AppTheme.border),
          SizedBox(height: 16.h),
          Text(
            'No tickets yet',
            style: TextConstants.mediumText.copyWith(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Your purchased event tickets will appear here',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    final ticketId = (ticket['ticketId'] ?? ticket['id']) as String;
    final eventTitle = ticket['eventTitle'] ?? 'Event';
    final eventImage = ticket['eventImage'] as String?;
    final quantity = ticket['quantity'] ?? 1;
    final checkedIn = ticket['checkedIn'] == true;

    // Parse event date for status determination
    DateTime? eventDate;
    final eventDateVal = ticket['eventDate'];
    if (eventDateVal is Timestamp) {
      eventDate = eventDateVal.toDate();
    } else if (eventDateVal is String) {
      eventDate = DateTime.tryParse(eventDateVal);
    }

    final ticketStatus = _getTicketStatus(eventDate, checkedIn);

    // Format event date
    String eventDateStr = '';
    if (eventDate != null) {
      eventDateStr = DateFormat('MMM d, yyyy').format(eventDate);
    }

    return GestureDetector(
      onTap: () => _showTicketDetail(context, ticket),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Top section with event info
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  // Event image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: eventImage != null && eventImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: eventImage,
                            cacheManager: CustomCacheManager(),
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 56.w,
                            height: 56.w,
                            color: AppTheme.primaryBackground,
                            child: Iconify(Ph.calendar_blank,
                                size: 24.sp, color: AppTheme.primary),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventTitle,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        if (eventDateStr.isNotEmpty)
                          Row(
                            children: [
                              Iconify(Ph.calendar_blank,
                                  size: 12.sp, color: AppTheme.textLight),
                              SizedBox(width: 4.w),
                              Text(
                                eventDateStr,
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 12.sp,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(ticketStatus),
                ],
              ),
            ),

            // Dashed divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: List.generate(
                  40,
                  (index) => Expanded(
                    child: Container(
                      height: 1,
                      color:
                          index.isEven ? AppTheme.border : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom section with QR mini preview + ticket details
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  // Mini QR
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: QrImageView(
                      data: ticketId,
                      version: QrVersions.auto,
                      size: 40.w,
                      backgroundColor: Colors.white,
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
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '$quantity ticket${quantity > 1 ? 's' : ''}  •  $ticketId',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Iconify(Ph.caret_right,
                      size: 18.sp, color: AppTheme.textLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTicketStatus(DateTime? eventDate, bool checkedIn) {
    if (checkedIn) return 'used';
    if (eventDate == null) return 'upcoming';
    if (eventDate.isBefore(DateTime.now())) return 'expired';
    return 'upcoming';
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'used':
        color = AppTheme.info;
        label = 'Used';
        break;
      case 'expired':
        color = AppTheme.textLight;
        label = 'Expired';
        break;
      default:
        color = AppTheme.success;
        label = 'Upcoming';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextConstants.smallText.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showTicketDetail(BuildContext context, Map<String, dynamic> ticket) {
    final ticketId = (ticket['ticketId'] ?? ticket['id']) as String;
    final eventTitle = ticket['eventTitle'] ?? 'Event';
    final tierName = ticket['tierName'] as String?;
    final quantity = ticket['quantity'] ?? 1;
    final totalPrice = (ticket['totalPrice'] as num?)?.toDouble() ?? 0;
    final eventLocation = ticket['eventLocation'] ?? '';

    // Parse event date
    DateTime? eventDate;
    final eventDateVal = ticket['eventDate'];
    if (eventDateVal is Timestamp) {
      eventDate = eventDateVal.toDate();
    } else if (eventDateVal is String) {
      eventDate = DateTime.tryParse(eventDateVal);
    }

    String eventDateStr = '';
    if (eventDate != null) {
      eventDateStr = DateFormat('MMM d, yyyy • h:mm a').format(eventDate);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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

            Text(
              eventTitle,
              style: TextConstants.boldText.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            if (eventDateStr.isNotEmpty)
              Text(
                eventDateStr,
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            if (eventLocation.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                eventLocation,
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  color: AppTheme.textLight,
                ),
              ),
            ],

            SizedBox(height: 24.h),

            // Full QR code
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: QrImageView(
                data: ticketId,
                version: QrVersions.auto,
                size: 200.w,
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

            Text(
              ticketId,
              style: TextConstants.mediumText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 16.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(Ph.tag, tierName ?? 'General Admission'),
                _buildInfoChip(
                    Ph.hash, '$quantity ticket${quantity > 1 ? 's' : ''}'),
                if (totalPrice > 0)
                  _buildInfoChip(
                      Ph.currency_ngn, '₦${totalPrice.toStringAsFixed(0)}'),
              ],
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Iconify(icon, size: 14.sp, color: AppTheme.textLight),
        SizedBox(width: 4.w),
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
}
