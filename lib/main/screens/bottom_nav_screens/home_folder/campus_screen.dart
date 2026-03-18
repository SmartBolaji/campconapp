import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/widgets/empty_state_view.dart';
import 'package:campcon/main/widgets/dialogs/campus_dialog.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/shimmer_card.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/post_widget.dart';
import 'package:campcon/main/widgets/navigate_profile_widget.dart';
import 'package:campcon/main/widgets/new_posts_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class CampusScreen extends StatefulWidget {
  const CampusScreen({super.key});

  @override
  State<CampusScreen> createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowCampusDialog();
    });
  }

  void _checkAndShowCampusDialog() async {
    if (_hasShownDialog) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final campus = authProvider.currentUser?.campus;

    // Show dialog if no campus selected
    if (campus == null || campus.isEmpty) {
      _hasShownDialog = true;

      final selectedCampus = await CampusDialog.show(
        context,
        onSelection: (campus) async {
          await authProvider.updateCampus(campus);
        },
      );

      // Load feed after selection
      if (selectedCampus != null && mounted) {
        feedProvider.loadCampusFeed(currentUserId, selectedCampus);
      }
    } else {
      // Load feed with existing campus
      feedProvider.loadCampusFeed(currentUserId, campus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final campus = authProvider.currentUser?.campus ?? '';

    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        // Show loading for initial load
        if (feedProvider.isLoadingCampus && feedProvider.campusPosts.isEmpty) {
          return ShimmerList(
            itemCount: 4,
            type: ShimmerCardType.post,
            padding: EdgeInsets.only(top: 12.h, bottom: 80.h),
          );
        }

        // Show error state
        if (feedProvider.errorCampus != null) {
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
                  feedProvider.errorCampus!,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () =>
                      feedProvider.retryCampusFeed(currentUserId, campus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: Text(
                    'Retry',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                )
              ],
            ),
          );
        }

        // Show empty state
        if (feedProvider.campusPosts.isEmpty) {
          return RefreshIndicator(
            onRefresh: () =>
                feedProvider.refreshCampusFeed(currentUserId, campus),
            color: AppTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildCampusHeader(campus),
                ),
                SliverFillRemaining(
                  child: EmptyStateView(
                    icon: Ph.graduation_cap,
                    title: 'No campus posts yet',
                    subtitle:
                        'Be the first to share what is happening around campus.',
                    buttonText: 'Retry',
                    onPressed: () =>
                        feedProvider.retryCampusFeed(currentUserId, campus),
                  ),
                ),
              ],
            ),
          );
        }

        // Show posts
        return RefreshIndicator(
          onRefresh: () =>
              feedProvider.refreshCampusFeed(currentUserId, campus),
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ✅ FLOATING BUTTON: SliverAppBar with styled container
              if (feedProvider.campusNewPostsCount > 0)
                SliverAppBar(
                  backgroundColor: AppTheme.surface,
                  elevation: 0,
                  floating: false,
                  pinned: true,
                  toolbarHeight: 57.h,
                  flexibleSpace: Container(
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
                    child: Center(
                      child: NewPostsButton(
                        newPostsCount: feedProvider.campusNewPostsCount,
                        isLoading: feedProvider.isLoadingNewCampus,
                        onPressed: () =>
                            feedProvider.loadNewCampusPosts(campus),
                      ),
                    ),
                  ),
                ),

              // Campus Header
              SliverToBoxAdapter(
                child: _buildCampusHeader(campus),
              ),

              // Posts List
              SliverPadding(
                padding: EdgeInsets.only(bottom: 80.sp),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= feedProvider.campusPosts.length) {
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

                      if (index >= feedProvider.campusPosts.length - 3 &&
                          feedProvider.campusHasMore &&
                          !feedProvider.isLoadingMoreCampus) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            context
                                .read<FeedProvider>()
                                .loadMoreCampusFeed(campus);
                          }
                        });
                      }

                      final postWithAuthor = feedProvider.campusPosts[index];
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
                              showFloatingSnackBar(
                                  context, 'Failed to like post');
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
                              final state =
                                  feedProvider.getPostState(post.postId);
                              showFloatingSnackBar(
                                context,
                                state.isReposted
                                    ? 'Reposted!'
                                    : 'Repost removed',
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
                                    style:
                                        TextStyle(color: AppTheme.textPrimary),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete this post? This action cannot be undone.',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary),
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
                                      onPressed: () =>
                                          Navigator.pop(context, true),
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
                    childCount: feedProvider.campusPosts.length +
                        (feedProvider.isLoadingMoreCampus ? 1 : 0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampusHeader(String campus) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.school,
              color: AppTheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campus.isEmpty ? 'Select Campus' : campus,
                  style: TextConstants.boldText.copyWith(
                    fontSize: 16.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Campus Community',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Change campus button
          InkWell(
            onTap: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final feedProvider =
                  Provider.of<FeedProvider>(context, listen: false);
              final currentUserId = authProvider.currentUser?.uid ?? '';

              final selectedCampus = await CampusDialog.show(
                context,
                onSelection: (campus) async {
                  await authProvider.updateCampus(campus);
                },
              );

              if (selectedCampus != null && mounted) {
                feedProvider.loadCampusFeed(currentUserId, selectedCampus);
              }
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                'Change',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
