import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/campus_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/eventsScreen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/for_youScreen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/friends_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/post_folder/new_post.dart';
import 'package:campcon/main/screens/other_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final currentUser = authProvider.currentUser;
          final bool isLoggedIn = currentUser != null;

          return SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppTheme.surface,
                      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 0),
                      child: Column(
                        children: [
                          // Top Bar
                          _buildTopBar(context, currentUser, isLoggedIn),
                          SizedBox(height: 20.h),

                          // Create Post Button
                          _buildCreatePostButton(),
                          SizedBox(height: 20.h),

                          // Tab Bar
                          _buildTabBar(),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                color: AppTheme.background,
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
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, currentUser, bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Avatar
        GestureDetector(
          onTap: () {
            if (isLoggedIn) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfileScreen(userId: currentUser.uid),
                ),
              );
            }
          },
          child: Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: isLoggedIn && currentUser.profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(currentUser.profileImageUrl!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => Container(
                        color: AppTheme.primaryBackground,
                        child: Icon(
                          Icons.person,
                          size: 22.sp,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            child: Icon(
              Icons.person,
              size: 22.sp,
              color: AppTheme.primary,
            ),
          ),
        ),

        // Logo
        Image.asset(
          'assets/images/small_logo.png',
          height: 40.h,
        ),

        // Search Button
        Container(
          width: 35.w,
          height: 35.h,
          // decoration: BoxDecoration(
          //   color: AppTheme.primaryBackground.withOpacity(0.3),
          //   shape: BoxShape.circle,
          // ),
          child: IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: Icon(
              FeatherIcons.search,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
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
            width: 1.5,
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
