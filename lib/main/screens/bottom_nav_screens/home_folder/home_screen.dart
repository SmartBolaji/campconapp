import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/campus_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/events_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/for_you_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/friends_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/new_post.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.surface,
                  padding: EdgeInsets.fromLTRB(0.w, 5.h, 0.w, 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Column(
                          children: [
                            // ✅ Use reusable top bar
                            const CustomTopBar(),
                            SizedBox(height: 20.h),

                            // ✅ Create Post Button using ActionSearchBar
                            ActionSearchBar.post(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NewPostScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),

                      // Tab Bar
                      _buildTabBar(),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Container(
            color: AppTheme.surface,
            child: TabBarView(
              controller: _tabController,
              children: const [
                MyForYouScreen(),
                FriendsScreen(),
                CampusScreen(),
                EventsScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: TextConstants.mediumText.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextConstants.mediumText.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
        tabs: const [
          Tab(text: "My FYP"),
          Tab(text: "Friends"),
          Tab(text: "Campus"),
          Tab(text: "Events"),
        ],
      ),
    );
  }
}
