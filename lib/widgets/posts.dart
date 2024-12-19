import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostWidget extends StatefulWidget {
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
  final List<String> imageUrls; // List of image URLs for carousel

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
    required this.imageUrls, // Pass the image URLs here
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const int maxVisibleIndicators = 5;

    // Determine the start and end of the visible range
    int startIndex = (_currentIndex - maxVisibleIndicators ~/ 2)
        .clamp(0, widget.imageUrls.length - maxVisibleIndicators);
    int endIndex =
        (startIndex + maxVisibleIndicators).clamp(0, widget.imageUrls.length);

    // Generate indicators
    List<Widget> indicators = [];
    if (startIndex > 0) {
      indicators.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.6), // Mini dot
        ),
      ));
    }
    for (int i = startIndex; i < endIndex; i++) {
      indicators.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == i ? Color(0xFFBA9E02) : Colors.grey,
        ),
      ));
    }
    if (endIndex < widget.imageUrls.length) {
      indicators.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.6), // Mini dot
        ),
      ));
    }

    bool isLongContent = widget.content.length > 100;
    String displayContent =
        isLongContent ? widget.content.substring(0, 100) : widget.content;

    return Column(
      children: [
        // Content
        Container(
          padding: EdgeInsets.only(
              top: widget.height / 64,
              bottom: 5,
              left: widget.width / 24,
              right: widget.width / 24),
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
                      Container(
                        width: widget.width / 12,
                        height: widget.width / 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(widget.userImageUrl),
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
                            widget.userName,
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontWeight: FontWeight.bold,
                              fontSize: widget.width / 25,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '@${widget.userHandle}',
                            style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: widget.width / 28,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: widget.width / 28,
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
                      fontSize: widget.width / 25,
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
        Stack(
          children: [
            // PageView for images
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: widget.imageUrls.length,
                controller: PageController(viewportFraction: 1),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    width: widget.width,
                  );
                },
              ),
            ),
            // Indicator positioned at the bottom center
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: indicators,
              ),
            ),
          ],
        ),
        // Buttons row with More button
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: widget.width / 24, vertical: widget.height / 60),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      _buildActionIcon(
                        icon: FeatherIcons.arrowUpCircle,
                        count: widget.likesCount,
                        isActive: widget.isLiked,
                        onTap: widget.onLike,
                      ),
                      const SizedBox(width: 10),
                      _buildActionIcon(
                        icon: FeatherIcons.arrowDownCircle,
                        count: widget.dislikesCount,
                        isActive: widget.isDisliked,
                        onTap: widget.onDislike,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  _buildActionIcon(
                    icon: FeatherIcons.messageCircle,
                    count: widget.repliesCount,
                    isActive: false,
                    onTap: widget.onReply,
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.bookmark,
                      color: Colors.grey.shade500,
                      size: widget.width / 18,
                    ),
                    onTap: () => widget.onBookmark(),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.share,
                      color: Colors.grey.shade500,
                      size: widget.width / 18,
                    ),
                    onTap: () => widget.onShare(),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    child: Icon(
                      FeatherIcons.moreHorizontal,
                      color: Colors.grey.shade500,
                      size: widget.width / 18,
                    ),
                    onTap: () => widget.onMore(),
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
            size: widget.width / 18,
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Trebuchet',
              fontSize: widget.width / 28,
              color: isActive ? Color(0xFFBA9E02) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
