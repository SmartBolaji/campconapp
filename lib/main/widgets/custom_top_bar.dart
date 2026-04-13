import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class CustomTopBar extends StatelessWidget {
  final String? centerText;
  final Widget? centerWidget;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onCustomTap;
  final bool showAdd;
  final bool showEdit;
  final bool showSearch;
  final bool showCart;
  final bool showCustom;
  final Widget? customIcon;
  final int cartItemCount;

  const CustomTopBar({
    Key? key,
    this.centerText,
    this.centerWidget,
    this.onSearchTap,
    this.onAddTap,
    this.onEditTap,
    this.onCartTap,
    this.onCustomTap,
    this.showAdd = false,
    this.showEdit = false,
    this.showSearch = true,
    this.showCart = false,
    this.showCustom = false,
    this.customIcon,
    this.cartItemCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final appColors = context.appColors;
        final colorScheme = Theme.of(context).colorScheme;
        final currentUser = authProvider.currentUser;
        final bool isLoggedIn = currentUser != null;
        final hasProfileImage =
            (currentUser?.profileImageUrl ?? '').trim().isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Center Content (Logo or Text) - Absolutely centered
            Center(
              child: centerWidget ??
                  (centerText != null
                      ? Text(centerText!, style: TextConstants.medium(context))
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
                      // Open profile drawer
                      Scaffold.of(context).openEndDrawer();
                    }
                  },
                  child: Container(
                    width: 35.w,
                    height: 35.h,
                    padding: isLoggedIn && !hasProfileImage
                        ? EdgeInsets.all(6.w)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLoggedIn && !hasProfileImage
                          ? appColors.primaryBackground
                          : null,
                      image: isLoggedIn && hasProfileImage
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                  currentUser?.profileImageUrl?.trim() ?? ''),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) => Container(
                                color: appColors.primaryBackground,
                                child: Iconify(
                                  Ph.user,
                                  color: colorScheme.primary,
                                  size: 20.sp,
                                ),
                              ),
                            )
                          : null,
                    ),
                    child: isLoggedIn && !hasProfileImage
                        ? Iconify(
                            Ph.user,
                            color: colorScheme.primary,
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
                                color: appColors.primaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FontAwesomeIcons.cartShopping,
                                color: colorScheme.primary,
                                size: 17.sp,
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
                                    color: colorScheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: appColors.surface,
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
                                      style:
                                          TextConstants.small(context).copyWith(
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
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: colorScheme.onPrimary,
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
                            color: appColors.textPrimary,
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
                            color: appColors.textPrimary,
                            size: 24.sp,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )
                    else if (showCustom)
                      SizedBox(
                        width: 35.w,
                        height: 35.h,
                        child: IconButton(
                          onPressed: onCustomTap ?? () {},
                          icon: customIcon ??
                              Icon(
                                IconlyLight.setting,
                                color: appColors.textPrimary,
                                size: 22.sp,
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
