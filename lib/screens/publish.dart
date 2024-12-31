import 'package:campcon/services/task_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PostPageState();
}

class _PostPageState extends State<PublishPage> {
  // assign variable
  DateTime now = DateTime.now();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];
  final List<String> _imgs = [];
  bool _isTagInputVisible = false; // Track visibility of the tag input system

  void savePost(String userId, String content, List<String> tags,
      List<String> imgs) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    String pid = 'ps${now.millisecondsSinceEpoch}';

    await FirebaseFirestore.instance.collection('posts').doc(pid).set({
      'postId': pid,
      'content': content,
      'author': userRef,
      'addedDate': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'dislikesCount': 0,
      'repliesCount': 0,
      'bookmarksCount': 0,
      'postTags': tags,
      'media': false,
      'imgs': imgs,
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear(); // Clear the input field
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _toggleTagInput() {
    setState(() {
      _isTagInputVisible =
          !_isTagInputVisible; // Toggle visibility of tag input
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskData = Provider.of<TaskData>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.grey.shade100,
        elevation: 1,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Transform.scale(
            scale: 0.80,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                  border: Border.all(width: 1, color: Colors.grey.shade900)),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade800,
                size: 25,
              ),
            ),
          ),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lato',
            // fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                _tags.addAll(taskData.tags);
                savePost(taskData.uid, contentController.text, _tags, _imgs);
                Future.delayed(const Duration(seconds: 2), () {
                  taskData.loadSnap(newTags: taskData.tags, limit: 20);
                });
                Navigator.pop(context);
                // print("Post Tags: $_tags"); // For debugging
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 8, left: 15, right: 15),
                decoration: BoxDecoration(
                    color: const Color(0xFFBA9E02),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Post',
                  style: TextStyle(
                    color: Colors.grey.shade50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                    // fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // The main content area that scrolls
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(
                      //     height:
                      //         40), // Add space to prevent text overlap with CircleAvatar
                      Row(
                        children: [
                          const SizedBox(
                              width: 50), // Add space for CircleAvatar
                          Expanded(
                            child: TextField(
                              buildCounter: (_,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) {
                                return null; // Hides the counter
                              },
                              maxLength: 300,
                              controller: contentController,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: null,
                              autofocus: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: "What's on your mind?",
                                hintStyle: TextStyle(
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // CircleAvatar fixed at the top
                Positioned(
                  top: 20, // Position it at the top with some padding
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade600,
                    radius: 20,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // height: _isBottomSectionVisible ? 250 : 0, // Dynamic height
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // tag
                      GestureDetector(
                        onTap: _toggleTagInput, // Toggle visibility when tapped
                        child: Row(
                          children: [
                            Icon(
                              _isTagInputVisible
                                  ? Icons.close
                                  : Icons.label_outline,
                              color: Colors.grey.shade800,
                              size: 23,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isTagInputVisible ? 'Close' : 'Add Tag',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                // fontWeight: FontWeight.w600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // indicator and more thread
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  value: contentController.text.length /
                                      300, // Progress based on the current text length
                                  backgroundColor: Colors.grey.shade300,
                                  color: contentController.text.length > 200
                                      ? const Color(0xFFBA9E02)
                                      : const Color(0xFFBA9E02)
                                          .withOpacity(0.4), // Progress color
                                  strokeWidth: 3,
                                ),
                              ),
                              Text(
                                '${contentController.text.length}', // Current character count
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  // fontWeight: FontWeight.w600,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.grey.shade800,
                            size: 23,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // Conditionally display the tag input section
                if (_isTagInputVisible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
                                controller: _tagController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  hintText: 'Enter a tag...',
                                  hintStyle: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addTag,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                backgroundColor: Colors.grey.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  // fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Display tags as chips
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: Colors.grey.shade300,
                              labelStyle: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                // const SizedBox(height: 10),

                Container(
                    padding: const EdgeInsets.only(
                      // left: 20,
                      // right: 20,
                      bottom: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    )),
                // Bottom icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon:
                          Icon(FeatherIcons.image, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.gif, color: Colors.grey.shade600),
                    //   onPressed: () {},
                    // ),
                    IconButton(
                      icon: Icon(Icons.poll_outlined,
                          color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.location_on_outlined,
                          color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(FeatherIcons.settings,
                          color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
