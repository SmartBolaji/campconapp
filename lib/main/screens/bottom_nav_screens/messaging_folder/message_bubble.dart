import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/message_model.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_image_view.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_manager.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final String message;
  final bool isMe;
  final Timestamp timestamp;
  final bool isRead;
  final bool showTail;
  final bool showTime;
  final String? imageUrl;
  final String messageId;
  final String chatId;
  final String? uploadStatus;
  final int? uploadProgress;
  final bool deleted;
  final void Function(ChatMessage)? onReply;
  final void Function(String messageId)? onReplyTap;
  final String otherUserName;
  final String currentUserId;
  final bool highlighted;

  const MessageBubble({
    Key? key,
    required this.chatMessage,
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    required this.showTail,
    required this.showTime,
    this.imageUrl,
    required this.messageId,
    required this.chatId,
    this.uploadStatus,
    this.uploadProgress,
    this.deleted = false,
    this.onReply,
    this.onReplyTap,
    required this.otherUserName,
    required this.currentUserId,
    this.highlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If message is deleted, show a different UI
    if (deleted) {
      return Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
          bottom: showTime ? 16 : 5,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe
                      ? 16
                      : showTail
                          ? 0
                          : 16),
                  bottomRight: Radius.circular(isMe
                      ? showTail
                          ? 0
                          : 16
                      : 16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.not_interested,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (showTime) _buildTimestamp(context),
          ],
        ),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
          bottom: showTime ? 16 : 5,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              onTap: uploadStatus == 'complete' || uploadStatus == null
                  ? () => _openFullScreenImage(context)
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      placeholder: (context, url) => Container(
                        height: 200,
                        width: 200,
                        color: AppTheme.border,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        width: 200,
                        color: AppTheme.border,
                        child: const Icon(Icons.error),
                      ),
                      fit: BoxFit.cover,
                      width: 200,
                    ),
                  ),
                  if (uploadStatus == 'uploading')
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: CircularProgressIndicator(
                                  value: uploadProgress != null
                                      ? uploadProgress! / 100
                                      : null,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                              if (uploadProgress != null)
                                Text(
                                  '$uploadProgress%',
                                  style: TextConstants.smallText.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Uploading...',
                            style: TextConstants.smallText.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (showTime) _buildTimestamp(context),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
        bottom: showTime ? 16 : 5,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Reply preview block
          if (chatMessage.replyTo != null &&
              chatMessage.replyTo!['text'] != null)
            GestureDetector(
              onTap: () {
                if (onReplyTap != null &&
                    chatMessage.replyTo!['messageId'] != null) {
                  onReplyTap!(chatMessage.replyTo!['messageId']);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: AppTheme.primary,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatMessage.replyTo!['senderId'] == currentUserId
                          ? 'You'
                          : otherUserName,
                      style: TextConstants.smallText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chatMessage.replyTo!['text'] ?? '',
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
            ),
          // Main message bubble
          GestureDetector(
            onLongPress: () => _showMessageOptions(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: highlighted
                  ? BoxDecoration(
                      color: AppTheme.primaryBackground,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: _getBorderRadius(),
                    )
                  : BoxDecoration(
                      color: isMe ? AppTheme.primary : AppTheme.surface,
                      borderRadius: _getBorderRadius(),
                      border: isMe ? null : Border.all(color: AppTheme.border),
                    ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                message,
                style: TextConstants.smallText.copyWith(
                  color: highlighted
                      ? AppTheme.textPrimary
                      : (isMe ? Colors.white : AppTheme.textPrimary),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (showTime) _buildTimestamp(context),
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe
          ? 16
          : showTail
              ? 0
              : 16),
      bottomRight: Radius.circular(isMe
          ? showTail
              ? 0
              : 16
          : 16),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(timestamp),
            style: TextConstants.smallText.copyWith(
              fontSize: 11,
              color: AppTheme.textLight,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: isRead ? AppTheme.primary : AppTheme.textLight,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageImageView(
          imageUrl: imageUrl!,
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    final isMine = isMe;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding:
            const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Message options',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (message.isNotEmpty || imageUrl != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null && imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                          ),
                        ),
                      if (imageUrl != null &&
                          imageUrl!.isNotEmpty &&
                          message.isNotEmpty)
                        const SizedBox(height: 12),
                      if (message.isNotEmpty)
                        Text(
                          message,
                          style: TextConstants.smallText.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(children: [
                  _buildOptionTile(
                    context,
                    icon: Icons.reply,
                    title: 'Reply',
                    onTap: () => onReply?.call(chatMessage),
                  ),
                  Divider(height: 1, color: AppTheme.border),
                  _buildOptionTile(
                    context,
                    icon: Icons.copy_rounded,
                    title: 'Copy',
                    onTap: () => _copyMessage(context),
                  ),
                  if (isMine) ...[
                    Divider(height: 1, color: AppTheme.border),
                    if (message.isNotEmpty)
                      Column(
                        children: [
                          _buildOptionTile(
                            context,
                            icon: Icons.edit_rounded,
                            title: 'Edit',
                            onTap: () => _editMessage(context),
                          ),
                          Divider(height: 1, color: AppTheme.border),
                        ],
                      ),
                    _buildOptionTile(
                      context,
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete',
                      isDestructive: true,
                      onTap: () => _deleteMessage(context),
                    ),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextConstants.mediumText.copyWith(
                fontSize: 16,
                color: isDestructive ? AppColors.error : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    showFloatingSnackBar(
      context,
      'Message copied to clipboard',
    );
  }

  void _editMessage(BuildContext context) {
    final chatManager = ChatManager(
      chatId: chatId,
      currentUserId: '',
    );

    TextEditingController editController = TextEditingController(text: message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit Message',
          style: TextConstants.mediumText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: 'Edit your message',
            hintStyle: TextConstants.smallText.copyWith(
              color: AppTheme.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextConstants.smallText.copyWith(fontSize: 15),
          autofocus: true,
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                chatManager.editMessage(messageId, updatedText);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
            ),
            child: Text(
              'Save',
              style: TextConstants.smallText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(BuildContext context) {
    final chatManager = ChatManager(
      chatId: chatId,
      currentUserId: '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Message',
          style: TextConstants.mediumText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This message will be marked as deleted. Everyone in this chat will be able to see that a message was deleted.',
          style: TextConstants.smallText.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              chatManager.deleteMessage(messageId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(
              'Delete',
              style: TextConstants.smallText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
