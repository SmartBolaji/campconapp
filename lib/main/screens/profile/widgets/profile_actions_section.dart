import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/profile/profile_option.dart';
import 'package:campcon/main/screens/profile/menu_screen.dart';
import 'package:campcon/main/screens/profile/widgets/profile_button_widget.dart';
import 'package:campcon/main/screens/profile/widgets/profile_dialogs.dart';
import 'package:campcon/main/screens/profile/edit_profile_screen.dart';
import 'package:campcon/main/services/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ProfileActionsSection extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final ProfileProvider profileProvider;
  final AuthProvider authProvider;
  final VoidCallback onProfileUpdated;

  const ProfileActionsSection({
    required this.user,
    required this.isCurrentUser,
    required this.profileProvider,
    required this.authProvider,
    required this.onProfileUpdated,
    super.key,
  });

  String _profileDeepLink(UserModel? user) {
    final uid = user?.uid ?? '';
    return 'https://campcon.app/profile/$uid';
  }

  void _shareProfile(UserModel? user) {
    final link = _profileDeepLink(user);
    final name = user?.name ?? user?.username ?? 'someone';
    Share.share(
      'Check out $name\'s profile on Campcon: $link',
      subject: '$name on Campcon',
    );
  }

  void _copyProfileLink(UserModel? user, BuildContext context) {
    // Removed unused clipboard code - to be implemented via native channel if needed
    final link = _profileDeepLink(user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile link: $link')),
    );
  }

  Future<void> _handleFollowToggle(BuildContext context) async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await profileProvider.toggleFollow(followProvider: followProvider);
  }

  @override
  Widget build(BuildContext context) {
    return isCurrentUser
        ? _buildCurrentUserActions(context)
        : _buildOtherUserActions(context);
  }

  Widget _buildCurrentUserActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ProfileButton(
            text: "Edit",
            onTap: () {
              Navigator.push<bool>(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const EditProfileScreen(),
                  duration: const Duration(milliseconds: 300),
                ),
              ).then((updated) {
                if (updated == true) {
                  final followProvider =
                      Provider.of<FollowProvider>(context, listen: false);
                  profileProvider.refreshProfile(
                    followProvider: followProvider,
                    updatedCurrentUser: authProvider.currentUser,
                  );
                  onProfileUpdated();
                }
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ProfileButton(
            text: "Share",
            onTap: () => _shareProfile(user),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          child: Container(
            height: 40.h,
            width: 40.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.buttonBorder,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Iconify(
              Ph.dots_three,
              color: AppTheme.textPrimary,
              size: 18.sp,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const MenuScreen(),
                duration: const Duration(milliseconds: 300),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOtherUserActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ProfileButton(
            text: profileProvider.isLoading
                ? "..."
                : profileProvider.isFollowing
                    ? "Following"
                    : "Follow",
            onTap: profileProvider.isFollowLoading || profileProvider.isLoading
                ? null
                : () => _handleFollowToggle(context),
            backgroundColor: profileProvider.isFollowing
                ? AppTheme.buttonBorder
                : AppTheme.primary,
            textColor: profileProvider.isFollowing
                ? AppTheme.textPrimary
                : AppTheme.white,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ProfileButton(
            text: "Message",
            onTap: () => NavigationHelper.openChat(context, otherUser: user),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () {
            final currentUserId = authProvider.currentUser?.uid ?? '';
            ProfileOptions.show(
              context,
              userName: user.name,
              onShare: () => _shareProfile(user),
              onCopyLink: () => _copyProfileLink(user, context),
              onReport: () => ProfileDialogs.showReportDialog(
                context,
                currentUserId,
                user.uid,
                user.name ?? 'User',
                () {},
              ),
              onBlock: () => ProfileDialogs.blockUser(
                context,
                currentUserId,
                user.uid,
                user.name ?? 'User',
                () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          },
          child: Container(
            height: 40.h,
            width: 40.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(
                color: AppTheme.border,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Iconify(
              Ph.dots_three,
              color: AppTheme.textPrimary,
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }
}
