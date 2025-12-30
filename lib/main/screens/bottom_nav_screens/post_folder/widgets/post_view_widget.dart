import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_options.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:campcon/main/widgets/format_time.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/image_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostViewScreen extends StatefulWidget {
  final PostModel post;
  final UserModel? author;
  final String currentUserId;
  final VoidCallback? onLike;
  final VoidCallback? onRepost;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onMoreOptions;
  final bool focusComment;

  const PostViewScreen({
    super.key,
    required this.post,
    this.author,
    required this.currentUserId,
    this.onLike,
    this.onRepost,
    this.onShare,
    this.onBookmark,
    this.onMoreOptions,
    this.focusComment = false,
  });

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });

    // Focus comment input if requested
    if (widget.focusComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _commentFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToProfile(BuildContext context) {
    final initialUserData = widget.author ??
        UserModel(
          uid: widget.post.userId,
          email: '',
          username: widget.post.username,
          name: widget.post.username,
          profileImageUrl: '',
          phoneNumber: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: ProfileScreen(
          userId: widget.post.userId,
          initialUserData: initialUserData,
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _postComment(FeedProvider feedProvider) async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .collection('comments')
          .add({
        'userId': widget.currentUserId,
        'username': userData['name'] ?? userData['username'] ?? 'User',
        'userAvatar': userData['profileImageUrl'] ?? '',
        'comment': _commentController.text.trim(),
        'created': FieldValue.serverTimestamp(),
        'likes': 0,
      });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'comments': FieldValue.increment(1),
      });

      // Update replies count in provider
      feedProvider.updateRepliesCount(widget.post.postId, 1);

      _commentController.clear();
      _commentFocusNode.unfocus();
    } catch (e) {
      debugPrint('Error posting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _focusCommentInput() {
    _commentFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.post.imageUrls.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final displayName = widget.author?.name ?? widget.post.username;
    final displayImage = widget.author?.profileImageUrl ?? '';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        surfaceTintColor: AppTheme.surface,
        leading: IconButton(
          icon: Iconify(
            Ph.arrow_left,
            color: AppTheme.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppTheme.textLight),
            onPressed: widget.onMoreOptions,
          ),
        ],
      ),
      // ✅ Wrap body with Consumer to get live state updates
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          final postState = feedProvider.getPostState(widget.post.postId);

          return Column(
            children: [
              Container(
                height: 1,
                color: AppTheme.border,
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildPostContent(
                        hasImages: hasImages,
                        screenWidth: screenWidth,
                        displayName: displayName,
                        displayImage: displayImage,
                        postState: postState, // ✅ Pass live state
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.border, width: 1),
                            bottom:
                                BorderSide(color: AppTheme.border, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Comments',
                              style: TextConstants.mediumText.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                '${postState.repliesCount}', // ✅ Live count
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.post.postId)
                          .collection('comments')
                          .orderBy('created', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.w),
                                child: CircularProgressIndicator(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 50),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mode_comment_outlined,
                                      size: 48.sp,
                                      color: AppTheme.textLight,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'No comments yet',
                                      style: TextConstants.mediumText.copyWith(
                                        fontSize: 15.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      'Be the first to comment!',
                                      style: TextConstants.smallText.copyWith(
                                        fontSize: 13.sp,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var comment = snapshot.data!.docs[index];
                              return _buildComment(comment, feedProvider);
                            },
                            childCount: snapshot.data!.docs.length,
                          ),
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 20.h),
                    ),
                  ],
                ),
              ),
              _buildCommentInput(feedProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostContent({
    required bool hasImages,
    required double screenWidth,
    required String displayName,
    required String displayImage,
    required PostState postState, // ✅ Accept live state
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(context),
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppTheme.primaryBackground,
                    backgroundImage: displayImage.isNotEmpty
                        ? NetworkImage(displayImage)
                        : null,
                    child: displayImage.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 22.sp,
                            color: AppTheme.primary,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToProfile(context),
                        child: Text(
                          displayName,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        formatDateTime(widget.post.createdAt),
                        style: TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                widget.post.content,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),

          // Images
          if (hasImages) ...[
            SizedBox(height: 12.h),
            if (widget.post.imageUrls.length == 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ImagePageViewWidget(
                  imageUrls: widget.post.imageUrls,
                  showFullScreenButton: false,
                  isLiked: postState.isLiked, // ✅ Live state
                  onLike: widget.onLike ?? () {},
                  width: screenWidth - 32.w,
                ),
              )
            else
              ImagePageViewWidget(
                imageUrls: widget.post.imageUrls,
                showFullScreenButton: false,
                isLiked: postState.isLiked, // ✅ Live state
                onLike: widget.onLike ?? () {},
                width: screenWidth,
              ),
          ],

          SizedBox(height: 16.h),

          // Engagement stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                if (postState.likesCount > 0) ...[
                  Text(
                    '${_formatCount(postState.likesCount)} likes',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                if (postState.repliesCount > 0) ...[
                  Text(
                    '${_formatCount(postState.repliesCount)} comments',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                if (postState.repostsCount > 0)
                  Text(
                    '${_formatCount(postState.repostsCount)} reposts',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Action buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: FeatherIcons.messageCircle,
                  label: 'Comment',
                  onTap: _focusCommentInput,
                ),
                _buildActionButton(
                  icon: FeatherIcons.repeat,
                  label: 'Repost',
                  onTap: widget.onRepost,
                  isActive: postState.isReposted, // ✅ Live state
                  activeColor: AppTheme.primary,
                ),
                _buildActionButton(
                  icon: postState.isLiked // ✅ Live state
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: 'Like',
                  onTap: widget.onLike,
                  isActive: postState.isLiked, // ✅ Live state
                  activeColor: AppTheme.error,
                ),
                _buildActionButton(
                  icon: FeatherIcons.send,
                  label: 'Share',
                  onTap: widget.onShare,
                ),
                _buildActionButton(
                  icon: postState.isBookmarked // ✅ Live state
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  label: 'Save',
                  onTap: widget.onBookmark,
                  isActive: postState.isBookmarked, // ✅ Live state
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: isActive
                ? (activeColor ?? AppTheme.primary)
                : AppTheme.textLight,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              color: isActive
                  ? (activeColor ?? AppTheme.primary)
                  : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(DocumentSnapshot comment, FeedProvider feedProvider) {
    String username = comment.get('username') ?? 'User';
    String userAvatar = comment.get('userAvatar') ?? '';
    String commentText = comment.get('comment') ?? '';
    Timestamp? timestamp = comment.get('created');
    String timeAgo =
        timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now';
    String userId = comment.get('userId') ?? '';
    bool isMyComment = userId == widget.currentUserId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppTheme.primaryBackground,
            backgroundImage: userAvatar.isNotEmpty
                ? CachedNetworkImageProvider(userAvatar)
                : null,
            child: userAvatar.isEmpty
                ? Icon(Icons.person, size: 18.sp, color: AppTheme.primary)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '$username ',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: commentText),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  timeAgo,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (isMyComment)
            GestureDetector(
              onTap: () => CommentOptionsWidget.showCommentOptions(
                context: context,
                commentId: comment.id,
                onDelete: () => _deleteComment(comment.id, feedProvider),
              ),
              child: Icon(
                Icons.more_vert,
                size: 18.sp,
                color: AppTheme.textLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(FeedProvider feedProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 100.h),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextConstants.smallText.copyWith(
                        color: AppTheme.textLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: _isPosting ? null : () => _postComment(feedProvider),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _commentController.text.trim().isNotEmpty
                        ? AppTheme.primary
                        : AppTheme.textLight.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: _isPosting
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 20.sp,
                          color: AppTheme.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteComment(
      String commentId, FeedProvider feedProvider) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'comments': FieldValue.increment(-1),
      });

      // Update replies count in provider
      feedProvider.updateRepliesCount(widget.post.postId, -1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment deleted'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.textPrimary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
