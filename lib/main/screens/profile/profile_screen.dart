import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/profile/widgets/profile_header_widget.dart';
import 'package:campcon/main/screens/profile/widgets/profile_actions_section.dart';
import 'package:campcon/main/screens/profile/widgets/profile_tabs_section.dart';
import 'package:campcon/main/screens/profile/widgets/profile_tab_content.dart';
import 'package:campcon/main/screens/profile/widgets/full_bio_sheet.dart';
import 'package:campcon/main/widgets/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final UserModel? initialUserData;

  const ProfileScreen({
    this.userId,
    this.initialUserData,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Text key to measure bio length
  final GlobalKey _bioKey = GlobalKey();
  late ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _profileProvider.clearProfile();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    // Initialize with initial data if available
    if (widget.initialUserData != null) {
      _profileProvider.initProfile(
        initialUserData: widget.initialUserData,
        currentUserId: authProvider.currentUser?.uid,
      );
    }

    // Load full profile
    await _profileProvider.loadUserProfile(
      userId: widget.userId,
      initialUserData: widget.initialUserData ?? authProvider.currentUser,
      currentUserId: authProvider.currentUser?.uid,
      followProvider: followProvider,
    );

    // Check bio length after loading
    _checkBioLength();
  }

  // Check if bio is longer than 2 lines
  void _checkBioLength() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      if (_bioKey.currentContext != null &&
          profileProvider.profileUser != null) {
        final RenderBox renderBox =
            _bioKey.currentContext!.findRenderObject() as RenderBox;
        final textPainter = TextPainter(
          text: TextSpan(
            text: profileProvider.profileUser?.aboutMe ?? '',
            style: TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
              fontSize: 13.sp,
            ),
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: renderBox.size.width);

        profileProvider.setBioLong(textPainter.didExceedMaxLines);
      }
    });
  }

  void _showFullBio(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => FullBioSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer2<AuthProvider, ProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          final profileUser = profileProvider.profileUser;
          final isLoading = profileProvider.isLoading;
          final errorMessage = profileProvider.errorMessage;
          final currentUserId = authProvider.currentUser?.uid ?? '';

          // Loading state
          if (profileUser == null && isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          // Error state
          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: AppTheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (profileUser == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          final user = profileUser;
          final bool isCurrentUser = profileProvider.isCurrentUser;

          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverAppBar(
                      expandedHeight: profileProvider.hasBio ? 360.h : 330.h,
                      floating: false,
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      elevation: 0,
                      forceElevated: innerBoxIsScrolled,
                      leading: IconButton(
                        icon: Iconify(
                          Ph.arrow_left,
                          color: AppTheme.textPrimary,
                          size: 24.sp,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title:
                          innerBoxIsScrolled ? _buildAppBarTitle(user) : null,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Container(
                          color: AppTheme.surface,
                          child: SafeArea(
                            child: ProfileHeaderWidget(
                              user: user,
                              isLoading: isLoading,
                              isCurrentUser: isCurrentUser,
                              profileProvider: profileProvider,
                              bioKey: _bioKey,
                              onShowFullBio: () => _showFullBio(user),
                              currentUserActions: ProfileActionsSection(
                                user: user,
                                isCurrentUser: true,
                                profileProvider: profileProvider,
                                authProvider: authProvider,
                                onProfileUpdated: () {
                                  _loadUserProfile();
                                },
                              ),
                              otherUserActions: ProfileActionsSection(
                                user: user,
                                isCurrentUser: false,
                                profileProvider: profileProvider,
                                authProvider: authProvider,
                                onProfileUpdated: () {},
                              ),
                              followersCount: isLoading
                                  ? "0"
                                  : profileProvider.followersCount.toString(),
                              followingCount: isLoading
                                  ? "0"
                                  : profileProvider.followingCount.toString(),
                            ),
                          ),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(48.h),
                        child: const ProfileTabsSection(),
                      ),
                    ),
                  ),
                ];
              },
              body: Consumer<FeedProvider>(
                builder: (context, feedProvider, child) {
                  return ProfileTabContent(
                    currentUserId: currentUserId,
                    profileProvider: profileProvider,
                    feedProvider: feedProvider,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarTitle(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          backgroundImage:
              user.profileImageUrl != null && user.profileImageUrl != ''
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
          child: user.profileImageUrl == null || user.profileImageUrl == ''
              ? Iconify(
                  Ph.user,
                  size: 16.sp,
                  color: AppTheme.primary,
                )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.name ?? "No Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isProfessional) ...[
                    SizedBox(width: 4.w),
                    Iconify(Ph.star_fill,
                        size: 14.r, color: const Color(0xFFFFD700)),
                  ],
                  if (user.role.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    RoleBadge(role: user.role, size: 12),
                  ],
                ],
              ),
              Text(
                "@${user.username}",
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
