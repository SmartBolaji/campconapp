import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/follow_provider.dart';
import 'package:campcon/main/screens/profile/edit_profile_screen.dart';
import 'package:campcon/main/screens/profile/settings_screen.dart';
import 'package:campcon/main/widgets/profile_widget/profile_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  UserModel? profileUser;
  bool isLoading = true;
  String? errorMessage;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  bool isFollowLoading = false;

  // ✅ Text key to measure bio length
  final GlobalKey _bioKey = GlobalKey();
  bool _isBioLong = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialUserData != null) {
      setState(() {
        profileUser = widget.initialUserData;
        isLoading = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _checkBioLength();
    });
  }

  // ✅ Check if bio is longer than 2 lines
  void _checkBioLength() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bioKey.currentContext != null) {
        final RenderBox renderBox =
            _bioKey.currentContext!.findRenderObject() as RenderBox;
        final textPainter = TextPainter(
          text: TextSpan(
            text: profileUser?.aboutMe ?? '',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
              fontSize: 13.sp,
            ),
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: renderBox.size.width);

        final isOverflowing = textPainter.didExceedMaxLines;
        if (isOverflowing != _isBioLong) {
          setState(() {
            _isBioLong = isOverflowing;
          });
        }
      }
    });
  }

  // ✅ Show full bio in bottom sheet
  void _showFullBio() {
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
                        backgroundImage: profileUser?.profileImageUrl != null &&
                                profileUser!.profileImageUrl!.isNotEmpty
                            ? NetworkImage(profileUser!.profileImageUrl!)
                            : null,
                        child: profileUser?.profileImageUrl == null ||
                                profileUser!.profileImageUrl!.isEmpty
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
                              profileUser?.name ?? "No Name",
                              style: TextConstants.mediumText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "@${profileUser?.username ?? ''}",
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
                        profileUser?.aboutMe ?? '',
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

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    try {
      String targetUserId = widget.userId ??
          widget.initialUserData?.uid ??
          authProvider.currentUser?.uid ??
          '';

      if (targetUserId.isEmpty) {
        setState(() {
          errorMessage = 'User not logged in or ID not provided.';
          isLoading = false;
        });
        return;
      }

      bool needsFetch = widget.initialUserData == null ||
          targetUserId == authProvider.currentUser?.uid;

      if (needsFetch) {
        if (targetUserId == authProvider.currentUser?.uid) {
          setState(() {
            profileUser = authProvider.currentUser;
          });
        } else {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(targetUserId)
              .get();

          if (doc.exists && doc.data() != null) {
            setState(() {
              profileUser =
                  UserModel.fromMap(doc.data() as Map<String, dynamic>);
            });
          } else {
            setState(() {
              errorMessage = 'User profile not found.';
              isLoading = false;
            });
            return;
          }
        }
      }

      final counts = await followProvider.getFollowCounts(targetUserId);
      setState(() {
        followersCount = counts['followers']!;
        followingCount = counts['following']!;
      });

      if (targetUserId != authProvider.currentUser?.uid &&
          authProvider.currentUser != null) {
        final following = await followProvider.checkIfFollowing(
          authProvider.currentUser!.uid,
          targetUserId,
        );
        setState(() {
          isFollowing = following;
        });
      }

      setState(() {
        isLoading = false;
      });

      // ✅ Recheck bio length after loading
      _checkBioLength();
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _handleFollowToggle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    if (authProvider.currentUser == null || profileUser == null) return;

    setState(() {
      isFollowLoading = true;
    });

    final success = await followProvider.toggleFollow(
      authProvider.currentUser!.uid,
      profileUser!.uid,
    );

    if (success) {
      setState(() {
        isFollowing = !isFollowing;
        followersCount += isFollowing ? 1 : -1;
      });
    }

    setState(() {
      isFollowLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (profileUser == null) {
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
                    errorMessage!,
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final user = profileUser!;
          final bool isCurrentUser = user.uid == authProvider.currentUser?.uid;

          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340.h, // ✅ Fixed height
                    floating: false,
                    pinned: true,
                    backgroundColor: AppTheme.surface,
                    elevation: 0,
                    leading: IconButton(
                      icon: Iconify(
                        Ph.arrow_left,
                        color: AppTheme.textPrimary,
                        size: 24.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: AppTheme.surface,
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 0),
                            child: Column(
                              children: [
                                // Profile Image
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 40.r,
                                      backgroundColor:
                                          AppTheme.primary.withOpacity(0.1),
                                      backgroundImage: user.profileImageUrl !=
                                                  null &&
                                              user.profileImageUrl != ''
                                          ? NetworkImage(user.profileImageUrl!)
                                          : null,
                                      child: user.profileImageUrl == null ||
                                              user.profileImageUrl == ''
                                          ? Iconify(
                                              Ph.user,
                                              size: 40.sp,
                                              color: AppTheme.primary,
                                            )
                                          : null,
                                    ),
                                    // ✅ Loading indicator overlay while fetching full data
                                    if (isLoading)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: 20.w,
                                              height: 20.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  AppTheme.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 16.h),

                                // Name & Username
                                Text(
                                  user.name ?? "No Name",
                                  style: TextConstants.mediumText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "@${user.username}",
                                  style: TextConstants.smallText.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 12.h),

                                // ✅ Bio with "See more" functionality
                                if (user.aboutMe != null &&
                                    user.aboutMe!.isNotEmpty) ...[
                                  GestureDetector(
                                    onTap: _isBioLong ? _showFullBio : null,
                                    child: Container(
                                      key: _bioKey,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: user.aboutMe!,
                                              style: TextConstants.smallText
                                                  .copyWith(
                                                color: AppTheme.textPrimary,
                                                height: 1.5,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                            if (_isBioLong)
                                              TextSpan(
                                                text: '... ',
                                                style: TextConstants.smallText
                                                    .copyWith(
                                                  color: AppTheme.textPrimary,
                                                  height: 1.5,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                            if (_isBioLong)
                                              TextSpan(
                                                text: 'See more',
                                                style: TextConstants.smallText
                                                    .copyWith(
                                                  color: AppTheme.primary,
                                                  height: 1.5,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                ],

                                // Followers & Following
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ✅ Show loading state for counts
                                    _buildStatItem(
                                      isLoading
                                          ? "..."
                                          : followersCount.toString(),
                                      "Followers",
                                    ),
                                    SizedBox(width: 32.w),
                                    _buildStatItem(
                                      isLoading
                                          ? "..."
                                          : followingCount.toString(),
                                      "Following",
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16.h),

                                // Action Buttons
                                if (isCurrentUser)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ProfileButton(
                                          text: "Edit",
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  AppTheme.background,
                                              builder: (context) =>
                                                  const Editprofile(),
                                            ).then((updated) {
                                              if (updated == true) {
                                                setState(() {});
                                                _loadUserProfile();
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
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Iconify(
                                            Ph.gear,
                                            color: AppTheme.textPrimary,
                                            size: 24.sp,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: const SettingsScreen(),
                                              duration: const Duration(
                                                  milliseconds: 300),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ProfileButton(
                                          text: isFollowLoading
                                              ? "..."
                                              : isFollowing
                                                  ? "Following"
                                                  : "Follow",
                                          onTap: isFollowLoading || isLoading
                                              ? null
                                              : _handleFollowToggle,
                                          backgroundColor: isFollowing
                                              ? AppTheme.buttonBorder
                                              : AppTheme.primary,
                                          textColor: isFollowing
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
                                      Container(
                                        height: 40.h,
                                        width: 40.w,
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surface,
                                          border: Border.all(
                                            color: AppTheme.border,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        child: Iconify(
                                          Ph.share_network,
                                          color: AppTheme.textPrimary,
                                          size: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                ];
              },
              body: TabBarView(
                children: [
                  _buildTabContent("No posts yet"),
                  _buildTabContent("No reposts yet"),
                  _buildTabContent("No media yet"),
                  _buildTabContent("No saved items yet"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: TextConstants.mediumText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 5.h),
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(String emptyMessage) {
    return Container(
      color: AppTheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyMessage,
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
