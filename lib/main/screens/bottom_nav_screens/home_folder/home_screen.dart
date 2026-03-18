import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/campus_screen.dart';
// import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/events_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/for_you_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/friends_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/new_post.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/profile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      endDrawer: const ProfileDrawer(),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Top section (logo, search bar, create post button)
              SliverToBoxAdapter(
                child: Container(
                  color: colorScheme.surface,
                  padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                  child: Column(
                    children: [
                      //  Use reusable top bar
                      CustomTopBar(
                        onSearchTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              duration: const Duration(milliseconds: 200),
                              child: const SearchScreen(
                                context: SearchContext.home,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),

                      //  Create Post Button using ActionSearchBar
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
                    ],
                  ),
                ),
              ),

              // Floating/Pinned Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabBar: _buildTabBar(colorScheme),
                ),
              ),
            ];
          },
          body: Container(
            color: colorScheme.surface,
            child: TabBarView(
              controller: _tabController,
              children: const [
                MyForYouScreen(),
                FriendsScreen(),
                CampusScreen(),
                // EventsScreen(), // Temporarily disabled
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        // border: Border(
        //   bottom: BorderSide(
        //     color: colorScheme.outline,
        //     width: 1,
        //   ),
        // ),
      ),
      child: TabBar(
        dividerColor: AppTheme.border,
        dividerHeight: 1.h,
        controller: _tabController,
        isScrollable: false,
        labelColor: colorScheme.primary,
        unselectedLabelColor: AppTheme.textLight,
        labelStyle: TextConstants.mediumText.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextConstants.mediumText.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
        tabs: const [
          Tab(text: "My FYP"),
          Tab(text: "Friends"),
          Tab(text: "Campus"),
          // Tab(text: "Events"), // Temporarily disabled
        ],
      ),
    );
  }
}

// Delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => 48.h;

  @override
  double get maxExtent => 48.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
