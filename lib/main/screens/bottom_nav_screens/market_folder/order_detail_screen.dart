import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/order_model.dart';
import 'package:campcon/main/provider/buyer_orders_provider.dart';
import 'package:campcon/main/provider/sales_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/review_screen.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  final bool isSeller;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.isSeller = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildOrderHeader(),
                  SizedBox(height: 16.h),
                  _buildProductSection(),
                  SizedBox(height: 16.h),
                  _buildTimeline(),
                  SizedBox(height: 16.h),
                  _buildPickupDetails(context),
                  SizedBox(height: 16.h),
                  _buildPaymentInfo(),
                  SizedBox(height: 16.h),
                  _buildPersonInfo(context),
                  if (order.orderNotes != null &&
                      order.orderNotes!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    _buildOrderNotes(),
                  ],
                  SizedBox(height: 24.h),
                  _buildActions(context),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Order Details',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ID copied'),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Iconify(
              Ph.copy,
              color: AppTheme.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Header ────────────────────────────────────────────────

  Widget _buildOrderHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: TextConstants.mediumText.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _fullDate(order.createdAt),
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case OrderStatus.processing:
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        break;
      case OrderStatus.ready:
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        break;
      case OrderStatus.completed:
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        break;
      case OrderStatus.cancelled:
        bgColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        status == OrderStatus.ready ? 'Ready' : status.name.toUpperCase(),
        style: TextConstants.smallText.copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ── Product Section ─────────────────────────────────────────────

  Widget _buildProductSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product',
            style: TextConstants.mediumText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Product image
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppTheme.buttonBorder,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: order.productImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: order.productImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(
                            child: Iconify(Ph.image,
                                size: 24.sp, color: AppTheme.textLight),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Iconify(Ph.image,
                                size: 24.sp, color: AppTheme.textLight),
                          ),
                        ),
                      )
                    : Center(
                        child: Iconify(
                          Ph.package,
                          size: 28.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      style: TextConstants.mediumText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _infoChip('Qty: ${order.quantity}'),
                        SizedBox(width: 8.w),
                        _infoChip(_formatCurrency(order.unitPrice) + '/unit'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextConstants.mediumText.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: TextConstants.boldText.copyWith(
                    fontSize: 18.sp,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextConstants.smallText.copyWith(
          fontSize: 11.sp,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  // ── Order Timeline ──────────────────────────────────────────────

  Widget _buildTimeline() {
    final steps = _getTimelineSteps();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Timeline',
            style: TextConstants.mediumText.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...steps.asMap().entries.map((e) {
            final isLast = e.key == steps.length - 1;
            return _buildTimelineStep(e.value, isLast);
          }),
        ],
      ),
    );
  }

  List<_TimelineStep> _getTimelineSteps() {
    final steps = <_TimelineStep>[];

    // Placed
    steps.add(_TimelineStep(
      title: 'Order Placed',
      time: order.createdAt,
      isCompleted: true,
      icon: Ph.shopping_cart,
    ));

    if (order.isCancelled) {
      steps.add(_TimelineStep(
        title: 'Cancelled',
        subtitle: order.cancellationReason,
        time: order.cancelledAt,
        isCompleted: true,
        icon: Ph.x_circle,
        isError: true,
      ));
      return steps;
    }

    // Confirmed
    final isConfirmed = order.isConfirmed ||
        order.isProcessing ||
        order.isReady ||
        order.isCompleted;
    steps.add(_TimelineStep(
      title: 'Confirmed',
      time: order.confirmedAt,
      isCompleted: isConfirmed,
      icon: Ph.check_circle,
    ));

    // Processing
    final isProcessing =
        order.isProcessing || order.isReady || order.isCompleted;
    steps.add(_TimelineStep(
      title: 'Processing',
      time: isProcessing ? (order.confirmedAt ?? order.createdAt) : null,
      isCompleted: isProcessing,
      icon: Ph.gear,
    ));

    // Ready
    final isReady = order.isReady || order.isCompleted;
    steps.add(_TimelineStep(
      title: 'Ready for Pickup',
      time: isReady ? (order.confirmedAt ?? order.createdAt) : null,
      isCompleted: isReady,
      icon: Ph.package,
    ));

    // Completed
    steps.add(_TimelineStep(
      title: 'Completed',
      time: order.completedAt,
      isCompleted: order.isCompleted,
      icon: Ph.check_circle,
    ));

    return steps;
  }

  Widget _buildTimelineStep(_TimelineStep step, bool isLast) {
    final color = step.isError
        ? AppTheme.error
        : step.isCompleted
            ? AppTheme.success
            : AppTheme.textLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Iconify(
                  step.icon,
                  size: 14.sp,
                  color: color,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36.h,
                color: step.isCompleted
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : AppTheme.border,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextConstants.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                    color: step.isCompleted
                        ? AppTheme.textPrimary
                        : AppTheme.textLight,
                    fontSize: 13.sp,
                  ),
                ),
                if (step.time != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _fullDate(step.time!),
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
                if (step.subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    step.subtitle!,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Pickup Details ──────────────────────────────────────────────

  Widget _buildPickupDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Ph.map_pin, size: 18.sp, color: AppTheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Pickup Details',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _detailRow('Center', order.pickupLocation),
          if (order.pickupAddress != null && order.pickupAddress!.isNotEmpty)
            _detailRow('Address', order.pickupAddress!),
          if (order.pickupPhone != null && order.pickupPhone!.isNotEmpty)
            _detailRow('Phone', order.pickupPhone!),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openMaps(order.pickupLocation),
              icon: Iconify(
                Ph.navigation_arrow,
                size: 16.sp,
                color: AppTheme.primary,
              ),
              label: Text(
                'Get Directions',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.primary),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment Info ────────────────────────────────────────────────

  Widget _buildPaymentInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Ph.credit_card, size: 18.sp, color: AppTheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Payment',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _detailRow(
            'Method',
            order.paymentMethod == 'online' ? 'Pay Online' : 'Pay on Pickup',
          ),
          _detailRow(
            'Status',
            order.isCompleted
                ? 'Paid'
                : order.paymentMethod == 'online'
                    ? 'Paid'
                    : 'Pending',
          ),
          _detailRow('Amount', order.formattedTotal),
        ],
      ),
    );
  }

  // ── Seller / Buyer Info ─────────────────────────────────────────

  Widget _buildPersonInfo(BuildContext context) {
    // If viewing as seller, show buyer info. If viewing as buyer, show seller info.
    final personName =
        isSeller ? (order.buyerName ?? 'Buyer') : order.sellerName;
    final personImage = isSeller ? order.buyerImage : null;
    final personId = isSeller ? order.buyerId : order.sellerId;
    final label = isSeller ? 'Buyer' : 'Seller';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Ph.user, size: 18.sp, color: AppTheme.primary),
              SizedBox(width: 8.w),
              Text(
                '$label Info',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                backgroundImage:
                    personImage != null ? NetworkImage(personImage) : null,
                child: personImage == null
                    ? Iconify(Ph.user, size: 22.sp, color: AppTheme.primary)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personName,
                      style: TextConstants.mediumText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      label,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    NavigationHelper.openChat(context, otherUserId: personId);
                  },
                  icon: Iconify(
                    Ph.chat_circle_dots,
                    size: 16.sp,
                    color: AppTheme.primary,
                  ),
                  label: Text(
                    'Message',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primary),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    NavigationHelper.openProfile(context, personId);
                  },
                  icon: Iconify(
                    Ph.user_circle,
                    size: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                  label: Text(
                    'View Profile',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.border),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Order Notes ─────────────────────────────────────────────────

  Widget _buildOrderNotes() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(Ph.note, size: 18.sp, color: AppTheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Order Notes',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            order.orderNotes!,
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    if (isSeller) {
      return _buildSellerActions(context);
    } else {
      return _buildBuyerActions(context);
    }
  }

  Widget _buildBuyerActions(BuildContext context) {
    final List<Widget> buttons = [];

    if (order.isPending) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showBuyerCancelDialog(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel Order',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (order.isReady) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _confirmReceived(context),
            icon: Iconify(Ph.check, size: 18.sp, color: AppTheme.white),
            label: Text(
              'Confirm Received',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      );
    }

    if (order.isCompleted && !order.hasReview) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(order: order),
                ),
              );
            },
            icon: Iconify(Ph.star, size: 18.sp, color: AppTheme.white),
            label: Text(
              'Leave a Review',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: buttons
          .map((b) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: b,
              ))
          .toList(),
    );
  }

  Widget _buildSellerActions(BuildContext context) {
    final List<Widget> buttons = [];

    if (order.isPending) {
      buttons.add(
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showSellerCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Decline',
                  style: TextConstants.mediumText.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateStatus(context, OrderStatus.confirmed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Accept',
                  style: TextConstants.mediumText.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (order.isConfirmed) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, OrderStatus.processing),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Start Processing',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (order.isProcessing) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, OrderStatus.ready),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Mark as Ready',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (order.isReady) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus(context, OrderStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Complete Order',
              style: TextConstants.mediumText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: buttons
          .map((b) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: b,
              ))
          .toList(),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fullDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  Future<void> _openMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _updateStatus(BuildContext context, OrderStatus status) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    salesProvider.updateOrderStatus(order.id, status).then((success) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    });
  }

  void _confirmReceived(BuildContext context) {
    final provider = Provider.of<BuyerOrdersProvider>(context, listen: false);
    provider.confirmReceived(order.id).then((success) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order confirmed as received!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    });
  }

  void _showBuyerCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Order',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Back',
              style: TextConstants.smallText
                  .copyWith(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<BuyerOrdersProvider>(context, listen: false);
              provider
                  .cancelOrder(order.id, 'Cancelled by buyer')
                  .then((success) {
                if (success) {
                  Navigator.pop(context);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel Order',
              style: TextConstants.smallText.copyWith(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSellerCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Order',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for cancelling this order:',
              style: TextConstants.smallText
                  .copyWith(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
                hintStyle:
                    TextConstants.smallText.copyWith(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Back',
              style: TextConstants.smallText
                  .copyWith(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                final salesProvider =
                    Provider.of<SalesProvider>(context, listen: false);
                salesProvider
                    .cancelOrder(order.id, reasonController.text.trim())
                    .then((success) {
                  if (success) {
                    Navigator.pop(context);
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel Order',
              style: TextConstants.smallText.copyWith(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final String? subtitle;
  final DateTime? time;
  final bool isCompleted;
  final String icon;
  final bool isError;

  _TimelineStep({
    required this.title,
    this.subtitle,
    this.time,
    required this.isCompleted,
    required this.icon,
    this.isError = false,
  });
}
