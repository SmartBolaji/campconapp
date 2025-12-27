import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/market_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/post_product_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/post_service_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/market_cart.dart';
import 'package:campcon/main/provider/buyer_orders_provider.dart';
import 'package:campcon/main/widgets/custom_top_bar.dart';
import 'package:campcon/main/widgets/market/empty_state.dart';
import 'package:campcon/main/widgets/market/market_tabbar.dart';
import 'package:campcon/main/widgets/market/sort_filter_bar.dart';
import 'package:campcon/main/widgets/market/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconly/iconly.dart';
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
    // Load data on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _initializeBuyerOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                                  hintText: 'Search marketplace',
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
                        child: TabBarWidget(
                          selectedTab: provider.selectedTab,
                          onTabChanged: (index) {
                            provider.changeTab(index);
                          },
                        ),
                      ),
                    ),
                  ),

                  // ✅ Filters Section (Pinned below tabs) - INCREASED HEIGHT
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
                            // SizedBox(height: 12.h), // ✅ Restored spacing
                            const SortFilterBar(),
                            SizedBox(height: 8.h), // ✅ Restored spacing
                            // const CategoryChips(),
                            // SizedBox(height: 8.h), // ✅ Restored spacing
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ✅ Content Section
                  _buildSliverContent(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverContent(MarketplaceProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return SliverFillRemaining(
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
      );
    }

    // Empty state
    final filteredProducts = provider.filteredList;
    if (filteredProducts.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          isItem: provider.selectedTab == 0,
          onAddPressed: () => _showPostOptions(context),
        ),
      );
    }

    // ✅ Success - Show products in masonry grid
    return SliverPadding(
      padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 60.h,
          top: 8.h), // ✅ Adjusted padding
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: filteredProducts[index],
            imageHeight: _calculateImageHeight(index),
          );
        },
      ),
    );
  }

  // ✅ Calculate dynamic image height for variety
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

// ✅ Custom delegate for pinned filter header
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
