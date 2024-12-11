import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class PostWidget extends StatelessWidget {
  final String userHandle;
  final String userName;
  final String userImageUrl;
  final String content;
  final int likesCount;
  final int dislikesCount;
  final int repliesCount;
  final int bookmarksCount;
  final bool isLiked;
  final bool isDisliked;
  final bool isBookmarked;
  final Function onLike;
  final Function onDislike;
  final Function onBookmark;
  final Function onReply;
  final Function onShare;
  final Function onMore;
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
    required this.dislikesCount,
    required this.repliesCount,
    required this.bookmarksCount,
    required this.isLiked,
    required this.isDisliked,
    required this.isBookmarked,
    required this.onLike,
    required this.onDislike,
    required this.onBookmark,
    required this.onReply,
    required this.onShare,
    required this.onMore,
    required this.height,
    required this.width,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLongContent = content.length > 100;
    String displayContent = isLongContent ? content.substring(0, 100) : content;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: width / 24, vertical: height / 60),
          // decoration: BoxDecoration(
          //   border: Border(
          //     bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // User Image with added border and slightly larger size
                      Container(
                        width: width / 12,
                        height: width / 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(userImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBA9E02),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.add,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontWeight: FontWeight.bold,
                              fontSize: width / 25,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '@$userHandle',
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: width / 28,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: width / 28,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Content
              GestureDetector(
                onTap: () {},
                child: RichText(
                  text: TextSpan(
                    text: displayContent,
                    style: GoogleFonts.poppins(
                      fontSize: width / 26,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    children: isLongContent
                        ? [
                            const TextSpan(
                              text: ' See more',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Buttons row with More button
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: width / 24, vertical: height / 60),
          decoration: BoxDecoration(
            // border: Border(
            //   bottom: BorderSide(
            //       color: isLiked || isDisliked
            //           ? Colors.grey.withOpacity(0.5)
            //           : Colors.grey.shade300,
            //       width: 1),
            // ),
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Like and Dislike
                  Row(
                    children: [
                      _buildActionIcon(
                        icon: FeatherIcons.thumbsUp,
                        count: likesCount,
                        isActive: isLiked,
                        onTap: onLike,
                      ),
                      const SizedBox(width: 10),
                      _buildActionIcon(
                        icon: FeatherIcons.thumbsDown,
                        count: dislikesCount,
                        isActive: isDisliked,
                        onTap: onDislike,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Reply
                  _buildActionIcon(
                    icon: FeatherIcons.messageCircle,
                    count: repliesCount,
                    isActive: false,
                    onTap: onReply,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  // Bookmark
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.bookmark,
                      color: Colors.grey.shade500,
                      size: width / 18,
                    ),
                    onTap: onBookmark(),
                  ),
                  const SizedBox(width: 10),
                  // Share
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.share,
                      color: Colors.grey.shade500,
                      size: width / 18,
                    ),
                    onTap: () => onShare(),
                  ),
                  const SizedBox(width: 10),
                  // More Button
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.moreHorizontal,
                      color: Colors.grey.shade500,
                      size: width / 18,
                    ),
                    onTap: () => onMore(),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required int count,
    required bool isActive,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Color(0xFFBA9E02) : Colors.grey.shade500,
            size: width / 18,
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Trebuchet',
              fontSize: width / 28,
              color: isActive ? Color(0xFFBA9E02) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
