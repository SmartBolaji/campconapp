import 'package:campcon/services/task_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isTagInputVisible = false; // Track visibility of the tag input system

  void savePost(String userId, String content, List<String> tags) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.collection('posts').add({
      'content': content,
      'author': userRef,
      'addedDate': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'dislikesCount': 0,
      'repliesCount': 0,
      'bookmarksCount': 0,
      'postTags': tags,
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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            IconlyLight.close_square,
            size: 28,
            color: Colors.grey.shade800,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // title: const Text(
        //   'New Post',
        //   style: TextStyle(
        //     color: Colors.black,
        //     fontSize: 22,
        //     fontWeight: FontWeight.bold,
        //     fontFamily: 'Trebuchet',
        //   ),
        // ),
        actions: [
          TextButton(
              onPressed: () {
                _tags.addAll(taskData.tags);
                savePost(taskData.uid, contentController.text, _tags);
                Future.delayed(Duration(seconds: 2), () {
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
                    fontFamily: 'Trebuchet',
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
                              controller: contentController,
                              style: const TextStyle(fontFamily: 'Trebuchet'),
                              maxLines: null,
                              autofocus: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: "What's on your mind?",
                                hintStyle: TextStyle(fontFamily: 'Trebuchet'),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add a tag icon with text at the top of bottom icons
                GestureDetector(
                  onTap: _toggleTagInput, // Toggle visibility when tapped
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          _isTagInputVisible
                              ? Icons.close
                              : Icons.add_circle_outline,
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTagInputVisible ? 'Close' : 'Add a Tag',
                          style: TextStyle(
                            fontFamily: 'Trebuchet',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Conditionally display the tag input section
                if (_isTagInputVisible)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                hintText: 'Enter a tag...',
                                hintStyle:
                                    const TextStyle(fontFamily: 'Trebuchet'),
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
                                fontFamily: 'Trebuchet',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Display tags as chips
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(
                                  fontFamily: 'Trebuchet', fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: Colors.grey.shade300,
                            labelStyle: const TextStyle(
                              fontFamily: 'Trebuchet',
                              color: Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                // Bottom icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.gif, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.poll, color: Colors.grey.shade600),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.location_on, color: Colors.grey.shade600),
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
