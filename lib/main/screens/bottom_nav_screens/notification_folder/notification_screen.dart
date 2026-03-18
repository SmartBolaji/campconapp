import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/notification_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/empty_state_view.dart';
import 'package:campcon/main/widgets/profile_drawer.dart';
import 'package:campcon/main/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
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

  void _showFilterBottomSheet(BuildContext context) {
    final notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Notifications',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (notifyProvider.selectedTab != 0)
                        TextButton(
                          onPressed: () {
                            notifyProvider.changeTab(0);
                            setModalState(() {});
                          },
                          child: Text(
                            'Clear',
                            style: TextConstants.smallText.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Filter options
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: List.generate(
                      notifyProvider.tabLabels.length,
                      (index) {
                        final isSelected = notifyProvider.selectedTab == index;
                        return GestureDetector(
                          onTap: () {
                            notifyProvider.changeTab(index);
                            setModalState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.background,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getFilterIcon(index),
                                  size: 16.sp,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  notifyProvider.tabLabels[index],
                                  style: TextConstants.smallText.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Apply Filter',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getFilterIcon(int index) {
    switch (index) {
      case 0:
        return IconlyLight.category;
      case 1:
        return IconlyLight.heart;
      case 2:
        return IconlyLight.chat;
      case 3:
        return IconlyLight.add_user;
      case 4:
        return IconlyLight.bag;
      case 5:
        return IconlyLight.calendar;
      case 6:
        return IconlyLight.message;
      case 7:
        return IconlyLight.send;
      default:
        return IconlyLight.category;
    }
  }

  // Filter notifications based on search query
  List<NotificationModel> _getFilteredNotifications(
      NotifyProvider notifyProvider) {
    final notifications = notifyProvider.notifications;
    if (_searchQuery.isEmpty) {
      return notifications;
    }
    return notifications.where((notification) {
      final query = _searchQuery.toLowerCase();
      return notification.actorName.toLowerCase().contains(query) ||
          notification.body.toLowerCase().contains(query) ||
          notification.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.uid;

    return Consumer<NotifyProvider>(
      builder: (context, notifyProvider, child) {
        return Scaffold(
          endDrawer: const ProfileDrawer(),
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Top section (search bar + filter icon)
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppTheme.surface,
                      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                      child: Column(
                        children: [
                          // Top Bar
                          CustomTopBar(
                            centerText: 'Notifications',
                            showSearch: false,
                            showCustom: true,
                            customIcon: // Filter Icon
                                GestureDetector(
                              onTap: () => _showFilterBottomSheet(context),
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: notifyProvider.selectedTab != 0
                                      ? AppTheme.primary.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Stack(
                                  children: [
                                    Icon(
                                      IconlyLight.filter,
                                      size: 22.sp,
                                      color: notifyProvider.selectedTab != 0
                                          ? AppTheme.primary
                                          : AppTheme.textLight,
                                    ),
                                    // Active filter indicator
                                    if (notifyProvider.selectedTab != 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8.w,
                                          height: 8.w,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.surface,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          //  Search Bar using ActionSearchBar
                          ActionSearchBar.navigate(
                            hintText: 'Search notifications',
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: const Duration(milliseconds: 200),
                                  child: const SearchScreen(
                                      context: SearchContext.notifications),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  //  Active Filter Chip (if filter is applied)
                  if (notifyProvider.selectedTab != 0)
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppTheme.surface,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFilterIcon(notifyProvider.selectedTab),
                                    size: 14.sp,
                                    color: AppTheme.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    notifyProvider.currentTabLabel,
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  GestureDetector(
                                    onTap: () {
                                      notifyProvider.changeTab(0);
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 14.sp,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  //  Mark all as read button (if unread exists)
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

                  //  Content Section
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
        child: ShimmerList(
          itemCount: 6,
          type: ShimmerCardType.notification,
          padding: EdgeInsets.only(top: 10.h, bottom: 60.h),
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

    // Get filtered notifications (by search and tab filter)
    final filteredNotifications = _getFilteredNotifications(notifyProvider);

    // Empty state (after filtering)
    if (filteredNotifications.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateView(
          icon: Ph.bell,
          title: _searchQuery.isNotEmpty
              ? 'No results found'
              : notifyProvider.allNotifications.isEmpty
                  ? 'No notifications yet'
                  : 'No ${notifyProvider.currentTabLabel.toLowerCase()} notifications',
          subtitle: _searchQuery.isNotEmpty
              ? 'Try a different search term.'
              : notifyProvider.allNotifications.isEmpty
                  ? 'When you get notifications, they will show up here.'
                  : 'Try changing the filter to see more notifications.',
          buttonText: 'Retry',
          onPressed: _loadNotifications,
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
            final notification = filteredNotifications[index];
            return _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onDismiss: () {
                notifyProvider.deleteNotification(notification.id);
              },
            );
          },
          childCount: filteredNotifications.length,
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
    NavigationHelper.handleNotificationTap(context, notification);
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  void _navigateToProfile(BuildContext context) {
    final initialUserData = UserModel(
      uid: notification.actorId,
      email: '',
      username: notification.actorName,
      name: notification.actorName,
      profileImageUrl: notification.actorProfileImage ?? '',
      phoneNumber: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ProfileScreen(
          userId: notification.actorId,
          initialUserData: initialUserData,
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    final colorScheme = Theme.of(context).colorScheme;
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
                : AppTheme.primary.withValues(alpha: 0.05),
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
              GestureDetector(
                onTap: () {
                  _navigateToProfile(context);
                },
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: notification.actorProfileImage != null
                      ? CachedNetworkImageProvider(
                          notification.actorProfileImage!)
                      : null,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: notification.actorProfileImage == null
                      ? Iconify(
                          Ph.user,
                          size: 20.sp,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
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
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
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
