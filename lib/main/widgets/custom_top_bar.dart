import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CustomTopBar extends StatelessWidget {
  final String? centerText;
  final Widget? centerWidget;
  final VoidCallback? onSearchTap;
  final VoidCallback? onAddTap;
  final bool showAdd;

  const CustomTopBar({
    Key? key,
    this.centerText,
    this.centerWidget,
    this.onSearchTap,
    this.onAddTap,
    this.showAdd = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final bool isLoggedIn = currentUser != null;

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

            // Center Content (Logo or Text)
            Expanded(
              child: Center(
                child: centerWidget ??
                    (centerText != null
                        ? Text(centerText!, style: TextConstants.mediumText)
                        : Image.asset(
                            'assets/images/small_logo.png',
                            height: 22.h,
                          )),
              ),
            ),

            // Right Action (Search or Add)
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
            else
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
              ),
          ],
        );
      },
    );
  }
}
