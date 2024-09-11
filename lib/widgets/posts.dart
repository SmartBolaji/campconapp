import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class PostWidget extends StatelessWidget {
  final String userHandle;
  final String userName;
  final String userImageUrl;
  final String content;
  final int likesCount;
  final int repliesCount;
  final int bookmarksCount; // Added bookmark count
  final bool isLiked;
  final bool isBookmarked;
  final Function onLike;
  final Function onBookmark;
  final Function onReply;
  final double height;
  final double width;
  final String time;

  const PostWidget({
    Key? key,
    required this.userHandle,
    required this.userName,
    required this.userImageUrl,
    required this.content,
    required this.likesCount,
    required this.repliesCount,
    required this.bookmarksCount, // Added bookmark count
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.onReply,
    required this.height,
    required this.width,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determines if the content exceeds the limit and needs a "See more" link
    bool isLongContent = content.length > 100;
    String displayContent = isLongContent ? content.substring(0, 100) : content;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: width / 15, vertical: height / 60),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Image with added border and slightly larger size
          Container(
            width: width / 8,
            height: width / 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // border: Border.all(color: Colors.grey.shade400, width: 2),
              image: DecorationImage(
                image: AssetImage(userImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Main content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Name, Handle, and Time in a wrapped style
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8, // Spacing between elements
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Trebuchet',
                        fontSize: width / 24,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '@$userHandle',
                      style: TextStyle(
                        fontFamily: 'Trebuchet',
                        fontSize: width / 27,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Icon(Icons.fiber_manual_record,
                        size: 5, color: Colors.grey.shade500),
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Trebuchet',
                        fontSize: width / 28,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Post Content with "See more" option using GestureDetector
                GestureDetector(
                  onTap: () {
                    // Action for expanding content
                  },
                  child: RichText(
                    text: TextSpan(
                      text: displayContent,
                      style: GoogleFonts.poppins(
                        fontSize: width / 28,
                        color: Colors.black87,
                        height: 1.4, // Line height for readability
                      ),
                      children: isLongContent
                          ? [
                              const TextSpan(
                                text: ' See more',
                                style: TextStyle(
                                  color: Color(0xFFBA9E02),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Displaying replies in a conversational style above the buttons
                GestureDetector(
                  onTap: () => onReply(),
                  child: Text(
                    repliesCount == 1 ? '1 reply' : '$repliesCount replies',
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: width / 28,
                      color: const Color(0xFFBA9E02),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Like and Bookmark Buttons in styled containers
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align to the start
                  children: [
                    GestureDetector(
                      onTap: () => onLike(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isLiked
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                          border: Border.all(
                            color: isLiked ? Colors.red : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? IconlyBold.heart : IconlyLight.heart,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: width / 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$likesCount',
                              style: TextStyle(
                                fontFamily: 'Trebuchet',
                                fontSize: width / 28,
                                color:
                                    isLiked ? Colors.red : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => onBookmark(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isBookmarked
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                          border: Border.all(
                            color: isBookmarked ? Colors.blue : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isBookmarked
                                  ? IconlyBold.bookmark
                                  : IconlyLight.bookmark,
                              color: isBookmarked ? Colors.blue : Colors.grey,
                              size: width / 24,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$bookmarksCount', // Displaying number of bookmarks
                              style: TextStyle(
                                fontFamily: 'Trebuchet',
                                fontSize: width / 28,
                                color: isBookmarked
                                    ? Colors.blue
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
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
    );
  }
}
