import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/resource_section.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/camplist_section.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/add_resource.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/resource_tabbar.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    provider.setCurrentUserId(authProvider.currentUser?.uid);
    await provider.loadCurrentTab();
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<ResourceProvider>(context, listen: false);
    await provider.refreshCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResourceProvider>(
      builder: (context, provider, child) {
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
                  //  Floating App Bar with Search and Tabs
                  SliverAppBar(
                    backgroundColor: AppTheme.surface,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    pinned: true,
                    expandedHeight: 160.h,
                    surfaceTintColor: AppTheme.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // Top Bar
                            CustomTopBar(
                              centerText: 'Resources',
                              showAdd: true,
                              onAddTap: () => _showAddOptions(context),
                            ),
                            SizedBox(height: 20.h),

                            //  Search Bar using ActionSearchBar - navigates to search screen
                            ActionSearchBar.navigate(
                              hintText: 'Search resources',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 200),
                                    child: const SearchScreen(
                                        context: SearchContext.resources),
                                  ),
                                );
                              },
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
                        child: ResourceTabBar(
                          selectedTab: provider.selectedTab,
                          onTabChanged: (index) {
                            provider.changeTab(index);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Content based on selected tab
                  _buildSliverContent(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverContent(ResourceProvider provider) {
    if (provider.selectedTab == 0) {
      // Resource Tab
      return const ResourceSection();
    } else {
      // Camplist Tab
      return const CamplistSection();
    }
  }

  void _showAddOptions(BuildContext context) {
    AddResourceBottomSheet.show(context);
  }
}
