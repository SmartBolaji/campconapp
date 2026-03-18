import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/random_chat_models.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class RandomChatScreen extends StatefulWidget {
  const RandomChatScreen({super.key});

  @override
  State<RandomChatScreen> createState() => _RandomChatScreenState();
}

class _RandomChatScreenState extends State<RandomChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser == null) return;

      chatProvider.setCurrentUserProfile(
        UserProfile(
          userId: currentUser.uid,
          name: currentUser.name ?? currentUser.username,
          avatarUrl: currentUser.profileImageUrl,
          isOnline: true,
        ),
      );

      await chatProvider.joinRandomChatQueue(currentUserId: currentUser.uid);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(text);
    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showRevealRequestDialog() {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: AppTheme.surface,
          title: Text(
            'Request profile reveal?',
            style: TextConstants.mediumText.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'If accepted, both of you will see each other\'s profile details.',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await chatProvider.sendRevealRequest();
                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Send',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRevealReceivedDialog() {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: AppTheme.surface,
          title: Text(
            'Reveal request',
            style: TextConstants.mediumText.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Your random chat partner wants to reveal profiles.',
            style: TextConstants.smallText.copyWith(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () async {
                await chatProvider.declineReveal();
                if (mounted) Navigator.pop(ctx);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.warning),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Decline',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await chatProvider.acceptReveal();
                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Accept',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.revealRequestReceived) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showRevealReceivedDialog();
          });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () async {
                await chatProvider.resetChat();
                if (mounted) Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  chatProvider.activeRandomChatId == null
                      ? 'Random Shot'
                      : chatProvider.chatPartnerName,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (chatProvider.activeRandomChatId != null)
                  Text(
                    chatProvider.isRevealed ? 'Profile Revealed' : 'Anonymous',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: chatProvider.isRevealed
                          ? AppTheme.success
                          : AppTheme.textLight,
                    ),
                  ),
              ],
            ),
            actions: [
              if (chatProvider.activeRandomChatId != null &&
                  !chatProvider.isRevealed)
                chatProvider.revealRequestSent
                    ? Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              'Pending',
                              style: TextConstants.smallText.copyWith(
                                color: AppTheme.primary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _showRevealRequestDialog,
                        icon: Iconify(
                          Ph.eye,
                          color: AppTheme.primary,
                          size: 20.sp,
                        ),
                      ),
            ],
          ),
          body: chatProvider.activeRandomChatId == null
              ? _buildSearchingState(chatProvider)
              : Column(
                  children: [
                    Expanded(child: _buildMessages(chatProvider)),
                    _buildComposer(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchingState(ChatProvider chatProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 52.w,
              height: 52.h,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              chatProvider.isSearchingMatch
                  ? 'Finding a random match...'
                  : 'Preparing Random Shot...',
              textAlign: TextAlign.center,
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You will be connected as soon as someone joins the queue.',
              textAlign: TextAlign.center,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(ChatProvider chatProvider) {
    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68.w,
              height: 68.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.chat_bubble_outline,
                  color: AppTheme.primary, size: 34.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'Say hi to ${chatProvider.chatPartnerName}',
              style: TextConstants.mediumText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.r),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildBubble(message);
      },
    );
  }

  Widget _buildBubble(RandomChatMessage message) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: message.isSent ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: message.isSent ? AppTheme.white : AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              message.time,
              style: TextConstants.smallText.copyWith(
                fontSize: 10.sp,
                color: message.isSent
                    ? AppTheme.white.withValues(alpha: 0.8)
                    : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(22.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: TextField(
                controller: _messageController,
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 13.sp,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: TextConstants.smallText.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
              child: Icon(Icons.send, color: AppTheme.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }
}
