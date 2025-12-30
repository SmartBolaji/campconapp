import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/profile/edit_profile_screen.dart';
import 'package:campcon/main/screens/profile/profile_option.dart';
import 'package:campcon/main/screens/profile/menu_screen.dart';
import 'package:campcon/main/screens/profile/widgets/profile_button_widget.dart';
import 'package:campcon/main/screens/profile/widgets/profile_header_widget.dart';
import 'package:campcon/main/screens/profile/widgets/profile_posts_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
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
            style: TextConstants.smallText.copyWith(
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

  // Show full bio in bottom sheet
  void _showFullBio(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
              child: Column(
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        backgroundImage: user.profileImageUrl != null &&
                                user.profileImageUrl!.isNotEmpty
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null ||
                                user.profileImageUrl!.isEmpty
                            ? Iconify(
                                Ph.user,
                                size: 24.sp,
                                color: AppTheme.primary,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? "No Name",
                              style: TextConstants.mediumText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "@${user.username}",
                              style: TextConstants.smallText.copyWith(
                                color: AppTheme.textLight,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                          size: 24.sp,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Divider
                  Container(
                    height: 1,
                    color: AppTheme.border,
                  ),

                  SizedBox(height: 24.h),

                  // Full Bio
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        user.aboutMe ?? '',
                        style: TextConstants.mediumText.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.6,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleFollowToggle() async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await _profileProvider.toggleFollow(followProvider: followProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Consumer2<AuthProvider, ProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          final profileUser = profileProvider.profileUser;
          final isLoading = profileProvider.isLoading;
          final errorMessage = profileProvider.errorMessage;
          final currentUserId = authProvider.currentUser?.uid ?? '';

          if (profileUser == null && isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

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
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

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
                      backgroundColor: AppTheme.surface,
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
                      // Add title that appears when collapsed
                      title: innerBoxIsScrolled
                          ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.1),
                                  backgroundImage:
                                      user.profileImageUrl != null &&
                                              user.profileImageUrl != ''
                                          ? NetworkImage(user.profileImageUrl!)
                                          : null,
                                  child: user.profileImageUrl == null ||
                                          user.profileImageUrl == ''
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.name ?? "No Name",
                                        style:
                                            TextConstants.mediumText.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "@${user.username}",
                                        style: TextConstants.smallText.copyWith(
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
                            )
                          : null,
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
                              currentUserActions:
                                  _buildCurrentUserActions(authProvider),
                              otherUserActions:
                                  _buildOtherUserActions(profileProvider),
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
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.border,
                                width: 1,
                              ),
                            ),
                            color: AppTheme.surface,
                          ),
                          child: TabBar(
                            indicatorColor: AppTheme.primary,
                            indicatorWeight: 2,
                            labelColor: AppTheme.primary,
                            unselectedLabelColor: AppTheme.textLight,
                            labelStyle: TextConstants.smallText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: TextConstants.smallText,
                            tabs: const [
                              Tab(text: "Posts"),
                              Tab(text: 'Reposts'),
                              Tab(text: "Media"),
                              Tab(text: "Saved"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Consumer2<ProfileProvider, FeedProvider>(
                builder: (context, profileProvider, feedProvider, child) {
                  return Padding(
                    padding: EdgeInsets.only(top: 135.h),
                    child: TabBarView(
                      children: [
                        // Posts tab
                        RefreshIndicator(
                          onRefresh: () =>
                              profileProvider.loadUserPosts(refresh: true),
                          color: AppTheme.primary,
                          child: CustomScrollView(
                            slivers: ProfilePostsList.buildSlivers(
                              context: context,
                              tabType: ProfileTabType.posts,
                              currentUserId: currentUserId,
                              provider: profileProvider,
                              feedProvider: feedProvider,
                              scrollController: ScrollController(),
                              onRefresh: () =>
                                  profileProvider.loadUserPosts(refresh: true),
                            ),
                          ),
                        ),
                        // Reposts tab
                        RefreshIndicator(
                          onRefresh: () =>
                              profileProvider.loadUserReposts(refresh: true),
                          color: AppTheme.primary,
                          child: CustomScrollView(
                            slivers: ProfilePostsList.buildSlivers(
                              context: context,
                              tabType: ProfileTabType.reposts,
                              currentUserId: currentUserId,
                              provider: profileProvider,
                              feedProvider: feedProvider,
                              scrollController: ScrollController(),
                              onRefresh: () => profileProvider.loadUserReposts(
                                  refresh: true),
                            ),
                          ),
                        ),
                        // Media tab
                        RefreshIndicator(
                          onRefresh: () =>
                              profileProvider.loadUserMedia(refresh: true),
                          color: AppTheme.primary,
                          child: CustomScrollView(
                            slivers: ProfilePostsList.buildSlivers(
                              context: context,
                              tabType: ProfileTabType.media,
                              currentUserId: currentUserId,
                              provider: profileProvider,
                              feedProvider: feedProvider,
                              scrollController: ScrollController(),
                              onRefresh: () =>
                                  profileProvider.loadUserMedia(refresh: true),
                            ),
                          ),
                        ),
                        // Saved tab
                        RefreshIndicator(
                          onRefresh: () =>
                              profileProvider.loadSavedPosts(refresh: true),
                          color: AppTheme.primary,
                          child: CustomScrollView(
                            slivers: ProfilePostsList.buildSlivers(
                              context: context,
                              tabType: ProfileTabType.saved,
                              currentUserId: currentUserId,
                              provider: profileProvider,
                              feedProvider: feedProvider,
                              scrollController: ScrollController(),
                              onRefresh: () =>
                                  profileProvider.loadSavedPosts(refresh: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserActions(AuthProvider authProvider) {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

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
                  // refresh profile (same logic you had)
                  _profileProvider.refreshProfile(
                    followProvider: followProvider,
                    updatedCurrentUser:
                        Provider.of<AuthProvider>(context, listen: false)
                            .currentUser,
                  );
                }
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ProfileButton(
            text: "Share",
            onTap: () {
              // Share profile logic
            },
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

  Widget _buildOtherUserActions(ProfileProvider profileProvider) {
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
                : _handleFollowToggle,
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
            onTap: () {
              // Message logic
            },
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => ProfileOptions.show(
            context,
            userName: profileProvider.profileUser?.name,
            onShare: () {
              // TODO: Implement share profile
            },
            onCopyLink: () {
              // TODO: Implement copy link
            },
            onReport: () {
              // TODO: Implement report user
            },
            onBlock: () {
              // TODO: Implement block user
            },
          ),
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
