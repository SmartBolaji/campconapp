import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CustomTopBar extends StatelessWidget {
  final String? centerText;
  final Widget? centerWidget;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onCartTap;
  final bool showAdd;
  final bool showEdit;
  final bool showSearch;
  final bool showCart;
  final int cartItemCount;

  const CustomTopBar({
    Key? key,
    this.centerText,
    this.centerWidget,
    this.onSearchTap,
    this.onAddTap,
    this.onEditTap,
    this.onCartTap,
    this.showAdd = false,
    this.showEdit = false,
    this.showSearch = true,
    this.showCart = false,
    this.cartItemCount = 0,
  }) : super(key: key);

  // Calculate the width of right actions
  double _getRightActionsWidth() {
    double width = 0;
    if (showCart) width += 35.w;
    if (showCart && showAdd) width += 12.w; // spacing
    if (showAdd || showEdit || showSearch) width += 35.w;
    if (width == 0) width = 35.w; // placeholder width
    return width;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final bool isLoggedIn = currentUser != null;

        final double rightWidth = _getRightActionsWidth();
        const double leftWidth = 35; // Profile avatar width

        return Stack(
          alignment: Alignment.center,
          children: [
            // Center Content (Logo or Text) - Absolutely centered
            Center(
              child: centerWidget ??
                  (centerText != null
                      ? Text(centerText!, style: TextConstants.mediumText)
                      : Image.asset(
                          'assets/images/small_logo.png',
                          height: 22.h,
                        )),
            ),

            // Left and Right actions
            Row(
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
                    padding: isLoggedIn && currentUser.profileImageUrl == null
                        ? EdgeInsets.all(6.w)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLoggedIn && currentUser.profileImageUrl == null
                          ? AppTheme.primaryBackground
                          : null,
                      image: isLoggedIn && currentUser.profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(currentUser.profileImageUrl!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) => Container(
                                color: AppTheme.primaryBackground,
                                child: Iconify(
                                  Ph.user,
                                  color: AppTheme.primary,
                                  size: 20.sp,
                                ),
                              ),
                            )
                          : null,
                    ),
                    child: isLoggedIn && currentUser.profileImageUrl == null
                        ? Iconify(
                            Ph.user,
                            color: AppTheme.primary,
                            size: 20.sp,
                          )
                        : null,
                  ),
                ),

                // Right Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart icon (for marketplace)
                    if (showCart)
                      GestureDetector(
                        onTap: onCartTap,
                        child: Stack(
                          children: [
                            Container(
                              width: 35.w,
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                IconlyLight.bag,
                                color: AppTheme.primary,
                                size: 20.sp,
                              ),
                            ),
                            // Badge for cart count
                            if (cartItemCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.surface,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16.w,
                                    minHeight: 16.h,
                                  ),
                                  child: Center(
                                    child: Text(
                                      cartItemCount > 9
                                          ? '9+'
                                          : '$cartItemCount',
                                      style: TextConstants.smallText.copyWith(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Spacing between cart and add
                    if (showCart && showAdd) SizedBox(width: 12.w),

                    // Add button
                    if (showAdd)
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.white,
                            size: 24.sp,
                          ),
                        ),
                      )
                    else if (showEdit)
                      SizedBox(
                        width: 35.w,
                        height: 35.h,
                        child: IconButton(
                          onPressed: onEditTap ?? () {},
                          icon: Icon(
                            FeatherIcons.edit,
                            color: AppTheme.textPrimary,
                            size: 22.sp,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    else if (showSearch)
                      SizedBox(
                        width: 35.w,
                        height: 35.h,
                        child: IconButton(
                          onPressed: onSearchTap ?? () {},
                          icon: Icon(
                            FeatherIcons.search,
                            color: AppTheme.textPrimary,
                            size: 24.sp,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    else if (!showCart)
                      SizedBox(width: 35.w, height: 35.h), // Empty placeholder
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
