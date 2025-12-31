import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/create_event_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/widgets/event_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/widgets/event_sort_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _setCurrentUser();
    });
  }

  void _setCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventProvider.setCurrentUserId(authProvider.currentUser?.uid);
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final school = authProvider.currentUser?.school ?? '';
    final userId = authProvider.currentUser?.uid ?? '';

    if (school.isNotEmpty) {
      await eventProvider.loadEvents(school);
      if (userId.isNotEmpty) {
        await eventProvider.loadUserInteractions(userId);
      }
    } else {
      debugPrint('⚠️ User has no school set');
    }
  }

  Future<void> _onRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final school = authProvider.currentUser?.school ?? '';
    if (school.isNotEmpty) {
      await eventProvider.refreshEvents(school);
    }
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEventScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final currentUserName = authProvider.currentUser?.name ?? '';

    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        // Show loading for initial load
        if (eventProvider.isLoading && eventProvider.allEvents.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          );
        }

        // Show error state
        if (eventProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: AppTheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  eventProvider.error!,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _loadInitialData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: Text('Retry',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          );
        }

        final sections = eventProvider.filteredEventsSectioned;
        final myEvents = sections['my'] ?? [];
        final otherEvents = sections['other'] ?? [];

        // Show empty state (no events at all)
        if (myEvents.isEmpty && otherEvents.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EventSortFilterBar(),
                    SizedBox(height: 40.h),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 64.sp,
                      color: AppTheme.textLight,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No events yet',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Be the first to create an event!',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: _navigateToCreateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text('Create Event',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show events grid with sections
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sort/Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w),
                  child: const EventSortFilterBar(),
                ),
              ),

              // Build sectioned content
              ..._buildSliverContent(
                eventProvider,
                myEvents,
                otherEvents,
                currentUserId,
                currentUserName,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSliverContent(
    EventProvider eventProvider,
    List myEvents,
    List otherEvents,
    String currentUserId,
    String currentUserName,
  ) {
    List<Widget> slivers = [];

    // My Events Section (with Add Card)
    if (myEvents.isNotEmpty) {
      // Section Header
      slivers.add(
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            icon: Ph.users_three,
            title: 'My Events',
            count: myEvents.length,
            color: AppTheme.primary,
          ),
        ),
      );

      // My Events Grid (Add Card + My Events)
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childCount: myEvents.length + 1, // +1 for Add Card
            itemBuilder: (context, index) {
              // First item is Add Card
              if (index == 0) {
                return _buildAddEventCard(_calculateImageHeight(0));
              }

              // Offset by 1 for actual events
              final event = myEvents[index - 1];
              return EventCard(
                event: event,
                imageHeight: _calculateImageHeight(index),
                isAttending: eventProvider.isAttending(event.id),
                isOwner: true,
                onAttending: () {
                  if (currentUserId.isNotEmpty) {
                    eventProvider.toggleAttending(
                        event.id, currentUserId, currentUserName);
                  }
                },
              );
            },
          ),
        ),
      );

      // Divider between sections
      if (otherEvents.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Divider(color: AppTheme.border, thickness: 1),
            ),
          ),
        );
      }
    }

    // Other Events Section
    if (otherEvents.isNotEmpty) {
      // Section Header (only show if there are my events)
      if (myEvents.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              icon: Ph.users_three,
              title: 'Discover Events',
              count: otherEvents.length,
              color: AppTheme.textSecondary,
            ),
          ),
        );
      }

      // Other Events Grid
      // If no my events, add the Add Card at the beginning of other events
      final hasAddCard = myEvents.isEmpty;
      final itemCount = otherEvents.length + (hasAddCard ? 1 : 0);

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: myEvents.isEmpty ? 16.h : 0,
            bottom: 40.h,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childCount: itemCount,
            itemBuilder: (context, index) {
              // First item is Add Card (only if no my events)
              if (hasAddCard && index == 0) {
                return _buildAddEventCard(_calculateImageHeight(0));
              }

              // Offset by 1 if Add Card is present
              final eventIndex = hasAddCard ? index - 1 : index;
              final event = otherEvents[eventIndex];

              return EventCard(
                event: event,
                imageHeight: _calculateImageHeight(index),
                isAttending: eventProvider.isAttending(event.id),
                onAttending: () {
                  if (currentUserId.isNotEmpty) {
                    eventProvider.toggleAttending(
                        event.id, currentUserId, currentUserName);
                  }
                },
              );
            },
          ),
        ),
      );
    }

    // Add bottom padding if only my events
    if (myEvents.isNotEmpty && otherEvents.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(height: 40.h),
        ),
      );
    }

    return slivers;
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Iconify(
              icon,
              size: 16.sp,
              color: color,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '$count',
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEventCard(double imageHeight) {
    return GestureDetector(
      onTap: _navigateToCreateEvent,
      child: Container(
        height: imageHeight + 80.h, // Match event card approximate height
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 32.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Create Event',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'Host your own event',
                style: TextConstants.smallText.copyWith(
                  fontSize: 11.sp,
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

  double _calculateImageHeight(int index) {
    if (index % 3 == 0) return 120.h;
    if (index % 3 == 1) return 160.h;
    if (index % 3 == 2) return 120.h;
    if (index % 4 == 0) return 180.h;
    return 120.h;
  }
}
