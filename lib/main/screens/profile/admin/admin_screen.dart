import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/admin_provider.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/profile/admin/widgets/admin_pickup_card.dart';
import 'package:campcon/main/screens/profile/admin/widgets/admin_post_card.dart';
import 'package:campcon/main/screens/profile/admin/widgets/admin_product_card.dart';
import 'package:campcon/main/screens/profile/admin/widgets/admin_seller_card.dart';
import 'package:campcon/main/screens/profile/admin/widgets/admin_user_card.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const _tabs = [
    'Posts',
    'Seller Apps',
    'Users',
    'Items',
    'Services',
    'Pickup Apps'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final admin = context.read<AdminProvider>();
      await admin.checkAdminAccess(auth.currentUser?.uid);
      if (admin.isAdmin) {
        await admin.loadAdminData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isCheckingAccess) {
          return _buildCheckingScreen();
        }

        if (!admin.isAdmin) {
          return _buildNoAccessScreen();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(admin),
          body: Column(
            children: [
              _buildTabBar(admin),
              if (admin.error != null) _buildErrorBanner(admin.error!),
              _buildSearchField(admin),
              _buildSearchResultsCount(admin),
              Expanded(child: _buildBody(admin)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AdminProvider admin) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child:
              Iconify(Ph.arrow_left, size: 24.r, color: AppTheme.textPrimary),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Admin Console',
            style: TextConstants.boldText.copyWith(fontSize: 18.sp),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            await admin.loadAdminData();
            if (mounted) {
              showCustomToast(context, 'Data refreshed',
                  type: ToastType.success);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Iconify(
              Ph.arrows_clockwise,
              size: 22.r,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            SizedBox(height: 16.h),
            Text(
              'Verifying admin access…',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccessScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child:
                Iconify(Ph.arrow_left, size: 24.r, color: AppTheme.textPrimary),
          ),
        ),
        title: Text('Admin',
            style: TextConstants.boldText.copyWith(fontSize: 18.sp)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Iconify(Ph.prohibit, size: 32.r, color: AppTheme.error),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Access Denied',
              style: TextConstants.boldText.copyWith(
                fontSize: 18.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'You do not have admin access.',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AdminProvider admin) {
    final counts = [
      admin.posts.length,
      admin.sellerApplications.length,
      admin.users.length,
      admin.items.length,
      admin.services.length,
      admin.pickupApplications.length,
    ];

    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final selected = admin.selectedTab == index;
          final count = counts[index];
          final showCount = !admin.isLoading && count > 0;

          return GestureDetector(
            onTap: () {
              if (admin.selectedTab != index) {
                admin.setSelectedTab(index);
                admin.clearSearch();
                _searchController.clear();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tabs[index],
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                  if (showCount) ...[
                    SizedBox(width: 5.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : AppTheme.textLight,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Iconify(Ph.warning_circle, size: 14.r, color: AppTheme.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              error,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AdminProvider admin) {
    final hints = [
      'Search posts by username…',
      'Search seller apps by username…',
      'Search users by username…',
      'Search items by name…',
      'Search services by name…',
      'Search pickup centers by name…',
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => _doSearch(admin, v.trim()),
                style: TextConstants.smallText.copyWith(
                  fontSize: 13.sp,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hints[admin.selectedTab],
                  hintStyle: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    color: AppTheme.textLight,
                  ),
                  border: InputBorder.none,
                  // suffixIcon: GestureDetector(
                  //   onTap: () =>
                  //       _doSearch(admin, _searchController.text.trim()),
                  //   child: Padding(
                  //     padding: EdgeInsets.all(10.w),
                  //     child: Iconify(
                  //       Ph.magnifying_glass,
                  //       size: 18.r,
                  //       color: AppTheme.textSecondary,
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              admin.clearSearch();
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Iconify(Ph.x, size: 18.r, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsCount(AdminProvider admin) {
    final hasResults = _hasSearchResults(admin);
    if (!hasResults) return SizedBox(height: 8.h);

    final count = _resultCount(admin);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '$count result${count == 1 ? '' : 's'} found',
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              admin.clearSearch();
            },
            child: Text(
              'Clear',
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminProvider admin) {
    if (admin.isLoading) {
      return _buildShimmerList();
    }

    if (_hasSearchResults(admin)) {
      return _buildSearchResults(admin);
    }

    return RefreshIndicator(
      onRefresh: admin.refreshCurrentTab,
      color: AppTheme.primary,
      child: _buildTabContent(admin),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: AppTheme.border,
        highlightColor: AppTheme.surface,
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(21.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 13.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 10.h,
                        width: 180.w,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(AdminProvider admin) {
    switch (admin.selectedTab) {
      case 0:
        return _buildPostsList(admin.posts, admin, isSearch: false);
      case 1:
        return _buildSellerList(admin.sellerApplications, admin,
            isSearch: false);
      case 2:
        return _buildUsersList(admin.users, admin, isSearch: false);
      case 3:
        return _buildProductsList(admin.items, admin, isSearch: false);
      case 4:
        return _buildProductsList(admin.services, admin, isSearch: false);
      case 5:
        return _buildPickupList(admin.pickupApplications, admin,
            isSearch: false);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchResults(AdminProvider admin) {
    switch (admin.selectedTab) {
      case 0:
        return _buildPostsList(admin.searchPostsResults, admin, isSearch: true);
      case 1:
        return _buildSellerList(admin.searchResults, admin, isSearch: true);
      case 2:
        return _buildUsersList(admin.searchResults, admin, isSearch: true);
      case 3:
        return _buildProductsList(admin.searchProducts, admin, isSearch: true);
      case 5:
        return _buildPickupList(admin.searchPickupCentersResults, admin,
            isSearch: true);
      default:
        return _buildEmpty('No results');
    }
  }

  // ── Users list ─────────────────────────────────────────────────────────────

  Widget _buildUsersList(List users, AdminProvider admin,
      {required bool isSearch}) {
    if (users.isEmpty) {
      return _buildEmpty(isSearch ? 'No users found' : 'No users yet');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: users.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final user = users[i];
        return AdminUserCard(
          user: user,
          isActionLoading: admin.isActionLoading,
          onMakeAdmin: () async {
            final ok = await admin.grantAdmin(user.uid);
            if (!mounted) return;
            if (ok) {
              showCustomToast(
                context,
                '${user.fullName} is now an admin',
                type: ToastType.success,
              );
            } else {
              showCustomToast(context, admin.error ?? 'Failed to grant admin',
                  type: ToastType.error);
            }
          },
          onVerify: () => _showVerifyRoleSheet(admin, user),
        );
      },
    );
  }

  Future<void> _showVerifyRoleSheet(AdminProvider admin, dynamic user) async {
    const options = [
      {'label': 'Verified', 'value': 'verified', 'icon': Ph.check},
      {'label': 'Government', 'value': 'gov', 'icon': Ph.buildings},
      {'label': 'Organization', 'value': 'org', 'icon': Ph.users_three},
      {'label': 'Default User', 'value': 'user', 'icon': Ph.user},
    ];

    final selectedRole = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select verification role',
                style: TextConstants.boldText.copyWith(fontSize: 15.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                '@${user.username}',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              ...options.map((option) {
                final value = option['value'] as String;
                final selected = user.role.toLowerCase() == value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, value),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withValues(alpha: 0.12)
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: selected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Iconify(
                            option['icon'] as String,
                            size: 16.r,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              option['label'] as String,
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 13.sp,
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (selected)
                            Iconify(
                              Ph.check,
                              size: 16.r,
                              color: AppTheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (selectedRole == null || selectedRole == user.role.toLowerCase()) {
      return;
    }

    final ok = await admin.updateUserRole(user.uid, selectedRole);
    if (!mounted) return;
    if (ok) {
      showCustomToast(context, 'Role updated to $selectedRole',
          type: ToastType.success);
    } else {
      showCustomToast(context, admin.error ?? 'Failed to update role',
          type: ToastType.error);
    }
  }

  // ── Post list ──────────────────────────────────────────────────────────────

  Widget _buildPostsList(List posts, AdminProvider admin,
      {required bool isSearch}) {
    if (posts.isEmpty) {
      return _buildEmpty(isSearch ? 'No posts found' : 'No posts yet');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: posts.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final post = posts[i];
        return AdminPostCard(
          post: post,
          isActionLoading: admin.isActionLoading,
          onDelete: () async {
            final ok = await admin.deletePost(post.postId);
            if (!mounted) return;
            if (ok) {
              showCustomToast(context, 'Post deleted', type: ToastType.success);
            } else {
              showCustomToast(context, admin.error ?? 'Failed to delete post',
                  type: ToastType.error);
            }
          },
        );
      },
    );
  }

  // ── Seller applications list ───────────────────────────────────────────────

  Widget _buildSellerList(List users, AdminProvider admin,
      {required bool isSearch}) {
    if (users.isEmpty) {
      return _buildEmpty(
          isSearch ? 'No users found' : 'No pending seller applications');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: users.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final user = users[i];

        // Search results may show any user — only show actions if actually pending
        if (isSearch && (user.sellerStatus != 'pending')) {
          return AdminSellerCard(
            user: user,
            isActionLoading: admin.isActionLoading,
          );
        }

        return AdminSellerCard(
          user: user,
          isActionLoading: admin.isActionLoading,
          onApprove: () async {
            final ok = await admin.approveSellerApplication(user.uid);
            if (!mounted) return;
            if (ok) {
              showCustomToast(
                context,
                '${user.businessName ?? user.fullName} approved as seller',
                type: ToastType.success,
              );
            } else {
              showCustomToast(context, admin.error ?? 'Failed to approve',
                  type: ToastType.error);
            }
          },
          onReject: (reason) async {
            final ok =
                await admin.rejectSellerApplication(user.uid, reason: reason);
            if (!mounted) return;
            if (ok) {
              showCustomToast(context, 'Application rejected',
                  type: ToastType.warning);
            } else {
              showCustomToast(context, admin.error ?? 'Failed to reject',
                  type: ToastType.error);
            }
          },
        );
      },
    );
  }

  // ── Products / services list ───────────────────────────────────────────────

  Widget _buildProductsList(List products, AdminProvider admin,
      {required bool isSearch}) {
    if (products.isEmpty) {
      return _buildEmpty(isSearch ? 'No listings found' : 'No listings yet');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final product = products[i];
        return AdminProductCard(
          product: product,
          isActionLoading: admin.isActionLoading,
          onDelete: () async {
            final ok =
                await admin.deleteListing(product.id, isItem: product.isItem);
            if (!mounted) return;
            if (ok) {
              showCustomToast(context, '"${product.name}" removed',
                  type: ToastType.success);
            } else {
              showCustomToast(context, admin.error ?? 'Failed to delete',
                  type: ToastType.error);
            }
          },
        );
      },
    );
  }

  // ── Pickup applications list ───────────────────────────────────────────────

  Widget _buildPickupList(List centers, AdminProvider admin,
      {required bool isSearch}) {
    if (centers.isEmpty) {
      return _buildEmpty(
          isSearch ? 'No pickup centers found' : 'No pending applications');
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: centers.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        final center = centers[i];
        return AdminPickupCard(
          center: center,
          isActionLoading: admin.isActionLoading,
          onApprove: center.isPending
              ? () async {
                  final ok = await admin.approvePickupApplication(center.id);
                  if (!mounted) return;
                  if (ok) {
                    showCustomToast(context, '"${center.name}" approved',
                        type: ToastType.success);
                  } else {
                    showCustomToast(context, admin.error ?? 'Failed to approve',
                        type: ToastType.error);
                  }
                }
              : null,
          onReject: center.isPending
              ? (reason) async {
                  final ok = await admin.rejectPickupApplication(center.id,
                      reason: reason);
                  if (!mounted) return;
                  if (ok) {
                    showCustomToast(context, 'Application rejected',
                        type: ToastType.warning);
                  } else {
                    showCustomToast(context, admin.error ?? 'Failed to reject',
                        type: ToastType.error);
                  }
                }
              : null,
          onSuspend: center.isApproved
              ? () async {
                  final ok = await admin.suspendPickupCenter(center.id);
                  if (!mounted) return;
                  if (ok) {
                    showCustomToast(context, '"${center.name}" suspended',
                        type: ToastType.warning);
                  } else {
                    showCustomToast(context, admin.error ?? 'Failed to suspend',
                        type: ToastType.error);
                  }
                }
              : null,
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _doSearch(AdminProvider admin, String q) {
    if (q.isEmpty) {
      admin.clearSearch();
      return;
    }
    switch (admin.selectedTab) {
      case 0:
        admin.searchPosts(q);
        break;
      case 1:
        admin.searchUsers(q);
        break;
      case 2:
        admin.searchUsers(q);
        break;
      case 3:
        admin.searchListings(q, isItem: true);
        break;
      case 4:
        admin.searchListings(q, isItem: false);
        break;
      case 5:
        admin.searchPickupCenters(q);
        break;
    }
  }

  bool _hasSearchResults(AdminProvider admin) {
    return admin.searchPostsResults.isNotEmpty ||
        admin.searchResults.isNotEmpty ||
        admin.searchProducts.isNotEmpty ||
        admin.searchPickupCentersResults.isNotEmpty;
  }

  int _resultCount(AdminProvider admin) {
    switch (admin.selectedTab) {
      case 0:
        return admin.searchPostsResults.length;
      case 1:
        return admin.searchResults.length;
      case 2:
        return admin.searchResults.length;
      case 3:
        return admin.searchProducts.length;
      case 5:
        return admin.searchPickupCentersResults.length;
      default:
        return 0;
    }
  }

  Widget _buildEmpty(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Iconify(
                    Ph.info,
                    size: 26.r,
                    color: AppTheme.textLight,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                message,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
