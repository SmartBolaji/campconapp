import 'package:campcon/screens/posts/bottom_field.dart';
import 'package:campcon/screens/posts/bubble_view.dart';
import 'package:campcon/widgets/twoline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class PostViewWidget extends StatelessWidget {
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
  final bool isMedia;
  final List<String> imageUrls;
  final Function onLike;
  final Function onDislike;
  final Function onBookmark;
  final Function onReply;
  final Function onShare;
  final Function onMore;
  final String time;

  const PostViewWidget({
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
    required this.isMedia,
    required this.imageUrls,
    required this.onLike,
    required this.onDislike,
    required this.onBookmark,
    required this.onReply,
    required this.onShare,
    required this.onMore,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      bottomSheet: CustomBottomSheet(),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        surfaceTintColor: Colors.grey.shade200,
        elevation: 0,
        title: const Text(
          "Post",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Transform.scale(
            scale: 0.85, // Adjust the scale factor to reduce size
            child: Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.grey.shade500,
                size: 32,
              ),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Transform.scale(
              scale: 1, // Adjust the scale factor to reduce size
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(width: 1, color: Colors.grey.shade400)),
                child: Icon(
                  FeatherIcons.share,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Transform.scale(
              scale: 1.1, // Adjust the scale factor to reduce size
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                    border: Border.all(width: 1, color: Colors.grey.shade400)),
                child: TwoLineMenuIcon(),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Information
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(userImageUrl),
                        radius: size.width * 0.055,
                      ),
                      SizedBox(width: size.width * 0.03),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '@$userHandle',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Post Content
            Container(
              padding: const EdgeInsets.only(left: 15, right: 20, top: 10),
              child: Text(
                content,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade900,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Media (Carousel)
            if (isMedia)
              SizedBox(
                height: size.height * 0.25,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),
              ),

            // time
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
              ),
              padding: EdgeInsets.only(
                left: 15,
                top: 0,
                bottom: 15,
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),
            // Actions with counts above icons
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              padding: EdgeInsets.only(top: 17, bottom: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BuildActionWithCount(
                    icon: FeatherIcons.arrowUp,
                    count: likesCount,
                    isActive: isLiked,
                    onTap: onLike,
                  ),
                  BuildActionWithCount(
                    icon: FeatherIcons.arrowDown,
                    count: dislikesCount,
                    isActive: isDisliked,
                    onTap: onDislike,
                  ),
                  _buildActionWithCount(
                    icon: FeatherIcons.messageCircle,
                    count: repliesCount,
                    onTap: onReply,
                  ),
                  _buildActionWithCount(
                    icon: FeatherIcons.bookmark,
                    count: bookmarksCount,
                    isActive: isBookmarked,
                    onTap: onBookmark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionWithCount({
    required IconData icon,
    required int count,
    required Function onTap,
    bool isActive = false,
  }) {
    return Column(
      children: [
        // Count Text
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 14,
            color: isActive ? const Color(0xFFBA9E02) : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Divider
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10), // Adds spacing
          height: 1.5, // Divider thickness
          width: 20, // Length of the divider
          color: isActive
              ? const Color(0xFFBA9E02)
              : Colors.grey.shade400, // Divider color
        ),
        // Action Icon
        GestureDetector(
          child: Icon(
            icon,
            color: isActive ? const Color(0xFFBA9E02) : Colors.grey.shade500,
            size: 30,
          ),
          onTap: () => onTap(),
        ),
      ],
    );
  }
}
