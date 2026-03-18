import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/widgets/empty_state_view.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/shimmer_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:campcon/main/widgets/navigate_profile_widget.dart';
import 'package:campcon/main/widgets/new_posts_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.uid ?? '';

      feedProvider.loadFriendsFeed(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        if (feedProvider.isLoadingFriends) {
          return ShimmerList(
            itemCount: 4,
            type: ShimmerCardType.post,
            padding: EdgeInsets.only(top: 12.h, bottom: 80.h),
          );
        }

        if (feedProvider.errorFriends != null) {
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
                  feedProvider.errorFriends!,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => feedProvider.retryFriendsFeed(currentUserId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: Text(
                    'Retry',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (feedProvider.friendsPosts.isEmpty) {
          return EmptyStateView(
            icon: Ph.users_three,
            title: 'Nothing here yet',
            subtitle: 'Follow classmates and creators to see their posts here.',
            buttonText: 'Retry',
            onPressed: () => feedProvider.retryFriendsFeed(currentUserId),
          );
        }

        // ✅ FLOATING BUTTON: Stack with floating button on top
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => feedProvider.refreshFriendsFeed(currentUserId),
              color: AppTheme.primary,
              child: ListView.builder(
                itemCount: feedProvider.friendsPosts.length +
                    (feedProvider.isLoadingMoreFriends ? 1 : 0),
                padding: EdgeInsets.only(
                  top: feedProvider.friendsNewPostsCount > 0 ? 65.h : 0,
                  bottom: 80.sp,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index >= feedProvider.friendsPosts.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
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

                  if (index >= feedProvider.friendsPosts.length - 3 &&
                      feedProvider.friendsHasMore &&
                      !feedProvider.isLoadingMoreFriends) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context
                            .read<FeedProvider>()
                            .loadMoreFriendsFeed(currentUserId);
                      }
                    });
                  }

                  final postWithAuthor = feedProvider.friendsPosts[index];
                  final post = postWithAuthor.post;
                  final author = postWithAuthor.author;
                  final postState = feedProvider.getPostState(post.postId);
                  final isMyPost = post.userId == currentUserId;

                  return PostWidget(
                    key: ValueKey(post.postId),
                    post: post,
                    author: author,
                    postState: postState,
                    currentUserId: currentUserId,
                    onTap: () {
                      // Navigate to post view when post is tapped
                      navigateToPostView(
                        context: context,
                        post: post,
                        author: author,
                        postState: postState,
                        currentUserId: currentUserId,
                        feedProvider: feedProvider,
                        isMyPost: isMyPost,
                        focusComment: false,
                      );
                    },
                    onLike: () async {
                      try {
                        // Get current user from auth provider
                        final currentUser = authProvider.currentUser;

                        // Get post image URL (first image if available)
                        String? postImageUrl;
                        if (post.imageUrls.isNotEmpty) {
                          postImageUrl = post.imageUrls.first;
                        }

                        await feedProvider.toggleLike(
                          post.postId,
                          currentUserId,
                          post.userId,
                          Provider.of<NotifyProvider>(
                            context,
                            listen: false,
                          ),
                          currentUser,
                          postImageUrl,
                        );
                      } catch (e) {
                        if (mounted) {
                          showFloatingSnackBar(context, 'Failed to like post');
                        }
                      }
                    },
                    onComment: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostCommentsScreen(
                            postId: post.postId,
                            post: post,
                          ),
                        ),
                      );
                    },
                    onRepost: () async {
                      try {
                        await feedProvider.toggleRepost(
                            post.postId, currentUserId);
                        if (mounted) {
                          final state = feedProvider.getPostState(post.postId);
                          showFloatingSnackBar(
                            context,
                            state.isReposted ? 'Reposted!' : 'Repost removed',
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          showFloatingSnackBar(context, 'Failed to repost');
                        }
                      }
                    },
                    onShare: () {
                      PostOptionsWidget.showShareOptions(
                        context: context,
                        postId: post.postId,
                        postContent: post.content,
                      );
                    },
                    onBookmark: () async {
                      try {
                        await feedProvider.toggleBookmark(
                          post.postId,
                          currentUserId,
                        );
                      } catch (e) {
                        if (mounted) {
                          showFloatingSnackBar(
                              context, 'Failed to bookmark post');
                        }
                      }
                    },
                    onMoreOptions: () {
                      PostOptionsWidget.showPostOptions(
                        context: context,
                        isMyPost: isMyPost,
                        postId: post.postId,
                        onDelete: () async {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              title: Text(
                                'Delete Post',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              content: Text(
                                'Are you sure you want to delete this post? This action cannot be undone.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            try {
                              // Delete from Firestore first
                              await Provider.of<PostProvider>(context,
                                      listen: false)
                                  .deletePost(post.postId, post.imageUrls);
                              // Then remove from local feed
                              feedProvider.deletePostLocally(post.postId);
                              showFloatingSnackBar(context, 'Post deleted');
                            } catch (e) {
                              showFloatingSnackBar(
                                  context, 'Failed to delete post');
                            }
                          }
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
                  );
                },
              ),
            ),

            // ✅ FLOATING BUTTON: Positioned above scroll area with background
            if (feedProvider.friendsNewPostsCount > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border,
                        width: 0.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Center(
                    child: NewPostsButton(
                      newPostsCount: feedProvider.friendsNewPostsCount,
                      isLoading: feedProvider.isLoadingNewFriends,
                      onPressed: () =>
                          feedProvider.loadNewFriendsPosts(currentUserId),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
