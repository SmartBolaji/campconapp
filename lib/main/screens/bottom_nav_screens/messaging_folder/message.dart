import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/message_model.dart';
// import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_alert.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_bubble.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_manager.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_options.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_upload.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/send_notify.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:campcon/main/widgets/navigate_profile.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/message_provider.dart';
import 'package:campcon/main/widgets/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Message extends StatefulWidget {
  final String uid;
  final String profileImg;
  final String name;
  final String fcmToken;
  final String? defaultMessage;

  const Message({
    required this.uid,
    required this.profileImg,
    required this.name,
    required this.fcmToken,
    this.defaultMessage,
    Key? key,
  }) : super(key: key);

  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<Message> {
  Map<String, dynamic>? userData;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // To track if there's text in the input field
  bool _hasText = false;
  // To manage chat messages
  late ChatManager _chatManager;
  // To track loading state for pagination
  ChatMessage? _replyToMessage;
  // To manage loading more messages
  bool _isLoadingMore = false;
  // To highlight a specific message
  String? _highlightedMessageId;

  // Store reference to message provider to use in dispose
  MessageProvider? _messageProvider;

  // Escrow alert - commented out for now
  // bool _showBuyersAlert = false;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final chatId = getChatId(widget.uid);

    // Store reference to message provider for later cleanup
    _messageProvider = Provider.of<MessageProvider>(context, listen: false);

    // Initialize message provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageProvider?.initializeChat(
        currentUserId: currentUserId,
        otherUserId: widget.uid,
      );
    });

    // Escrow - commented out for now
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<EscrowProvider>(context, listen: false).fetchEscrows(chatId);
    //   _checkBuyersAlert();
    // });

    // Initialize chat manager
    _chatManager = ChatManager(
      chatId: chatId,
      currentUserId: currentUserId,
    );

    _loadUserData();
    _focusNode.addListener(_onFocusChange);
    messageController.addListener(_onTextChanged);

    // Set default message if provided
    if (widget.defaultMessage?.isNotEmpty == true) {
      messageController.text = widget.defaultMessage!;
      _hasText = true;
    }

    // Set up scroll controller
    _scrollController.addListener(_onScroll);

    // Mark messages as read
    _chatManager.markAllAsRead();
  }

  // Escrow alert - commented out for now
  // Future<void> _checkBuyersAlert() async {
  //   final shouldShow = await EscrowAlertSheet.shouldShow();
  //   if (shouldShow && mounted) {
  //     setState(() => _showBuyersAlert = true);
  //   }
  // }

  @override
  void dispose() {
    _chatManager.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    messageController.removeListener(_onTextChanged);
    messageController.dispose();

    // Clean up message provider using stored reference
    _messageProvider?.disposeChat();

    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _scrollToBottom();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    setState(() {
      _isLoadingMore = true;
    });

    await _chatManager.loadMoreMessages();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> markMessagesAsRead() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.uid ?? '';
      String chatId = getChatId(widget.uid);

      // First check if the chat document exists
      DocumentSnapshot chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      // Only update if the document exists
      if (chatDoc.exists) {
        // Update chat document to remove current user from unreadBy array
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .update({
          'unreadBy': FieldValue.arrayRemove([currentUserId])
        });

        // Mark all messages as read
        QuerySnapshot unreadMessages = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

        // Use batch write for better performance
        if (unreadMessages.docs.isNotEmpty) {
          WriteBatch batch = FirebaseFirestore.instance.batch();
          for (var doc in unreadMessages.docs) {
            batch.update(doc.reference, {'isRead': true});
          }
          await batch.commit();
        }
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _loadUserData() async {
    Map<String, dynamic>? data = await getUserData(widget.uid);
    setState(() {
      userData = data;
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<void> sendMessage() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (messageController.text.isEmpty || currentUser == null) return;

      final String message = messageController.text;

      // Clear input field immediately for better UX
      setState(() {
        messageController.clear();
        _hasText = false;
      });

      _scrollToBottom();

      // Send message via chat manager
      await _chatManager.sendMessage(
        text: message,
        receiverId: widget.uid,
        replyTo: _replyToMessage,
      );
      setState(() => _replyToMessage = null);

      // Send FCM notification
      if (widget.fcmToken.isNotEmpty) {
        await sendPushNotification(
          token: widget.fcmToken,
          name: currentUser.name ?? 'Someone',
          message: message,
          profileImg: currentUser.profileImage ?? '',
          uid: currentUser.uid,
          type: 'message',
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        showFloatingSnackBar(
          context,
          'Failed to send message. Please try again.',
          backgroundColor: AppColors.error,
        );
      }
    }
  }

  String getChatId(String receiverId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String currentUserId = authProvider.currentUser?.uid ?? '';
    return (currentUserId.hashCode <= receiverId.hashCode)
        ? "$currentUserId-$receiverId"
        : "$receiverId-$currentUserId";
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) {
      return 'Just now';
    }

    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _onTextChanged() {
    setState(() {
      _hasText = messageController.text.isNotEmpty;
    });
  }

  void _handleImageSelection() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    await MessageUploadService.pickAndUploadImage(
      context: context,
      currentUserId: currentUser.uid,
      receiverId: widget.uid,
      chatId: getChatId(widget.uid),
      scrollToBottom: _scrollToBottom,
      messageText: messageController.text.trim(),
      onClearMessage: () {
        setState(() {
          messageController.clear();
          _hasText = false;
        });
      },
      fcmToken: widget.fcmToken,
      senderName: currentUser.name ?? 'Someone',
      senderProfileImg: currentUser.profileImage,
    );
  }

  void _handleReply(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _navigateToUserProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (userData != null) {
      navigateToProfile(context, currentUserId, userData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser?.uid ?? '';

    // Escrow - commented out for now
    // final escrowProvider = Provider.of<EscrowProvider>(context);
    // final hasActiveEscrow = escrowProvider.escrows.any((escrow) =>
    //     escrow['chatId'] == chatId &&
    //     (escrow['status'] == 'in-escrow' || escrow['status'] == 'approved'));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          surfaceTintColor: AppTheme.surface,
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Iconify(
                Ph.arrow_left,
                size: 24.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          titleSpacing: 5,
          title: Row(
            children: [
              GestureDetector(
                onTap: _navigateToUserProfile,
                // Profile image - matching custom_top_bar.dart style
                child: Container(
                  width: 40,
                  height: 40,
                  padding: widget.profileImg.isEmpty
                      ? const EdgeInsets.all(8)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.profileImg.isEmpty
                        ? AppTheme.primaryBackground
                        : AppTheme.border,
                    image: widget.profileImg.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              widget.profileImg,
                              cacheManager: CustomCacheManager(),
                              cacheKey: '${widget.profileImg}_profile',
                            ),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: widget.profileImg.isEmpty
                      ? Iconify(
                          Ph.user,
                          color: AppTheme.primary,
                          size: 20,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _navigateToUserProfile,
                    child: Row(
                      children: [
                        Text(
                          widget.name,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RoleBadge(
                          role: userData?['role'] ?? '',
                          size: 14.0,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${userData?['username']?.toString().toLowerCase() ?? ''}',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Escrow button - commented out for now
            // Stack(
            //   children: [
            //     IconButton(
            //       onPressed: () {
            //         // Navigate to escrow screen
            //       },
            //       icon: Icon(
            //         Icons.assignment_turned_in_outlined,
            //         color: AppTheme.textPrimary,
            //         size: 24,
            //       ),
            //     ),
            //     if (hasActiveEscrow)
            //       Positioned(
            //         right: 10,
            //         top: 10,
            //         child: Container(
            //           width: 10,
            //           height: 10,
            //           decoration: BoxDecoration(
            //             color: AppColors.error,
            //             shape: BoxShape.circle,
            //             border: Border.all(color: AppTheme.surface, width: 1.5),
            //           ),
            //         ),
            //       ),
            //   ],
            // ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                MessageOptions.showOptions(
                  context,
                  currentUserId: currentUserId,
                  otherUserId: widget.uid,
                  otherUserName: widget.name,
                  onBlock: () {
                    Navigator.pop(context);
                  },
                );
              },
              icon: Icon(
                Icons.more_horiz,
                color: AppTheme.textPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages List
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _chatManager.messagesStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        );
                      }

                      var messages = snapshot.data!;

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FeatherIcons.messageCircle,
                                size: 40,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No messages yet",
                                style: TextConstants.boldText.copyWith(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Send a message to start a conversation",
                                style: TextConstants.smallText.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoadingMore && index == messages.length) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: CircularProgressIndicator(
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          }

                          var message = messages[index];
                          bool isMe = message.senderId == currentUserId;

                          final messageDate =
                              DateTime.fromMillisecondsSinceEpoch(
                                  message.timestamp);

                          bool showTimestamp = index == messages.length - 1;
                          if (index < messages.length - 1) {
                            final nextMessageDate =
                                DateTime.fromMillisecondsSinceEpoch(
                                    messages[index + 1].timestamp);
                            showTimestamp = !DateUtils.isSameDay(
                                messageDate, nextMessageDate);
                          }

                          bool showTail = index == 0;
                          if (index > 0) {
                            showTail = messages[index - 1].senderId !=
                                message.senderId;
                          }

                          bool showTime = index == 0;
                          if (index > 0) {
                            final prevMessageDate =
                                DateTime.fromMillisecondsSinceEpoch(
                                    messages[index - 1].timestamp);
                            showTime = messages[index - 1].senderId !=
                                    message.senderId ||
                                !_isSameMinute(messageDate, prevMessageDate);
                          }

                          return Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (showTimestamp)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    _formatMessageDate(messageDate),
                                    style: TextConstants.smallText.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              MessageBubble(
                                chatMessage: message,
                                message: message.text,
                                isMe: isMe,
                                timestamp: Timestamp.fromMillisecondsSinceEpoch(
                                    message.timestamp),
                                isRead: message.isRead,
                                showTail: showTail,
                                showTime: showTime,
                                imageUrl: message.imageUrl,
                                messageId: message.messageId,
                                chatId: getChatId(widget.uid),
                                deleted: message.deleted,
                                onReply: _handleReply,
                                onReplyTap: (messageId) {
                                  final idx = messages.indexWhere(
                                      (m) => m.messageId == messageId);
                                  if (idx != -1) {
                                    setState(() =>
                                        _highlightedMessageId = messageId);
                                    const itemHeight = 80.0;
                                    _scrollController.animateTo(
                                      idx * itemHeight,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      if (mounted) {
                                        setState(
                                            () => _highlightedMessageId = null);
                                      }
                                    });
                                  }
                                },
                                otherUserName: widget.name,
                                currentUserId: currentUserId,
                                highlighted:
                                    message.messageId == _highlightedMessageId,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              if (_replyToMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Replying to ${_replyToMessage!.senderId == currentUserId ? "yourself" : widget.name}',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _replyToMessage!.text,
                              style: TextConstants.smallText.copyWith(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 18, color: AppTheme.textLight),
                        onPressed: () => setState(() => _replyToMessage = null),
                      ),
                    ],
                  ),
                ),
              // Input Field
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.border.withValues(alpha: 0.5),
                      offset: const Offset(0, -1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _handleImageSelection,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    FeatherIcons.image,
                                    color:
                                        AppTheme.primary.withValues(alpha: 0.7),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  focusNode: _focusNode,
                                  minLines: 1,
                                  maxLines: 5,
                                  style: TextConstants.smallText.copyWith(
                                    fontSize: 16,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "Message...",
                                    hintStyle: TextConstants.smallText.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (_hasText)
                                GestureDetector(
                                  onTap: sendMessage,
                                  child: Icon(
                                    Icons.send,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Escrow floating alert - commented out for now
          // if (_showBuyersAlert)
          //   Positioned(
          //     top: 20,
          //     left: 0,
          //     right: 0,
          //     child: _buildEscrowAlert(),
          //   ),
        ],
      ),
    );
  }

  String _formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();

    if (DateUtils.isSameDay(dateTime, now)) {
      return 'Today';
    } else if (DateUtils.isSameDay(
        dateTime, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(dateTime);
    }
  }

  bool _isSameMinute(DateTime d1, DateTime d2) {
    return d1.year == d2.year &&
        d1.month == d2.month &&
        d1.day == d2.day &&
        d1.hour == d2.hour &&
        d1.minute == d2.minute;
  }
}
