import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart' show FeedProvider, PostState;
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/provider/profile_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:campcon/main/widgets/empty_state_view.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/navigate_profile_widget.dart';
import 'package:campcon/main/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

enum ProfileTabType { posts, reposts, media, saved }

class ProfilePostsList {
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
    final activeUserId = authProvider.currentUser?.uid ?? currentUserId;

    final posts = _getPostsList(provider, tabType);
    final isLoading = _isLoading(provider, tabType);
    final hasMore = _hasMore(provider, tabType);

    if (tabType == ProfileTabType.saved && !provider.isCurrentUser) {
      return [
        const SliverFillRemaining(
          child: EmptyStateView(
            icon: Ph.bookmark_simple,
            title: 'Saved posts are private',
            subtitle: 'Only you can view your saved posts.',
          ),
        ),
      ];
    }

    if (isLoading && posts.isEmpty) {
      return [
        SliverFillRemaining(
          child: ShimmerList(
            itemCount: 4,
            type: ShimmerCardType.post,
            padding: EdgeInsets.only(top: 10.h, bottom: 80.h),
          ),
        ),
      ];
    }

    if (posts.isEmpty) {
      return [
        SliverFillRemaining(child: _buildEmptyState(tabType)),
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
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              );
            }

            if (index >= posts.length - 2 && hasMore && !isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                switch (tabType) {
                  case ProfileTabType.posts:
                    provider.loadUserPosts();
                    break;
                  case ProfileTabType.reposts:
                    provider.loadUserReposts();
                    break;
                  case ProfileTabType.media:
                    provider.loadUserMedia();
                    break;
                  case ProfileTabType.saved:
                    provider.loadSavedPosts();
                    break;
                }
              });
            }

            final postWithAuthor = posts[index];
            final post = postWithAuthor.post;
            final author = postWithAuthor.author;
            final postState = provider.getPostState(post.postId);
            final isMyPost = post.userId == activeUserId;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (postWithAuthor.repostedBy != null)
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 4.h),
                    child: Row(
                      children: [
                        Icon(Icons.repeat, size: 14.sp, color: AppTheme.primary),
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
                  currentUserId: activeUserId,
                  onTap: () {
                    navigateToPostView(
                      context: context,
                      post: post,
                      author: author,
                      currentUserId: activeUserId,
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
                    final currentUser = authProvider.currentUser;
                    await provider.toggleLike(
                      post.postId,
                      post.userId,
                      Provider.of<NotifyProvider>(context, listen: false),
                      currentUser,
                      post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
                    );
                  },
                  onComment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostCommentsScreen(postId: post.postId, post: post),
                      ),
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

  static List<PostWithAuthorProfile> _getPostsList(
    ProfileProvider provider,
    ProfileTabType tabType,
  ) {
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

  static bool _isLoading(ProfileProvider provider, ProfileTabType tabType) {
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

  static bool _hasMore(ProfileProvider provider, ProfileTabType tabType) {
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

  static Widget _buildEmptyState(ProfileTabType tabType) {
    switch (tabType) {
      case ProfileTabType.posts:
        return const EmptyStateView(
          icon: Ph.article,
          title: 'No posts yet',
          subtitle: 'When posts are shared, they will show up here.',
        );
      case ProfileTabType.reposts:
        return const EmptyStateView(
          icon: Ph.repeat,
          title: 'No reposts yet',
          subtitle: 'Reposted content will appear here.',
        );
      case ProfileTabType.media:
        return const EmptyStateView(
          icon: Ph.image_square,
          title: 'No media yet',
          subtitle: 'Photos and videos will appear here.',
        );
      case ProfileTabType.saved:
        return const EmptyStateView(
          icon: Ph.bookmark_simple,
          title: 'No saved items yet',
          subtitle: 'Saved posts are shown here for quick access.',
        );
    }
  }
}
