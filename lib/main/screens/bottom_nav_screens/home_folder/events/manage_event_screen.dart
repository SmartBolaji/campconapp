import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ManageEventScreen extends StatefulWidget {
  final EventModel event;

  const ManageEventScreen({super.key, required this.event});

  @override
  State<ManageEventScreen> createState() => _ManageEventScreenState();
}

class _ManageEventScreenState extends State<ManageEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data
  List<Map<String, dynamic>> _attendees = [];
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoadingAttendees = true;
  bool _isLoadingPurchases = true;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    final attendees = await provider.getAttendees(widget.event.id);
    final purchases = await provider.getTicketPurchases(widget.event.id);

    if (mounted) {
      setState(() {
        _attendees = attendees;
        _purchases = purchases;
        _isLoadingAttendees = false;
        _isLoadingPurchases = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Manage Event',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
          ),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Attendees'),
            Tab(text: 'Check-In'),
            Tab(text: 'Earnings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAttendeesTab(),
          _buildCheckInTab(),
          _buildEarningsTab(),
        ],
      ),
    );
  }

  // ─── OVERVIEW TAB ───────────────────────────────────────

  Widget _buildOverviewTab() {
    final event = widget.event;
    final isPast = event.eventDate.isBefore(DateTime.now());
    final totalRevenue = _purchases.fold<double>(
        0, (sum, p) => sum + ((p['totalPrice'] as num?)?.toDouble() ?? 0));

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event summary card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl!,
                      cacheManager: CustomCacheManager(),
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        event.formattedDate,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isPast
                              ? AppTheme.textLight.withValues(alpha: 0.2)
                              : AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          isPast ? 'Ended' : 'Active',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isPast ? AppTheme.textLight : AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Quick stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Ph.users,
                  label: 'Attendees',
                  value: '${_attendees.length}',
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Ph.ticket,
                  label: 'Tickets Sold',
                  value: '${event.soldTickets}',
                  color: AppTheme.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Ph.currency_ngn,
                  label: 'Revenue',
                  value: _formatCurrency(totalRevenue),
                  color: AppTheme.success,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Ph.check_circle,
                  label: 'Checked In',
                  value:
                      '${_attendees.where((a) => a['checkedIn'] == true).length}',
                  color: AppTheme.warning,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Ticket availability
          if (!event.isFree && event.sellOnCampcon) ...[
            Text(
              'Ticket Availability',
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            if (event.hasMultipleTiers)
              ...event.ticketTiers.map((tier) => _buildTierProgress(tier))
            else
              _buildSimpleTicketProgress(event),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Iconify(icon, size: 22.sp, color: color),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextConstants.boldText.copyWith(
              fontSize: 20.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierProgress(TicketTier tier) {
    final progress = tier.stock > 0 ? tier.sold / tier.stock : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tier.name,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${tier.sold}/${tier.stock}',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppTheme.border,
                color: tier.isSoldOut ? AppTheme.error : AppTheme.primary,
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              tier.formattedPrice,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTicketProgress(EventModel event) {
    final total = event.totalTickets;
    final sold = event.soldTickets;
    final progress = total > 0 ? sold / total : 0.0;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'General Admission',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$sold/$total',
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.border,
              color: event.isSoldOut ? AppTheme.error : AppTheme.primary,
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            event.formattedPrice,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ─── ATTENDEES TAB ──────────────────────────────────────

  Widget _buildAttendeesTab() {
    if (_isLoadingAttendees) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final filtered = _searchQuery.isEmpty
        ? _attendees
        : _attendees.where((a) {
            final name = (a['userName'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      children: [
        // Header with count
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          child: Row(
            children: [
              Text(
                '${_attendees.length} Attendees',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Iconify(Ph.arrows_clockwise,
                    size: 20.sp, color: AppTheme.textSecondary),
                onPressed: () async {
                  setState(() => _isLoadingAttendees = true);
                  final provider =
                      Provider.of<EventProvider>(context, listen: false);
                  final attendees =
                      await provider.getAttendees(widget.event.id);
                  setState(() {
                    _attendees = attendees;
                    _isLoadingAttendees = false;
                  });
                },
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppTheme.border),
              color: AppTheme.buttonBorder,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search attendees...',
                hintStyle: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Iconify(Ph.magnifying_glass,
                      size: 18.sp, color: AppTheme.textLight),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(Ph.users, size: 48.sp, color: AppTheme.border),
                      SizedBox(height: 12.h),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No attendees yet'
                            : 'No results found',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 15.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    return _buildAttendeeCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(Map<String, dynamic> attendee) {
    final name = attendee['userName'] ?? 'Unknown';
    final avatar = attendee['userAvatar'] as String?;
    final checkedIn = attendee['checkedIn'] == true;
    final attendeeId = attendee['id'] as String;
    final timestamp = attendee['timestamp'];
    String joinedTime = '';
    if (timestamp is Timestamp) {
      joinedTime = timeago.format(timestamp.toDate());
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppTheme.primaryBackground,
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? CachedNetworkImageProvider(avatar,
                    cacheManager: CustomCacheManager())
                : null,
            child: avatar == null || avatar.isEmpty
                ? Iconify(Ph.user, size: 18.sp, color: AppTheme.primary)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (joinedTime.isNotEmpty)
                  Text(
                    'Joined $joinedTime',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
              ],
            ),
          ),
          // Check-in toggle
          GestureDetector(
            onTap: () async {
              final provider =
                  Provider.of<EventProvider>(context, listen: false);
              final success =
                  await provider.toggleCheckIn(widget.event.id, attendeeId);
              if (success) {
                setState(() {
                  attendee['checkedIn'] = !(attendee['checkedIn'] == true);
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: checkedIn
                    ? AppTheme.success.withValues(alpha: 0.15)
                    : AppTheme.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Iconify(
                    checkedIn ? Ph.check_circle_fill : Ph.circle,
                    size: 16.sp,
                    color: checkedIn ? AppTheme.success : AppTheme.textLight,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    checkedIn ? 'Checked In' : 'Not In',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: checkedIn ? AppTheme.success : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CHECK-IN TAB ───────────────────────────────────────

  Widget _buildCheckInTab() {
    return _CheckInTabContent(event: widget.event);
  }

  // ─── EARNINGS TAB ───────────────────────────────────────

  Widget _buildEarningsTab() {
    if (_isLoadingPurchases) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final totalRevenue = _purchases.fold<double>(
        0, (sum, p) => sum + ((p['totalPrice'] as num?)?.toDouble() ?? 0));

    // Breakdown by tier (if applicable)
    final tierBreakdown = <String, double>{};
    for (final p in _purchases) {
      final tier = (p['tierName'] ?? 'General Admission') as String;
      tierBreakdown[tier] = (tierBreakdown[tier] ?? 0) +
          ((p['totalPrice'] as num?)?.toDouble() ?? 0);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total revenue card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _formatCurrency(totalRevenue),
                  style: TextConstants.boldText.copyWith(
                    fontSize: 28.sp,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_purchases.length} ticket purchases',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Tier breakdown
          if (tierBreakdown.length > 1) ...[
            Text(
              'Revenue by Tier',
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            ...tierBreakdown.entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _formatCurrency(entry.value),
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 16.h),
          ],

          // Individual purchases
          Text(
            'Purchases',
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          if (_purchases.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Column(
                  children: [
                    Iconify(Ph.receipt, size: 48.sp, color: AppTheme.border),
                    SizedBox(height: 12.h),
                    Text(
                      'No purchases yet',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_purchases.length, (index) {
              return _buildPurchaseCard(_purchases[index]);
            }),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase) {
    final buyerName = purchase['userName'] ?? 'Unknown';
    final amount = (purchase['totalPrice'] as num?)?.toDouble() ?? 0;
    final quantity = purchase['quantity'] ?? 1;
    final method = purchase['paymentMethod'] ?? 'N/A';
    final purchasedAt = purchase['purchasedAt'];
    String dateStr = '';
    if (purchasedAt is Timestamp) {
      dateStr = DateFormat('MMM d, yyyy · h:mm a').format(purchasedAt.toDate());
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppTheme.primaryBackground,
            child: Iconify(Ph.user, size: 16.sp, color: AppTheme.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyerName,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$quantity ticket${quantity > 1 ? 's' : ''} · $method',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }
}

// ─── CHECK-IN TAB (Stateful for scanner) ────────────────

class _CheckInTabContent extends StatefulWidget {
  final EventModel event;

  const _CheckInTabContent({required this.event});

  @override
  State<_CheckInTabContent> createState() => _CheckInTabContentState();
}

class _CheckInTabContentState extends State<_CheckInTabContent> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  String? _lastResult;
  String? _lastStatus; // success, already, invalid, error
  String? _lastName;
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final ticketId = barcode.rawValue!;
    if (ticketId == _lastResult) return; // Avoid duplicate scans

    setState(() {
      _isProcessing = true;
      _lastResult = ticketId;
    });

    final provider = Provider.of<EventProvider>(context, listen: false);
    final result = await provider.checkInByTicketId(widget.event.id, ticketId);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastStatus = result?['status'];
        _lastName = result?['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scanner
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isScanning)
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleBarcode,
                  ),
                )
              else
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(Ph.camera, size: 48.sp, color: AppTheme.white),
                        SizedBox(height: 12.h),
                        Text(
                          'Scanner Paused',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 16.sp,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Scan overlay
              if (_isScanning)
                Container(
                  width: 250.w,
                  height: 250.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.8),
                        width: 2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),

              // Processing indicator
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
            ],
          ),
        ),

        // Result area
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_lastStatus == null) ...[
                  Iconify(Ph.qr_code, size: 48.sp, color: AppTheme.border),
                  SizedBox(height: 12.h),
                  Text(
                    'Point camera at a ticket QR code',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_lastStatus == 'success') ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Iconify(Ph.check_circle_fill,
                        size: 48.sp, color: AppTheme.success),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Checked In!',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.success,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _lastName ?? '',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ] else if (_lastStatus == 'already') ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Iconify(Ph.warning_circle_fill,
                        size: 48.sp, color: AppTheme.warning),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Already Checked In',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.warning,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _lastName ?? '',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Iconify(Ph.x_circle_fill,
                        size: 48.sp, color: AppTheme.error),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Invalid Ticket',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.error,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'This QR code is not recognized',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                // Scan Again button
                if (_lastStatus != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _lastStatus = null;
                        _lastResult = null;
                        _lastName = null;
                      });
                    },
                    icon: Iconify(Ph.arrow_counter_clockwise,
                        size: 18.sp, color: AppTheme.primary),
                    label: Text(
                      'Scan Again',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Toggle scanner
                TextButton.icon(
                  onPressed: () {
                    setState(() => _isScanning = !_isScanning);
                    if (_isScanning) {
                      _scannerController.start();
                    } else {
                      _scannerController.stop();
                    }
                  },
                  icon: Iconify(
                    _isScanning ? Ph.pause : Ph.play,
                    size: 18.sp,
                    color: AppTheme.textSecondary,
                  ),
                  label: Text(
                    _isScanning ? 'Pause Scanner' : 'Resume Scanner',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
