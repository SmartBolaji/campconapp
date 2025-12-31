import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart'
    show PostState, FeedProvider;
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_view_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/navigate_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

enum ProfileTabType { posts, reposts, media, saved }

class ProfilePostsList {
  // Static method to build slivers for use in CustomScrollView
  static List<Widget> buildSlivers({
    required BuildContext context,
    required ProfileTabType tabType,
    required String currentUserId,
    required ProfileProvider provider,
    required FeedProvider feedProvider,
    required ScrollController scrollController,
    required Future<void> Function() onRefresh,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    
    final posts = _getPostsListStatic(provider, tabType);
    final isLoading = _isLoadingStatic(provider, tabType);
    final hasMore = _hasMoreStatic(provider, tabType);
    final isEmpty = posts.isEmpty && !isLoading;

    // Check if this is the saved tab and not current user
    if (tabType == ProfileTabType.saved && !provider.isCurrentUser) {
      return [
        SliverFillRemaining(
          child: Container(
            color: AppTheme.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border,
                      size: 64.sp, color: AppTheme.textLight),
                  SizedBox(height: 16.h),
                  Text(
                    'Saved posts are private',
                    style: TextConstants.smallText
                        .copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    // Loading state
    if (isLoading && posts.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      ];
    }

    // Empty state
    if (isEmpty) {
      return [
        SliverFillRemaining(
          child: _buildEmptyStateStatic(context, tabType),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == posts.length) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }

            final postWithAuthor = posts[index];
            final post = postWithAuthor.post;
            final author = postWithAuthor.author;
            final postState = provider.getPostState(post.postId);
            final isMyPost = post.userId == currentUserId;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Repost indicator
                if (postWithAuthor.repostedBy != null)
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 4.h),
                    child: Row(
                      children: [
                        Icon(Icons.repeat,
                            size: 14.sp, color: AppTheme.primary),
                        SizedBox(width: 6.w),
                        Text(
                          '${postWithAuthor.repostedBy!.name ?? postWithAuthor.repostedBy!.username} reposted',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                PostWidget(
                  key: ValueKey(post.postId),
                  post: post,
                  author: author,
                  postState: PostState(
                    likesCount: postState.likesCount,
                    repliesCount: postState.repliesCount,
                    repostsCount: postState.repostsCount,
                    isLiked: postState.isLiked,
                    isBookmarked: postState.isBookmarked,
                    isReposted: postState.isReposted,
                  ),
                  currentUserId: currentUserId,
                  onTap: () {
                    navigateToPostView(
                      context: context,
                      post: post,
                      author: author,
                      currentUserId: currentUserId,
                      postState: PostState(
                        likesCount: postState.likesCount,
                        repliesCount: postState.repliesCount,
                        repostsCount: postState.repostsCount,
                        isLiked: postState.isLiked,
                        isBookmarked: postState.isBookmarked,
                        isReposted: postState.isReposted,
                      ),
                      feedProvider: feedProvider,
                      isMyPost: isMyPost,
                      focusComment: false,
                    );
                  },
                  onLike: () async {
                    // Get current user from auth provider
                    final currentUser = authProvider.currentUser;

                    await provider.toggleLike(
                      post.postId,
                      post.userId,
                      Provider.of<NotifyProvider>(
                        context,
                        listen: false,
                      ),
                      currentUser,
                      post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
                    );
                  },
                  onComment: () {
                    navigateToPostView(
                      context: context,
                      post: post,
                      author: author,
                      currentUserId: currentUserId,
                      postState: PostState(
                        likesCount: postState.likesCount,
                        repliesCount: postState.repliesCount,
                        repostsCount: postState.repostsCount,
                        isLiked: postState.isLiked,
                        isBookmarked: postState.isBookmarked,
                        isReposted: postState.isReposted,
                      ),
                      feedProvider: feedProvider,
                      isMyPost: isMyPost,
                      focusComment: true,
                    );
                  },
                  onRepost: () async {
                    await provider.toggleRepost(post.postId);
                    final state = provider.getPostState(post.postId);
                    showFloatingSnackBar(
                      context,
                      state.isReposted ? 'Reposted!' : 'Repost removed',
                    );
                  },
                  onShare: () {
                    PostOptionsWidget.showShareOptions(
                      context: context,
                      postId: post.postId,
                      postContent: post.content,
                    );
                  },
                  onBookmark: () async {
                    await provider.toggleBookmark(post.postId);
                  },
                  onMoreOptions: () {
                    PostOptionsWidget.showPostOptions(
                      context: context,
                      isMyPost: isMyPost,
                      postId: post.postId,
                      onDelete: () async {
                        showFloatingSnackBar(context, 'Post deleted');
                      },
                      onShare: () {
                        PostOptionsWidget.showShareOptions(
                          context: context,
                          postId: post.postId,
                          postContent: post.content,
                        );
                      },
                    );
                  },
                  index: index,
                ),
              ],
            );
          },
          childCount: posts.length + (hasMore ? 1 : 0),
        ),
      ),
    ];
  }

  // Helper static methods
  static List<PostWithAuthorProfile> _getPostsListStatic(
      ProfileProvider provider, ProfileTabType tabType) {
    switch (tabType) {
      case ProfileTabType.posts:
        return provider.userPosts;
      case ProfileTabType.reposts:
        return provider.userReposts;
      case ProfileTabType.media:
        return provider.userMedia;
      case ProfileTabType.saved:
        return provider.savedPosts;
    }
  }

  static bool _isLoadingStatic(
      ProfileProvider provider, ProfileTabType tabType) {
    switch (tabType) {
      case ProfileTabType.posts:
        return provider.isLoadingPosts;
      case ProfileTabType.reposts:
        return provider.isLoadingReposts;
      case ProfileTabType.media:
        return provider.isLoadingMedia;
      case ProfileTabType.saved:
        return provider.isLoadingSaved;
    }
  }

  static bool _hasMoreStatic(ProfileProvider provider, ProfileTabType tabType) {
    switch (tabType) {
      case ProfileTabType.posts:
        return provider.hasMorePosts;
      case ProfileTabType.reposts:
        return provider.hasMoreReposts;
      case ProfileTabType.media:
        return provider.hasMoreMedia;
      case ProfileTabType.saved:
        return provider.hasMoreSaved;
    }
  }

  static Widget _buildEmptyStateStatic(
      BuildContext context, ProfileTabType tabType) {
    String message;
    IconData icon;

    switch (tabType) {
      case ProfileTabType.posts:
        message = 'No posts yet';
        icon = Icons.article_outlined;
        break;
      case ProfileTabType.reposts:
        message = 'No reposts yet';
        icon = Icons.repeat;
        break;
      case ProfileTabType.media:
        message = 'No media yet';
        icon = Icons.photo_library_outlined;
        break;
      case ProfileTabType.saved:
        message = 'No saved items yet';
        icon = Icons.bookmark_border;
        break;
    }

    return Container(
      color: AppTheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.sp, color: AppTheme.textLight),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextConstants.smallText
                  .copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
