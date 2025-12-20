import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/resource_section.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/camplist_section.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/resources/resource_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
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
                  // ✅ Floating App Bar with Search and Tabs
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

                            // Search Bar
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
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
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    IconlyLight.search,
                                    size: 25.sp,
                                    color: AppTheme.textLight,
                                  ),
                                  hintText: 'Search resources',
                                  hintStyle: TextConstants.smallText.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.buttonBorder,
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10.h),
                                ),
                                onChanged: (value) {
                                  // TODO: Implement search
                                },
                              ),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AddOptionButton(
                    icon: Icons.upload_file_outlined,
                    label: 'Upload Resource',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to upload resource screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Upload Resource - Coming Soon'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _AddOptionButton(
                    icon: Icons.add_task_outlined,
                    label: 'Add Task',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add task screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Add Task - Coming Soon'),
                          backgroundColor: AppTheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextConstants.smallText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
