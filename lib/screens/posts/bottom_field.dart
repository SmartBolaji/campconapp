import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> emojis = ['😊', '😂', '❤️', '😎', '😍', '😢'];

  void _addEmojiToTextField(String emoji) {
    setState(() {
      _controller.text = _controller.text + emoji;
    });
  }

  void _sendMessage() {
    // You can implement message sending logic here
    print("Message Sent: ${_controller.text}");
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border(
              top: BorderSide(
            width: 1,
            color: Colors.grey.shade300,
          ))
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(16),
          //   topRight: Radius.circular(16),
          // ),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji Group (Top)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _addEmojiToTextField(emojis[index]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      emojis[index],
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10), // Spacing between emojis and text field

          // Row for user image, text field, and send icon
          Row(
            children: [
              // User Image (Left)
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                    'assets/images/social.jpeg'), // Replace with actual image URL
              ),
              const SizedBox(width: 12), // Space between image and text field

              // Text Field (Center)
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      fontFamily: 'Lato',
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(
                  width: 12), // Space between text field and send button

              // Send Icon (Right)
              GestureDetector(
                onTap: _sendMessage,
                child: Icon(
                  Icons.send,
                  color: const Color(0xFFBA9E02),
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
