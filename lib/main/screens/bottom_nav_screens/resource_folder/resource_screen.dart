import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/resource_section.dart';
// import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/camplist_section.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/widgets/add_resource.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:campcon/main/widgets/profile_drawer.dart';
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
                  // Top section (search bar)
                  SliverToBoxAdapter(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                      child: Column(
                        children: [
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
    // Resource Tab
    return const ResourceSection();

    // Camplist Tab (temporarily disabled)
    // return const CamplistSection();
  }

  void _showAddOptions(BuildContext context) {
    AddResourceBottomSheet.show(context);
  }
}
