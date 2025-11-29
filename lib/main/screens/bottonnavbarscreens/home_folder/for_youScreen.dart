import 'dart:async';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/post_folder/post_comments_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/post_folder/post_options.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/posts/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyForYouScreen extends StatefulWidget {
  const MyForYouScreen({super.key});

  @override
  State<MyForYouScreen> createState() => _MyForYouScreenState();
}

class _MyForYouScreenState extends State<MyForYouScreen> {
  bool _isLoading = true;
  List<PostWithAuthor> _posts = [];
  String? _error;
  StreamSubscription<List<PostWithAuthor>>? _postsSubscription;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated';
      });
      return;
    }

    try {
      // Cancel existing subscription
      await _postsSubscription?.cancel();

      // Load posts once
      final postsWithAuthors = await feedProvider.getPostsWithAuthors().first;

      // Initialize post states silently
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          feedProvider.checkIfLiked(postWithAuthor.post.postId, currentUserId),
          feedProvider.checkIfBookmarked(
              postWithAuthor.post.postId, currentUserId),
        ]);
      }

      if (mounted) {
        setState(() {
          _posts = postsWithAuthors;
          _isLoading = false;
        });
      }

      // Listen for updates ONCE (new posts, comment count changes, etc.)
      _postsSubscription = feedProvider.getPostsWithAuthors().listen(
        (newPosts) {
          if (!mounted) return;

          // Only update if there's actual change in post count or data
          if (newPosts.length != _posts.length) {
            setState(() {
              _posts = newPosts;
            });
          } else {
            // Check if comment counts changed
            bool hasChanges = false;
            for (int i = 0; i < newPosts.length; i++) {
              if (i < _posts.length &&
                  newPosts[i].post.comments != _posts[i].post.comments) {
                hasChanges = true;
                break;
              }
            }

            if (hasChanges) {
              setState(() {
                _posts = newPosts;
              });
            }
          }
        },
        onError: (error) {
          debugPrint('Stream error: $error');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load posts';
        });
      }
      debugPrint('Error loading posts: $e');
    }
  }

  Future<void> _refreshPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) return;

    try {
      // Just reload the posts, don't show loading indicator
      final postsWithAuthors = await feedProvider.getPostsWithAuthors().first;

      // Re-initialize post states
      for (var postWithAuthor in postsWithAuthors) {
        await Future.wait([
          feedProvider.checkIfLiked(postWithAuthor.post.postId, currentUserId),
          feedProvider.checkIfBookmarked(
              postWithAuthor.post.postId, currentUserId),
        ]);
      }

      if (mounted) {
        setState(() {
          _posts = postsWithAuthors;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      );
    }

    if (_error != null) {
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
              _error!,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadPosts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
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

    return Consumer<FeedProvider>(
      builder: (context, feedProvider, child) {
        return RefreshIndicator(
          onRefresh: _refreshPosts,
          color: AppTheme.primary,
          child: ListView.builder(
            itemCount: _posts.length,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final postWithAuthor = _posts[index];
              final post = postWithAuthor.post;
              final author = postWithAuthor.author;

              // Get post state from provider (updates silently)
              final postState = feedProvider.getPostState(post.postId);
              final isMyPost = post.userId == currentUserId;

              print(
                  'index: $index, postId: ${post.postId}, isMyPost: $isMyPost');

              return PostWidget(
                key: ValueKey(post.postId),
                post: post,
                author: author,
                postState: postState,
                currentUserId: currentUserId,
                onTap: () {
                  // TODO: Navigate to post detail screen
                  debugPrint('Post tapped: ${post.postId}');
                },
                onLike: () async {
                  try {
                    // This updates UI immediately via notifyListeners()
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
                  // ✅ Just navigate - stream will update comment count automatically
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: post.postId,
                      ),
                    ),
                  );
                },
                onRepost: () {
                  // TODO: Implement repost functionality
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
                    // This updates UI immediately via notifyListeners()
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
                      // Show confirmation dialog
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
                        // TODO: Implement delete post from Firestore
                        // Remove from local list immediately (optimistic update)
                        setState(() {
                          _posts.removeAt(index);
                        });

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
