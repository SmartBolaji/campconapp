import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/order_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SalesProvider _salesProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _salesProvider = Provider.of<SalesProvider>(context, listen: false);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _salesProvider.setSelectedTab(_tabController.index);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSales();
    });
  }

  void _initializeSales() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sellerId = authProvider.currentUser?.uid;
    if (sellerId != null) {
      _salesProvider.initialize(sellerId);
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
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Consumer<SalesProvider>(
          builder: (context, salesProvider, child) {
            return Column(
              children: [
                _buildHeader(),
                if (!salesProvider.isLoading) _buildStatsCard(salesProvider),
                _buildTabBar(),
                Expanded(
                  child: salesProvider.isLoading
                      ? _buildLoading()
                      : salesProvider.error != null
                          ? _buildError(salesProvider.error!)
                          : _buildOrdersList(salesProvider),
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
                'My Sales',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _salesProvider.refresh(),
            child: Iconify(
              Ph.arrows_clockwise,
              color: AppTheme.textPrimary,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(SalesProvider provider) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Ph.currency_circle_dollar,
                  label: 'Total Revenue',
                  value: provider.formatCurrency(provider.totalRevenue),
                  isLight: true,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: AppTheme.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Ph.calendar_check,
                  label: 'Today',
                  value: provider.formatCurrency(provider.todayRevenue),
                  isLight: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            height: 1,
            color: AppTheme.white.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Ph.shopping_bag,
                  label: 'Total Sales',
                  value: '${provider.totalSales}',
                  isLight: true,
                ),
              ),
              Container(
                width: 1,
                height: 50.h,
                color: AppTheme.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Ph.clock,
                  label: 'Pending',
                  value: '${provider.pendingCount}',
                  isLight: true,
                  highlight: provider.pendingCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    bool isLight = false,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              size: 18.sp,
              color: isLight
                  ? AppTheme.white.withOpacity(0.8)
                  : AppTheme.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: isLight
                    ? AppTheme.white.withOpacity(0.8)
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: highlight
                ? Colors.amber
                : isLight
                    ? AppTheme.white
                    : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
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
        tabs: [
          Tab(text: 'Pending (${_salesProvider.pendingOrders.length})'),
          Tab(text: 'Active (${_salesProvider.activeOrders.length})'),
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
    print(error);
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
            onPressed: () => _salesProvider.refresh(),
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

  Widget _buildOrdersList(SalesProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOrdersTab(provider.pendingOrders, provider, 'No pending orders'),
        _buildOrdersTab(provider.activeOrders, provider, 'No active orders'),
        _buildOrdersTab(
            provider.completedOrders, provider, 'No completed orders'),
        _buildOrdersTab(
            provider.cancelledOrders, provider, 'No cancelled orders'),
      ],
    );
  }

  Widget _buildOrdersTab(
    List<OrderModel> orders,
    SalesProvider provider,
    String emptyMessage,
  ) {
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
          return _buildOrderCard(orders[index], provider);
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
            Ph.package,
            size: 64.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextConstants.mediumText.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, SalesProvider provider) {
    final buyer = provider.getBuyer(order.buyerId);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Order header
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
                            'Qty: ${order.quantity} × ${provider.formatCurrency(order.unitPrice)}',
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

                // Buyer info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      backgroundImage: buyer?.profileImageUrl != null
                          ? NetworkImage(buyer!.profileImageUrl!)
                          : null,
                      child: buyer?.profileImageUrl == null
                          ? Iconify(
                              Ph.user,
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
                            buyer?.name ?? order.buyerName ?? 'Buyer',
                            style: TextConstants.smallText.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '@${buyer?.username ?? 'user'}',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 11.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openChat(order, buyer),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
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
                if (order.orderNotes != null &&
                    order.orderNotes!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  _buildOrderDetailRow(
                    icon: Ph.note,
                    label: 'Notes',
                    value: order.orderNotes!,
                  ),
                ],

                // Action buttons
                if (order.isActive) ...[
                  SizedBox(height: 16.h),
                  _buildActionButtons(order, provider),
                ],
              ],
            ),
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
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case OrderStatus.processing:
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      case OrderStatus.ready:
        bgColor = AppTheme.success.withOpacity(0.1);
        textColor = AppTheme.success;
        break;
      case OrderStatus.completed:
        bgColor = AppTheme.success.withOpacity(0.1);
        textColor = AppTheme.success;
        break;
      case OrderStatus.cancelled:
        bgColor = AppTheme.error.withOpacity(0.1);
        textColor = AppTheme.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status == OrderStatus.ready ? 'Ready' : status.name.toUpperCase(),
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

  Widget _buildActionButtons(OrderModel order, SalesProvider provider) {
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
                'Decline',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: provider.isUpdating
                  ? null
                  : () => provider.confirmOrder(order.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Accept',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (order.isConfirmed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isUpdating
              ? null
              : () => provider.startProcessing(order.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Start Processing',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (order.isProcessing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              provider.isUpdating ? null : () => provider.markAsReady(order.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Mark as Ready',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (order.isReady) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isUpdating
              ? null
              : () => provider.completeOrder(order.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.success,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'Complete Order',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCancelDialog(OrderModel order, SalesProvider provider) {
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
              'Please provide a reason for cancelling this order:',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
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
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                provider.cancelOrder(order.id, reasonController.text.trim());
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
              style: TextConstants.smallText.copyWith(
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(OrderModel order, dynamic buyer) {
    // TODO: Navigate to chat screen with buyer
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
