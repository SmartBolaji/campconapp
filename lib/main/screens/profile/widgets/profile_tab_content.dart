import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/profile/widgets/profile_posts_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTabContent extends StatelessWidget {
  final String currentUserId;
  final ProfileProvider profileProvider;
  final FeedProvider feedProvider;

  const ProfileTabContent({
    required this.currentUserId,
    required this.profileProvider,
    required this.feedProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 135.h),
      child: TabBarView(
        children: [
          // Posts tab
          RefreshIndicator(
            onRefresh: () => profileProvider.loadUserPosts(refresh: true),
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: ProfilePostsList.buildSlivers(
                context: context,
                tabType: ProfileTabType.posts,
                currentUserId: currentUserId,
                provider: profileProvider,
                feedProvider: feedProvider,
                scrollController: ScrollController(),
                onRefresh: () => profileProvider.loadUserPosts(refresh: true),
              ),
            ),
          ),
          // Reposts tab
          RefreshIndicator(
            onRefresh: () => profileProvider.loadUserReposts(refresh: true),
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: ProfilePostsList.buildSlivers(
                context: context,
                tabType: ProfileTabType.reposts,
                currentUserId: currentUserId,
                provider: profileProvider,
                feedProvider: feedProvider,
                scrollController: ScrollController(),
                onRefresh: () => profileProvider.loadUserReposts(refresh: true),
              ),
            ),
          ),
          // Media tab
          RefreshIndicator(
            onRefresh: () => profileProvider.loadUserMedia(refresh: true),
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: ProfilePostsList.buildSlivers(
                context: context,
                tabType: ProfileTabType.media,
                currentUserId: currentUserId,
                provider: profileProvider,
                feedProvider: feedProvider,
                scrollController: ScrollController(),
                onRefresh: () => profileProvider.loadUserMedia(refresh: true),
              ),
            ),
          ),
          // Saved tab
          RefreshIndicator(
            onRefresh: () => profileProvider.loadSavedPosts(refresh: true),
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: ProfilePostsList.buildSlivers(
                context: context,
                tabType: ProfileTabType.saved,
                currentUserId: currentUserId,
                provider: profileProvider,
                feedProvider: feedProvider,
                scrollController: ScrollController(),
                onRefresh: () => profileProvider.loadSavedPosts(refresh: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
