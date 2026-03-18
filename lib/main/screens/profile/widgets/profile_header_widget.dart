import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/new_post.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/full_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserModel user;
  final bool isLoading;
  final bool isCurrentUser;
  final ProfileProvider profileProvider;
  final GlobalKey bioKey;
  final VoidCallback onShowFullBio;
  final Widget currentUserActions;
  final Widget otherUserActions;
  final String followersCount;
  final String followingCount;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.isLoading,
    required this.isCurrentUser,
    required this.profileProvider,
    required this.bioKey,
    required this.onShowFullBio,
    required this.currentUserActions,
    required this.otherUserActions,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 50.h, 24.w, 0),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              GestureDetector(
                onTap:
                    user.profileImageUrl != null && user.profileImageUrl != ''
                        ? () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: FullScreenImageView(
                                  imageUrls: [user.profileImageUrl!],
                                  isLiked: false,
                                  onLike: () {},
                                  initialIndex: 0,
                                  showLikeButton: false,
                                ),
                              ),
                            );
                          }
                        : null,
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  backgroundImage:
                      user.profileImageUrl != null && user.profileImageUrl != ''
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                  child:
                      user.profileImageUrl == null || user.profileImageUrl == ''
                          ? Iconify(
                              Ph.user,
                              size: 40.sp,
                              color: AppTheme.primary,
                            )
                          : null,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Plus icon badge at bottom right - only show for current user
              if (isCurrentUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: const NewPostScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Container(
                      height: 30.w,
                      width: 30.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Iconify(
                          Ph.plus,
                          size: 16.sp,
                          color: AppTheme.white,
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

          // Bio with "See more" functionality
          if (user.aboutMe != null && user.aboutMe!.isNotEmpty) ...[
            GestureDetector(
              onTap: profileProvider.isBioLong ? onShowFullBio : null,
              child: Container(
                key: bioKey,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: user.aboutMe!,
                        style: TextConstants.smallText.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.5,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (profileProvider.isBioLong)
                        TextSpan(
                          text: '... ',
                          style: TextConstants.smallText.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.5,
                            fontSize: 13.sp,
                          ),
                        ),
                      if (profileProvider.isBioLong)
                        TextSpan(
                          text: 'See more',
                          style: TextConstants.smallText.copyWith(
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
              _buildStatItem(followersCount, "Followers"),
              SizedBox(width: 32.w),
              _buildStatItem(followingCount, "Following"),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          isCurrentUser ? currentUserActions : otherUserActions,
        ],
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
}
