import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/theme_provider.dart';
import 'package:campcon/main/provider/update_provider.dart';
import 'package:campcon/main/screens/profile/account_information_screen.dart';
import 'package:campcon/main/screens/profile/menu_screen.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/widgets/theme_bottom_sheet.dart';
import 'package:campcon/main/widgets/dialogs/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentUser = authProvider.currentUser;

        if (currentUser == null) {
          return const SizedBox.shrink();
        }

        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(),
          child: Column(
            children: [
              // Header section with profile info
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ProfileScreen(userId: currentUser.uid),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: context.appColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Image
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentUser.profileImageUrl == null
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : null,
                          image: currentUser.profileImageUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    currentUser.profileImageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: currentUser.profileImageUrl == null
                            ? Center(
                                child: Iconify(
                                  Ph.user,
                                  color: Theme.of(context).primaryColor,
                                  size: 40.sp,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(height: 14.h),

                      // Name
                      Text(
                        currentUser.fullName ?? 'User',
                        style: TextConstants.boldText.copyWith(
                          fontSize: 17.sp,
                          color: context.appColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),

                      // Username
                      Text(
                        '@${currentUser.username ?? 'username'}',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: context.appColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Ph.user,
                      label: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const AccountInformationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Ph.gear,
                      label: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const MenuScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Ph.download,
                      label: 'Check for Updates',
                      onTap: () {
                        Navigator.pop(context);
                        UpdateDialog.show(context);
                      },
                    ),
                  ],
                ),
              ),

              // Theme toggle section at bottom
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 80.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: context.appColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildThemeToggle(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Iconify(
              icon,
              color: Theme.of(context).primaryColor,
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Text(
              label,
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Iconify(
              Ph.caret_right,
              color: context.appColors.textLight,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final currentMode = themeProvider.themeMode;
        final isDark = currentMode == ThemeMode.dark;
        String modeLabel;

        switch (currentMode) {
          case ThemeMode.light:
            modeLabel = 'Light Mode';
            break;
          case ThemeMode.dark:
            modeLabel = 'Dark Mode';
            break;
          case ThemeMode.system:
            modeLabel = 'System Default';
            break;
        }

        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            showThemeBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Iconify(
                      isDark ? Ph.moon : Ph.sun,
                      color: isDark ? Colors.amber : Colors.orange,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: context.appColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        modeLabel,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: context.appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Iconify(
                  Ph.caret_right,
                  color: context.appColors.textLight,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
