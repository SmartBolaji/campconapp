import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/comment_model.dart';
import 'package:campcon/main/models/post_model.dart';
import 'package:campcon/main/provider/feed_provider.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCommentsScreen extends StatefulWidget {
  final String postId;
  final PostModel? post;

  const PostCommentsScreen({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isPosting = false;

  // Reply state
  String? _replyToCommentId;
  String? _replyToUsername;

  // Optimistic comments
  final List<CommentModel> _optimisticComments = [];

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _setReplyTo(String commentId, String username) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUsername = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final username = userData['name'] ?? userData['username'] ?? 'User';
      final userAvatar = userData['profileImageUrl'] ?? '';
      final isVerified = userData['isVerified'] ?? false;

      // Optimistic insert
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final optimistic = CommentModel(
        commentId: tempId,
        postId: widget.postId,
        userId: currentUser.uid,
        username: username,
        userAvatar: userAvatar,
        isVerified: isVerified,
        text: text,
        createdAt: DateTime.now(),
        replyTo: _replyToCommentId,
        replyToUsername: _replyToUsername,
      );

      setState(() {
        _optimisticComments.add(optimistic);
      });

      _commentController.clear();
      _cancelReply();

      // Firestore write
      final commentData = {
        'postId': widget.postId,
        'userId': currentUser.uid,
        'username': username,
        'userAvatar': userAvatar,
        'isVerified': isVerified,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': <String>[],
        'replyTo': optimistic.replyTo,
        'replyToUsername': optimistic.replyToUsername,
      };

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add(commentData);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'comments': FieldValue.increment(1)});

      // Update feed provider
      if (mounted) {
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        feedProvider.updateRepliesCount(widget.postId, 1);
      }

      // Remove optimistic once Firestore stream delivers it
      setState(() {
        _optimisticComments.removeWhere((c) => c.commentId == tempId);
      });
    } catch (e) {
      debugPrint('Error posting comment: $e');
      setState(() {
        _optimisticComments.removeLast();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text('Delete Comment',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Are you sure you want to delete this comment?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(comment.commentId)
          .delete();

      // Count replies to also delete
      int deletedCount = 1;
      final replies = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .where('replyTo', isEqualTo: comment.commentId)
          .get();
      for (final reply in replies.docs) {
        await reply.reference.delete();
        deletedCount++;
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'comments': FieldValue.increment(-deletedCount)});

      if (mounted) {
        final feedProvider = Provider.of<FeedProvider>(context, listen: false);
        feedProvider.updateRepliesCount(widget.postId, -deletedCount);
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
    }
  }

  Future<void> _toggleLike(CommentModel comment) async {
    if (_currentUserId == null) return;
    final ref = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(comment.commentId);

    if (comment.likes.contains(_currentUserId)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([_currentUserId]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([_currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              Iconify(Ph.arrow_left, color: AppTheme.textPrimary, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comments',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _optimisticComments.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                final firestoreComments = (snapshot.data?.docs ?? [])
                    .map((doc) => CommentModel.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                // Merge optimistic comments that aren't in Firestore yet
                final allComments = [...firestoreComments];
                for (final opt in _optimisticComments) {
                  if (!allComments.any((c) =>
                      c.text == opt.text &&
                      c.userId == opt.userId &&
                      c.createdAt.difference(opt.createdAt).inSeconds.abs() <
                          5)) {
                    allComments.add(opt);
                  }
                }

                if (allComments.isEmpty) {
                  return _buildEmptyState();
                }

                // Separate top-level and replies
                final topLevel =
                    allComments.where((c) => c.replyTo == null).toList();
                final replies =
                    allComments.where((c) => c.replyTo != null).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: topLevel.length,
                  itemBuilder: (context, index) {
                    final comment = topLevel[index];
                    final commentReplies = replies
                        .where((r) => r.replyTo == comment.commentId)
                        .toList();
                    return _buildCommentThread(comment, commentReplies);
                  },
                );
              },
            ),
          ),

          // Reply indicator
          if (_replyToUsername != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: AppTheme.primaryBackground,
              child: Row(
                children: [
                  Text(
                    'Replying to @$_replyToUsername',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child:
                        Iconify(Ph.x, color: AppTheme.textLight, size: 16.sp),
                  ),
                ],
              ),
            ),

          // Comment input bar
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(Ph.chat_circle_dots, size: 60.sp, color: AppTheme.border),
          SizedBox(height: 16.h),
          Text(
            'No comments yet',
            style: TextConstants.mediumText.copyWith(
              fontSize: 16.sp,
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
    );
  }

  Widget _buildCommentThread(CommentModel comment, List<CommentModel> replies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentCard(comment, isReply: false),
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 44.w),
            child: Column(
              children: replies
                  .map((r) => _buildCommentCard(r, isReply: true))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentCard(CommentModel comment, {bool isReply = false}) {
    final isMyComment = comment.userId == _currentUserId;
    final isLiked = comment.likes.contains(_currentUserId);
    final timeAgoStr = timeago.format(comment.createdAt);

    return GestureDetector(
      onLongPress: isMyComment ? () => _deleteComment(comment) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 14.r : 18.r,
              backgroundColor: AppTheme.primaryBackground,
              backgroundImage: comment.userAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(
                      comment.userAvatar,
                      cacheManager: CustomCacheManager(),
                    )
                  : null,
              child: comment.userAvatar.isEmpty
                  ? Iconify(Ph.user, size: 16.sp, color: AppTheme.primary)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.username,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (comment.isVerified) ...[
                        SizedBox(width: 4.w),
                        Iconify(Ph.check_circle_fill,
                            size: 14.sp, color: AppTheme.primary),
                      ],
                      SizedBox(width: 6.w),
                      Text(
                        timeAgoStr,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (comment.replyToUsername != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        '@${comment.replyToUsername}',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  Text(
                    comment.text,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleLike(comment),
                        child: Row(
                          children: [
                            Iconify(
                              isLiked ? Ph.heart_fill : Ph.heart,
                              size: 16.sp,
                              color:
                                  isLiked ? AppTheme.error : AppTheme.textLight,
                            ),
                            if (comment.likes.isNotEmpty) ...[
                              SizedBox(width: 4.w),
                              Text(
                                '${comment.likes.length}',
                                style: TextConstants.smallText.copyWith(
                                  fontSize: 12.sp,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      if (!isReply)
                        GestureDetector(
                          onTap: () =>
                              _setReplyTo(comment.commentId, comment.username),
                          child: Text(
                            'Reply',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppTheme.primaryBackground,
                backgroundImage:
                    FirebaseAuth.instance.currentUser?.photoURL != null
                        ? CachedNetworkImageProvider(
                            FirebaseAuth.instance.currentUser!.photoURL!,
                            cacheManager: CustomCacheManager(),
                          )
                        : null,
                child: FirebaseAuth.instance.currentUser?.photoURL == null
                    ? Iconify(Ph.user, size: 16.sp, color: AppTheme.primary)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppTheme.border),
                    color: AppTheme.buttonBorder,
                  ),
                  constraints: BoxConstraints(maxHeight: 100.h),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: _replyToUsername != null
                          ? 'Reply to @$_replyToUsername...'
                          : 'Add a comment...',
                      hintStyle: TextConstants.smallText.copyWith(
                        color: AppTheme.textLight,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
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
                onTap: _isPosting ? null : _postComment,
                child: _isPosting
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : Iconify(
                        Ph.paper_plane_tilt_fill,
                        size: 24.sp,
                        color: _commentController.text.trim().isNotEmpty
                            ? AppTheme.primary
                            : AppTheme.textLight,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
