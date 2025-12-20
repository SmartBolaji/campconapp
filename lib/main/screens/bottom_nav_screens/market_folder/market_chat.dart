import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId; // Use ID instead of just name
  final String recipientName;
  final String? productName;
  final bool isOrderChat;

  const ChatScreen({
    Key? key,
    required this.conversationId,
    required this.recipientName,
    this.productName,
    this.isOrderChat = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the provider when the screen is built
    // This is typically done higher up in the widget tree, but for demonstration, we use Read here
    // In a real app, you would use a ChangeNotifierProvider.value or a proper setup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketChatProvider>(context, listen: false)
          .loadConversation(conversationId);
    });

    return Consumer<MarketChatProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipientName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Online', // This should also come from a dynamic status field
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                // More options
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (isOrderChat && productName != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                color: Colors.yellow.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20.sp, color: Constants.primaryDark),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Chat about: $productName',
                        style: TextStyle(
                            fontSize: 14.sp, color: Constants.primaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: provider.messages.isEmpty
                  ? Center(
                      child: Text('Start a conversation!',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16.sp)))
                  : ListView.builder(
                      padding: EdgeInsets.all(10.w),
                      reverse: true, // Show newest messages at the bottom
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        final message =
                            provider.messages.reversed.toList()[index];
                        final isSender =
                            message.senderId == provider.currentUserId;

                        // Formatting time:
                        String formattedTime =
                            '${message.timestamp.hour % 12}:${message.timestamp.minute.toString().padLeft(2, '0')} ${message.timestamp.hour >= 12 ? 'PM' : 'AM'}';

                        return _buildMessageBubble(
                          message.text,
                          formattedTime,
                          isSender: isSender,
                        );
                      },
                    ),
            ),
            _buildChatInput(context, provider),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(String text, String time,
      {required bool isSender}) {
    final bubbleColor = isSender ? Constants.primaryDark : Colors.grey[200];
    final textColor = isSender ? Colors.white : Colors.black;
    final alignment =
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final margin = isSender
        ? EdgeInsets.only(top: 5.h, bottom: 5.h, left: 80.w)
        : EdgeInsets.only(top: 5.h, bottom: 5.h, right: 80.w);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.r),
                topRight: Radius.circular(15.r),
                bottomLeft:
                    isSender ? Radius.circular(15.r) : Radius.circular(0),
                bottomRight:
                    isSender ? Radius.circular(0) : Radius.circular(15.r),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 14.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 2.h, right: isSender ? 5.w : 0, left: isSender ? 0 : 5.w),
            child: Text(
              time,
              style: TextStyle(color: Colors.grey, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(BuildContext context, MarketChatProvider provider) {
    final messageController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Send a message',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              provider.sendMessage(messageController.text);
              messageController.clear();
            },
            child: CircleAvatar(
              backgroundColor: Constants.primaryDark,
              radius: 20.r,
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
