import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/campus_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/events/events_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/for_you_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/friends_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/post_folder/new_post.dart';
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

                            // Create Post Button
                            _buildCreatePostButton(),
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

  Widget _buildCreatePostButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewPostScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.buttonBorder,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: AppTheme.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppTheme.textLight,
              size: 25.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'What\'s on your mind?',
                style: TextConstants.smallText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textLight,
                ),
              ),
            ),
          ],
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
