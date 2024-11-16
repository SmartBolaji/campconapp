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
  final int bookmarksCount;
  final bool isLiked;
  final bool isBookmarked;
  final Function onLike;
  final Function onBookmark;
  final Function onReply;
  final Function onShare; // Added onShare function
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
    required this.bookmarksCount,
    required this.isLiked,
    required this.isBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.onReply,
    required this.onShare, // Added onShare parameter
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Name, Handle, and Time in a wrapped style
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Image with added border and slightly larger size
                  Container(
                    width: width / 15,
                    height: width / 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(userImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight, // Position the icon
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              0xFFBA9E02), // Background for the small icon
                        ),
                        padding: const EdgeInsets.all(
                            2), // Add some padding around the icon
                        child: const Icon(
                          Icons.add,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Trebuchet',
                      fontSize: width / 24,
                      color: Colors.black,
                    ),
                  ),
                  // const SizedBox(width: 5),
                  // Text(
                  //   '@$userHandle',
                  //   style: TextStyle(
                  //     fontFamily: 'Trebuchet',
                  //     fontSize: width / 27,
                  //     color: Colors.grey.shade600,
                  //   ),
                  // ),
                ],
              ),
              // Icon(Icons.fiber_manual_record,
              //     size: 5, color: Colors.grey.shade500),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: width / 28,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              )
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
              repliesCount == 0
                  ? 'No reply'
                  : repliesCount == 1
                      ? '$repliesCount reply'
                      : '$repliesCount replies',
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontSize: width / 28,
                color: const Color(0xFFBA9E02),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Like button
                  GestureDetector(
                    onTap: () => onLike(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? Color(0xFFBA9E02).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLiked
                              ? Color(0xFFBA9E02).withOpacity(0.8)
                              : Colors.grey.withOpacity(0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? IconlyBold.heart : IconlyLight.heart,
                            color: isLiked
                                ? Color(0xFFBA9E02).withOpacity(0.8)
                                : Colors.grey.withOpacity(0.8),
                            size: width / 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$likesCount',
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: width / 28,
                              color: isLiked
                                  ? Color(0xFFBA9E02).withOpacity(0.8)
                                  : Colors.grey.shade600.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(width: 5),
                  // // Reply button
                  // GestureDetector(
                  //   onTap: () => onReply(),
                  //   child: Container(
                  //     padding:
                  //         const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  //     decoration: BoxDecoration(
                  //       color: Colors.grey.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(20),
                  //       border: Border.all(
                  //         color: Colors.grey,
                  //         width: 1,
                  //       ),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(
                  //           IconlyLight.chat, // Reply icon
                  //           color: Colors.grey,
                  //           size: width / 18,
                  //         ),
                  //         const SizedBox(width: 5),
                  //         Text(
                  //           '$repliesCount',
                  //           style: TextStyle(
                  //             fontFamily: 'Trebuchet',
                  //             fontSize: width / 28,
                  //             color: Colors.grey.shade600,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  // Bookmark button
                  GestureDetector(
                    onTap: () => onBookmark(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? Color(0xFFBA9E02).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isBookmarked
                              ? Color(0xFFBA9E02).withOpacity(0.8)
                              : Colors.grey.withOpacity(0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isBookmarked
                                ? IconlyBold.bookmark
                                : IconlyLight.bookmark,
                            color: isBookmarked
                                ? Color(0xFFBA9E02).withOpacity(0.8)
                                : Colors.grey.withOpacity(0.8),
                            size: width / 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$bookmarksCount',
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: width / 28,
                              color: isBookmarked
                                  ? Color(0xFFBA9E02).withOpacity(0.8)
                                  : Colors.grey.shade600.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Share button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onShare(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            IconlyLight.send, // Share icon
                            color: Colors.grey.shade600.withOpacity(0.8),
                            size: width / 18,
                          ),
                          // const SizedBox(width: 5),
                          // Text(
                          //   'Share',
                          //   style: TextStyle(
                          //     fontFamily: 'Trebuchet',
                          //     fontSize: width / 28,
                          //     color: Colors.grey.shade600,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
