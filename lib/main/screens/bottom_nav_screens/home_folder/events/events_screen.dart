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
    });
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // ✅ Get school instead of campus
    final school = authProvider.currentUser?.school ?? '';
    final userId = authProvider.currentUser?.uid ?? '';

    if (school.isNotEmpty) {
      await eventProvider.loadEvents(school); // ✅ Load ALL events from school
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
      await eventProvider.refreshEvents(school); // ✅ Changed
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';

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

        // Show empty state
        if (eventProvider.filteredEvents.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                // height: MediaQuery.of(context).size.height - 200.h,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateEventScreen(),
                          ),
                        );
                      },
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

        // Show events grid
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sort/Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w),
                  child: const Column(
                    children: [
                      // SizedBox(height: 16.h),
                      EventSortFilterBar(),
                    ],
                  ),
                ),
              ),

              // Events Grid
              SliverPadding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
                  bottom: 40.h,
                ),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childCount: eventProvider.filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = eventProvider.filteredEvents[index];
                    return EventCard(
                      event: event,
                      imageHeight: _calculateImageHeight(index),
                      isInterested: eventProvider.isInterested(event.id),
                      isAttending: eventProvider.isAttending(event.id),
                      onInterested: () {
                        if (currentUserId.isNotEmpty) {
                          eventProvider.toggleInterested(
                            event.id,
                            currentUserId,
                          );
                        }
                      },
                      onAttending: () {
                        if (currentUserId.isNotEmpty) {
                          eventProvider.toggleAttending(
                            event.id,
                            currentUserId,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateImageHeight(int index) {
    if (index % 7 == 0) return 180.h;
    if (index % 5 == 0) return 160.h;
    if (index % 3 == 0) return 140.h;
    return 120.h;
  }
}
