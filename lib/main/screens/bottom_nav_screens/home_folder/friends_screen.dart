import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64.sp,
                  color: AppTheme.textLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No posts yet',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Follow people to see their posts here',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => feedProvider.refreshFriendsFeed(currentUserId),
          color: AppTheme.primary,
          child: ListView.builder(
            itemCount: feedProvider.friendsPosts.length,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
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
                  debugPrint('Post tapped: ${post.postId}');
                },
                onLike: () async {
                  try {
                    await feedProvider.toggleLike(
                      post.postId,
                      currentUserId,
                      post.userId,
                    );
                  } catch (e) {
                    if (mounted) {
                      showFloatingSnackBar(context, 'Failed to like post');
                    }
                  }
                },
                onComment: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: post.postId,
                      ),
                    ),
                  );
                },
                onRepost: () {
                  debugPrint('Repost: ${post.postId}');
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
