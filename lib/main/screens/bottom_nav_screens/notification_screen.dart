import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/notification_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/notification/notification_tabbar.dart';
// ✅ COMMENTED OUT - Sort/Filter bar
// import 'package:campcon/main/widgets/notification/notification_sort_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    final userId = authProvider.currentUser?.uid;
    if (userId != null) {
      await notifyProvider.loadNotifications(userId);
    }
  }

  Future<void> _onRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    final userId = authProvider.currentUser?.uid;
    if (userId != null) {
      await notifyProvider.refreshNotifications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.uid;

    return Consumer<NotifyProvider>(
      builder: (context, notifyProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ✅ Floating App Bar
                  SliverAppBar(
                    backgroundColor: AppTheme.surface,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    pinned: true,
                    expandedHeight: 100.h,
                    surfaceTintColor: AppTheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // Top Bar
                            const CustomTopBar(
                              centerText: 'Notifications',
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(50.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: NotificationTabBar(
                          selectedTab: notifyProvider.selectedTab,
                          onTabChanged: (index) {
                            notifyProvider.changeTab(index);
                          },
                        ),
                      ),
                    ),
                  ),

                  // ✅ COMMENTED OUT - Sort/Filter Bar
                  // SliverPersistentHeader(
                  //   pinned: true,
                  //   delegate: _FilterHeaderDelegate(
                  //     minHeight: 90.h,
                  //     maxHeight: 90.h,
                  //     child: Container(
                  //       color: AppTheme.surface,
                  //       padding: EdgeInsets.symmetric(horizontal: 20.w),
                  //       child: const NotificationSortFilterBar(),
                  //     ),
                  //   ),
                  // ),

                  // ✅ Mark all as read button (if unread exists)
                  if (notifyProvider.unreadCount > 0)
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppTheme.surface,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${notifyProvider.unreadCount} unread',
                              style: TextConstants.smallText.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (userId != null) {
                                  notifyProvider.markAllAsRead(userId);
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Mark all as read',
                                style: TextConstants.smallText.copyWith(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ✅ Content Section
                  _buildSliverContent(notifyProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverContent(NotifyProvider notifyProvider) {
    // Loading state
    if (notifyProvider.isLoading && notifyProvider.allNotifications.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    // Error state
    if (notifyProvider.error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyBold.danger,
                size: 48.sp,
                color: AppTheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                notifyProvider.error!,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _loadNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state (after filtering)
    if (notifyProvider.notifications.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyBold.notification,
                size: 64.sp,
                color: AppTheme.textLight,
              ),
              SizedBox(height: 16.h),
              Text(
                notifyProvider.allNotifications.isEmpty
                    ? 'No notifications yet'
                    : 'No ${notifyProvider.currentTabLabel.toLowerCase()} notifications',
                style: TextConstants.boldText.copyWith(
                  fontSize: 18.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  notifyProvider.allNotifications.isEmpty
                      ? 'When you get notifications, they\'ll show up here'
                      : 'Try switching to another tab to see more notifications',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show notifications
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        bottom: 60.h,
        top: 8.h,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final notification = notifyProvider.notifications[index];
            return _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onDismiss: () {
                notifyProvider.deleteNotification(notification.id);
              },
            );
          },
          childCount: notifyProvider.notifications.length,
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    final notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    // Mark as read
    if (!notification.isRead) {
      notifyProvider.markAsRead(notification.id);
    }

    // Navigate to target
    // TODO: Implement navigation based on targetType and targetId
    debugPrint(
        'Navigate to: ${notification.targetType} - ${notification.targetId}');
  }
}

// ✅ COMMENTED OUT - Filter header delegate (not needed with tabs)
// class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;
//
//   _FilterHeaderDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });
//
//   @override
//   double get minExtent => minHeight;
//
//   @override
//   double get maxExtent => maxHeight;
//
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return SizedBox.expand(child: child);
//   }
//
//   @override
//   bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          IconlyBold.delete,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.surface
                : AppTheme.primary.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Actor profile image
              CircleAvatar(
                radius: 20.r,
                backgroundImage: notification.actorProfileImage != null
                    ? NetworkImage(notification.actorProfileImage!)
                    : null,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: notification.actorProfileImage == null
                    ? Icon(
                        IconlyBold.profile,
                        size: 20.sp,
                        color: AppTheme.primary,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and body
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: notification.actorName,
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' ${notification.body}',
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 14.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Time
                    Text(
                      notification.timeAgo,
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification image (if available)
              if (notification.imageUrl != null) ...[
                SizedBox(width: 12.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: Image.network(
                    notification.imageUrl!,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40.w,
                        height: 40.w,
                        color: AppTheme.background,
                        child: Icon(
                          IconlyBold.image,
                          size: 20.sp,
                          color: AppTheme.textLight,
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Unread indicator
              if (!notification.isRead) ...[
                SizedBox(width: 8.w),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
