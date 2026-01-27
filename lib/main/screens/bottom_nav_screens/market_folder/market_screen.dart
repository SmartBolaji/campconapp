import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/market_provider.dart';
import 'package:campcon/main/provider/search_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/post_product_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/market_cart.dart';
import 'package:campcon/main/provider/buyer_orders_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/product/post_service_screen.dart';
import 'package:campcon/main/screens/search/search_screen.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/widgets/empty_state.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/widgets/market_tabbar.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/widgets/sort_filter_bar.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/widgets/product_card.dart';
import 'package:campcon/main/widgets/action_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _initializeBuyerOrders();
      _setCurrentUser();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setCurrentUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final marketProvider =
        Provider.of<MarketplaceProvider>(context, listen: false);
    marketProvider.setCurrentUserId(authProvider.currentUser?.uid);
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    await provider.loadCurrentTab();
  }

  void _initializeBuyerOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final buyerOrdersProvider =
        Provider.of<BuyerOrdersProvider>(context, listen: false);
    final buyerId = authProvider.currentUser?.uid;
    if (buyerId != null) {
      buyerOrdersProvider.initialize(buyerId);
    }
  }

  Future<void> _onRefresh() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    await provider.refreshCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
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
                              centerText: 'Marketplace',
                              showAdd: true,
                              showCart: true,
                              onAddTap: () => _showPostOptions(context),
                              cartItemCount:
                                  Provider.of<BuyerOrdersProvider>(context)
                                      .activeOrdersCount,
                              onCartTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const MarketCartScreen(),
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 20.h),

                            // Search Bar using ActionSearchBar - navigates to search screen
                            ActionSearchBar.navigate(
                              hintText: 'Search products & services',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 200),
                                    child: const SearchScreen(
                                      context: SearchContext.market,
                                    ),
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
                        child: TabBarWidget(
                          selectedTab: provider.selectedTab,
                          onTabChanged: (index) {
                            provider.changeTab(index);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Filters Section
                  SliverPersistentHeader(
                    // pinned: true,
                    delegate: _FilterHeaderDelegate(
                      minHeight: 90.h,
                      maxHeight: 90.h,
                      child: Container(
                        color: AppTheme.surface,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SortFilterBar(),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content Section
                  ..._buildSliverContent(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSliverContent(MarketplaceProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return [
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          ),
        ),
      ];
    }

    // Error state
    if (provider.error != null) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppTheme.error,
                ),
                SizedBox(height: 16.h),
                Text(
                  provider.error!,
                  style: TextConstants.mediumText.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () async {
                    await provider.refreshCurrentTab();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final sections = provider.filteredListSectioned;
    final myProducts = sections['my'] ?? [];
    final otherProducts = sections['other'] ?? [];

    // Empty state
    if (myProducts.isEmpty && otherProducts.isEmpty) {
      return [
        SliverFillRemaining(
          child: EmptyStateWidget(
            isItem: provider.selectedTab == 0,
            onAddPressed: () => _showPostOptions(context),
          ),
        ),
      ];
    }

    List<Widget> slivers = [];

    // My Products Section
    if (myProducts.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            icon: Ph.storefront,
            title: provider.selectedTab == 0 ? 'My Listings' : 'My Services',
            count: myProducts.length,
            color: AppTheme.primary,
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childCount: myProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: myProducts[index],
                imageHeight: _calculateImageHeight(index),
                showOwnerBadge: true,
              );
            },
          ),
        ),
      );

      // Divider between sections
      if (otherProducts.isNotEmpty) {
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

    // Other Products Section
    if (otherProducts.isNotEmpty) {
      // slivers.add(
      //   SliverToBoxAdapter(
      //     child: _buildSectionHeader(
      //       icon: Ph.buildings,
      //       title: myProducts.isNotEmpty
      //           ? 'Explore More'
      //           : (provider.selectedTab == 0 ? 'All Items' : 'All Services'),
      //       count: otherProducts.length,
      //       color: AppTheme.textSecondary,
      //     ),
      //   ),
      // );

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: 60.h,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childCount: otherProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: otherProducts[index],
                imageHeight: _calculateImageHeight(index),
              );
            },
          ),
        ),
      );
    }

    // Add bottom padding if only my products
    if (myProducts.isNotEmpty && otherProducts.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(height: 60.h),
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
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 0.h,
        bottom: 12.h,
      ),
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

  //  Calculate dynamic image height for variety
  double _calculateImageHeight(int index) {
    if (index % 7 == 0) return 180.h; // Tallest
    if (index % 5 == 0) return 160.h; // Tall
    if (index % 3 == 0) return 140.h; // Medium
    return 120.h; // Default/Short
  }

  void _showPostOptions(BuildContext context) {
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
                  _PostOptionButton(
                    icon: Icons.shopping_bag_outlined,
                    label: 'List an Item',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostItemScreen(),
                        ),
                      );
                    },
                  ),
                  _PostOptionButton(
                    icon: Icons.home_repair_service_outlined,
                    label: 'List a Service',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostServiceScreen(),
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

//  Custom delegate for pinned filter header
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _FilterHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _PostOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostOptionButton({
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
