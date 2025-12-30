// Navigate to post view
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_view_widget.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';

void navigateToPostView({
  required BuildContext context,
  bool mounted = true,
  required PostModel post,
  required UserModel? author,
  required PostState postState, // Keep for backward compatibility but not used
  required String currentUserId,
  required FeedProvider feedProvider,
  required bool isMyPost,
  bool focusComment = false,
}) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.rightToLeft,
      child: PostViewScreen(
        post: post,
        author: author,
        currentUserId: currentUserId,
        focusComment: focusComment,
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
                Navigator.pop(context); // Close the post view
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
      ),
      duration: const Duration(milliseconds: 300),
    ),
  );
}
