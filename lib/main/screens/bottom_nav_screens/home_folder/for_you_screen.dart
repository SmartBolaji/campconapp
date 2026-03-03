import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:campcon/main/widgets/navigate_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyForYouScreen extends StatefulWidget {
  const MyForYouScreen({super.key});

  @override
  State<MyForYouScreen> createState() => _MyForYouScreenState();
}

class _MyForYouScreenState extends State<MyForYouScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.uid ?? '';

      feedProvider.loadForYouFeed(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        if (feedProvider.isLoadingForYou) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          );
        }

        if (feedProvider.errorForYou != null) {
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
                  feedProvider.errorForYou!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => feedProvider.retryForYouFeed(currentUserId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (feedProvider.forYouPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add,
                  size: 64.sp,
                  color: AppTheme.textLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Be the first to create a post!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => feedProvider.loadForYouFeed(currentUserId),
          color: AppTheme.primary,
          child: ListView.builder(
            itemCount: feedProvider.forYouPosts.length,
            padding: EdgeInsets.only(bottom: 80.sp),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final postWithAuthor = feedProvider.forYouPosts[index];
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
                  // Navigate to post view with comment focus
                  navigateToPostView(
                    context: context,
                    post: post,
                    author: author,
                    postState: postState,
                    currentUserId: currentUserId,
                    feedProvider: feedProvider,
                    isMyPost: isMyPost,
                    focusComment: true, // Focus the comment input
                  );
                },
                onRepost: () async {
                  try {
                    await feedProvider.toggleRepost(post.postId, currentUserId);
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
                      showFloatingSnackBar(context, 'Failed to bookmark post');
                    }
                  }
                },
                onMoreOptions: () {
                  PostOptionsWidget.showPostOptions(
                    context: context,
                    isMyPost: isMyPost,
                    postId: post.postId,
                    post: post,
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
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppTheme.textSecondary),
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
                        feedProvider.deletePostLocally(post.postId);
                        showFloatingSnackBar(context, 'Post deleted');
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
        );
      },
    );
  }
}
