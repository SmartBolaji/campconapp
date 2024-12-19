import 'package:campcon/widgets/posts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class ProfilePage extends StatelessWidget {
  final String coverImageUrl;
  final String profileImageUrl;
  final String userName;
  final String userHandle;
  final int connectsCount;
  final int connectingCount;

  const ProfilePage({
    Key? key,
    required this.coverImageUrl,
    required this.profileImageUrl,
    required this.userName,
    required this.userHandle,
    required this.connectsCount,
    required this.connectingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Image with Back Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width,
                  height: height / 5.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(coverImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(
                          top: 45, left: 5), // Add padding for proper placement
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(
                            0.5), // Add background for better visibility
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        child: const Icon(IconlyLight.arrow_left_2,
                            size: 25, color: Colors.white),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
                // Profile Image
                Positioned(
                  bottom: -height / 20, // Extends the profile image outside
                  left: width / 2 - (width / 8), // Centers the image
                  child: Container(
                    width: width / 4.5,
                    height: width / 4.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: DecorationImage(
                        image: AssetImage(profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height / 16),
            // Name and Username
            Column(
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    // fontFamily: 'Trebuchet',
                    fontSize: width / 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '@$userHandle',
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    // fontStyle: FontStyle.italic,
                    fontSize: width / 26,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Connecting and Connects Count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$connectingCount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        // fontFamily: 'Trebuchet',
                      ),
                    ),
                    Text(
                      'Following',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        // fontFamily: 'Trebuchet',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30), // Space between the counts
                Container(
                  height: 30, // Add a fixed height to make the divider visible
                  child: VerticalDivider(
                    color: Colors.grey.shade300, // Color of the line
                    thickness: 1, // Line thickness
                    width: 1, // Set a small width for the divider to appear
                  ),
                ),
                const SizedBox(
                    width: 30), // Space between the line and the second column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$connectsCount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        // fontFamily: 'Trebuchet',
                      ),
                    ),
                    Text(
                      'Followers',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        // fontFamily: 'Trebuchet',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton('Edit Profile', Icons.edit),
                const SizedBox(width: 10),
                _buildActionButton('Share Profile', Icons.share),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    IconlyLight.add_user,
                    size: 18,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              ],
            ),
            // Bio
            const SizedBox(height: 10),
            Text(
              'This is a sample page.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                // fontFamily: 'Trebuchet',
              ),
            ),
            const SizedBox(height: 20),
            // Tab Bar
            Container(
              width: width,
              height: 35,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('Posts', isActive: true),
                  _buildTabButton('Media'),
                  _buildTabButton('Events'),
                  _buildTabButton('Resources'),
                  _buildTabButton('About'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Posts Section using PostWidget
            Column(
              children: List.generate(
                5,
                (index) => PostWidget(
                  userHandle: userHandle,
                  userName: userName,
                  userImageUrl: profileImageUrl,
                  content:
                      'This is a sample post content for testing purposes.',
                  likesCount: 20 + index,
                  dislikesCount: 5 + index,
                  repliesCount: 10 + index,
                  bookmarksCount: 3 + index,
                  isLiked: index % 2 == 0,
                  isDisliked: index % 2 != 0,
                  isBookmarked: index % 3 == 0,
                  onLike: () {},
                  onDislike: () {},
                  onBookmark: () {},
                  onReply: () {},
                  onShare: () {},
                  onMore: () {},
                  height: height,
                  width: width,
                  time: '2h', imageUrls: [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget
  Widget _buildActionButton(String? label, IconData? icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      // icon: Icon(icon, size: 18),
      label: Text(label!, style: GoogleFonts.poppins(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: const Color(0xFFBA9E02),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Tab Button Widget
  Widget _buildTabButton(String label, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey.shade600,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 40,
                height: 3,
                color: const Color(0xFFBA9E02),
              ),
          ],
        ),
      ),
    );
  }
}
