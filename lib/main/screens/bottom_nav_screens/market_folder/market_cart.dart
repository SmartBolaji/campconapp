import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/order_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/buyer_orders_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/order_detail_screen.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class MarketCartScreen extends StatefulWidget {
  const MarketCartScreen({super.key});

  @override
  State<MarketCartScreen> createState() => _MarketCartScreenState();
}

class _MarketCartScreenState extends State<MarketCartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BuyerOrdersProvider _buyerOrdersProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _buyerOrdersProvider =
        Provider.of<BuyerOrdersProvider>(context, listen: false);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _buyerOrdersProvider.setSelectedTab(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrders();
    });
  }

  void _initializeOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final buyerId = authProvider.currentUser?.uid;
    if (buyerId != null) {
      _buyerOrdersProvider.initialize(buyerId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<BuyerOrdersProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildHeader(),
                _buildTabBar(provider),
                Expanded(
                  child: provider.isLoading
                      ? _buildLoading()
                      : provider.error != null
                          ? _buildError(provider.error!)
                          : _buildOrdersList(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                'My Orders',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () => _buyerOrdersProvider.refresh(),
          //   child: Iconify(
          //     Ph.arrows_clockwise,
          //     color: AppTheme.textPrimary,
          //     size: 22.sp,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuyerOrdersProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 2,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: TextConstants.smallText.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
        unselectedLabelStyle: TextConstants.smallText.copyWith(
          fontSize: 13.sp,
        ),
        // dividerColor: AppTheme.border,
        dividerHeight: 0,
        tabs: [
          Tab(text: 'Active (${provider.activeOrders.length})'),
          const Tab(text: 'Completed'),
          const Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildError(String error) {
    debugPrint(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            Ph.warning_circle,
            size: 64.sp,
            color: AppTheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            error,
            style: TextConstants.mediumText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => _buyerOrdersProvider.refresh(),
            child: Text(
              'Retry',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuyerOrdersProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersTab(provider.activeOrders, provider, 'No active orders',
            showActions: true),
        _buildOrdersTab(
            provider.completedOrders, provider, 'No completed orders',
            showReview: true),
        _buildOrdersTab(
            provider.cancelledOrders, provider, 'No cancelled orders'),
      ],
    );
  }

  Widget _buildOrdersTab(
    List<OrderModel> orders,
    BuyerOrdersProvider provider,
    String emptyMessage, {
    bool showActions = false,
    bool showReview = false,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppTheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(
            orders[index],
            provider,
            showActions: showActions,
            showReview: showReview,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            Ph.shopping_bag,
            size: 64.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextConstants.boldText.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your orders will appear here',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    BuyerOrdersProvider provider, {
    bool showActions = false,
    bool showReview = false,
  }) {
    final seller = provider.getSeller(order.sellerId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(order: order, isSeller: false),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Order header with status
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: TextConstants.smallText.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDate(order.createdAt),
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
            ),

            // Order content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  // Product info
                  Row(
                    children: [
                      // Product image
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: AppTheme.buttonBorder,
                          borderRadius: BorderRadius.circular(8.r),
                          image: order.productImage != null
                              ? DecorationImage(
                                  image: NetworkImage(order.productImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: order.productImage == null
                            ? Center(
                                child: Iconify(
                                  Ph.package,
                                  size: 24.sp,
                                  color: AppTheme.textLight,
                                ),
                              )
                            : null,
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
                            SizedBox(height: 4.h),
                            Text(
                              'Qty: ${order.quantity} Ã— ${provider.formatCurrency(order.unitPrice)}',
                              style: TextConstants.smallText.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        order.formattedTotal,
                        style: TextConstants.boldText.copyWith(
                          fontSize: 16.sp,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: AppTheme.border, height: 1),
                  SizedBox(height: 12.h),

                  // Seller info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.1),
                        backgroundImage: seller?.profileImageUrl != null
                            ? NetworkImage(seller!.profileImageUrl!)
                            : null,
                        child: seller?.profileImageUrl == null
                            ? Iconify(
                                Ph.storefront,
                                size: 18.sp,
                                color: AppTheme.primary,
                              )
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller?.name ?? order.sellerName,
                              style: TextConstants.smallText.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Seller',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 11.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openChat(order, seller),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Iconify(
                            Ph.chat_circle_dots,
                            size: 20.sp,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Order progress tracker
                  if (order.isActive) ...[
                    _buildProgressTracker(order),
                    SizedBox(height: 12.h),
                  ],

                  // Order details
                  _buildOrderDetailRow(
                    icon: Ph.map_pin,
                    label: 'Pickup',
                    value: order.pickupLocation,
                  ),
                  SizedBox(height: 6.h),
                  _buildOrderDetailRow(
                    icon: Ph.credit_card,
                    label: 'Payment',
                    value: order.paymentMethod == 'online'
                        ? 'Pay Online'
                        : 'Pay on Pickup',
                  ),

                  // Cancellation reason if cancelled
                  if (order.isCancelled &&
                      order.cancellationReason != null) ...[
                    SizedBox(height: 6.h),
                    _buildOrderDetailRow(
                      icon: Ph.info,
                      label: 'Reason',
                      value: order.cancellationReason!,
                    ),
                  ],

                  // Action buttons
                  if (showActions && order.isActive) ...[
                    SizedBox(height: 16.h),
                    _buildBuyerActions(order, provider),
                  ],

                  // Review button for completed orders
                  if (showReview && order.isCompleted) ...[
                    SizedBox(height: 16.h),
                    _buildReviewButton(order, provider),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTracker(OrderModel order) {
    final steps = [
      {'status': OrderStatus.pending, 'label': 'Placed'},
      {'status': OrderStatus.confirmed, 'label': 'Confirmed'},
      {'status': OrderStatus.processing, 'label': 'Processing'},
      {'status': OrderStatus.ready, 'label': 'Ready'},
    ];

    int currentStep = 0;
    for (int i = 0; i < steps.length; i++) {
      if (order.status == steps[i]['status'] ||
          order.status.index > (steps[i]['status'] as OrderStatus).index) {
        currentStep = i;
      }
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex <= currentStep;
                final isCurrent = stepIndex == currentStep;

                return Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppTheme.primary : AppTheme.border,
                    border: isCurrent
                        ? Border.all(color: AppTheme.primary, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 14.sp,
                          color: AppTheme.white,
                        )
                      : null,
                );
              } else {
                final lineIndex = index ~/ 2;
                final isCompleted = lineIndex < currentStep;

                return Expanded(
                  child: Container(
                    height: 2.h,
                    color: isCompleted ? AppTheme.primary : AppTheme.border,
                  ),
                );
              }
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              final stepStatus = step['status'] as OrderStatus;
              final isCompleted = order.status.index >= stepStatus.index;

              return Text(
                step['label'] as String,
                style: TextConstants.smallText.copyWith(
                  fontSize: 10.sp,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? AppTheme.primary : AppTheme.textLight,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case OrderStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        label = 'PENDING';
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        label = 'CONFIRMED';
        break;
      case OrderStatus.processing:
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        label = 'PROCESSING';
        break;
      case OrderStatus.ready:
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        label = 'READY';
        break;
      case OrderStatus.completed:
        bgColor = AppTheme.success.withValues(alpha: 0.1);
        textColor = AppTheme.success;
        label = 'COMPLETED';
        break;
      case OrderStatus.cancelled:
        bgColor = AppTheme.error.withValues(alpha: 0.1);
        textColor = AppTheme.error;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextConstants.smallText.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Iconify(
          icon,
          size: 14.sp,
          color: AppTheme.textLight,
        ),
        SizedBox(width: 6.w),
        Text(
          '$label: ',
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBuyerActions(OrderModel order, BuyerOrdersProvider provider) {
    // Cancel button only for pending orders
    if (order.isPending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(order, provider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Cancel Order',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Confirm received button for ready orders
    if (order.isReady) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _confirmReceived(order, provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(
                Ph.check_circle,
                size: 18.sp,
                color: AppTheme.white,
              ),
              SizedBox(width: 8.w),
              Text(
                'Confirm Received',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReviewButton(OrderModel order, BuyerOrdersProvider provider) {
    final hasReviewed = provider.hasReviewed(order.id);

    if (hasReviewed) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              Ph.check_circle,
              size: 18.sp,
              color: AppTheme.success,
            ),
            SizedBox(width: 8.w),
            Text(
              'Review Submitted',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showReviewDialog(order, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              Ph.star,
              size: 18.sp,
              color: AppTheme.white,
            ),
            SizedBox(width: 8.w),
            Text(
              'Leave a Review',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(OrderModel order, BuyerOrdersProvider provider) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'Are you sure you want to cancel this order?',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final reason = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : 'Cancelled by buyer';
              await provider.cancelOrder(order.id, reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel Order',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReceived(OrderModel order, BuyerOrdersProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Confirm Received',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Have you received this order? This action cannot be undone.',
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not Yet',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.confirmReceived(order.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Yes, Received',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(OrderModel order, BuyerOrdersProvider provider) {
    double rating = 5.0;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'Rate Your Experience',
              style: TextConstants.boldText.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How was your experience with this order?',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Star rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          rating = index + 1.0;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Iconify(
                          index < rating ? Ph.star_fill : Ph.star,
                          size: 32.sp,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8.h),
                Text(
                  _getRatingText(rating),
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 16.h),

                // Comment
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a review (optional)',
                    hintStyle: TextConstants.smallText.copyWith(
                      color: AppTheme.textLight,
                    ),
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
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: provider.isSubmittingReview
                    ? null
                    : () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        final currentUser = authProvider.currentUser;

                        if (currentUser == null) return;

                        Navigator.pop(context);

                        final success = await provider.submitReview(
                          orderId: order.id,
                          productId: order.productId,
                          sellerId: order.sellerId,
                          buyerName: currentUser.name ?? 'Anonymous',
                          buyerImage: currentUser.profileImageUrl,
                          rating: rating,
                          comment: commentController.text.trim().isNotEmpty
                              ? commentController.text.trim()
                              : null,
                        );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted successfully!'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Submit Review',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent!';
    if (rating >= 4) return 'Great!';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Poor';
  }

  void _openChat(OrderModel order, dynamic seller) {
    final sellerId = order.sellerId;
    NavigationHelper.openChat(context, otherUserId: sellerId);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
