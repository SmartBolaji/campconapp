import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';

class ProfilePage extends StatefulWidget {
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
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  int _currentIndex = 0;

  void _updateCanShow(bool value) {
    setState(() {
      _showAppBarTitle = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 150 && !_showAppBarTitle) {
        _updateCanShow(true);
      } else if (_scrollController.offset <= 150 && _showAppBarTitle) {
        _updateCanShow(false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            // CustomScrollView with sliver-based AppBar
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Other slivers, e.g., SliverAppBar, SliverList for profile details
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Other widgets for profile details, etc.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: width,
                          height: height / 5.5,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(widget.coverImageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(
                                  top: 6,
                                  left: 5), // Add padding for proper placement
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                    0.5), // Add background for better visibility
                                shape: BoxShape.circle,
                              ),
                              child: GestureDetector(
                                child: const Icon(IconlyLight.arrow_left,
                                    size: 24, color: Colors.white),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ),
                        // Profile Image
                        Positioned(
                          bottom:
                              -height / 20, // Extends the profile image outside
                          left: width / 2 - (width / 8), // Centers the image
                          child: Container(
                            width: width / 4.5,
                            height: width / 4.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                image: AssetImage(widget.profileImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildProfileDetails(width),
                    // const SizedBox(height: 15),
                    // _buildBioColumn(),
                    const SizedBox(height: 20),
                    _buildCountsRow(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 25),
                  ]),
                ),
                // Place SliverPersistentHeader directly as a sliver
                SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: SliverRowHeaderDelegate(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                      child: _buildTabBar(),
                    ),
                  ),
                ),
                // Placeholder post list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Sample Post ${index + 1}",
                        style: GoogleFonts.lato(),
                      ),
                    ),
                    childCount: 100,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // AppBar actions
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      // _buildAppBarAction(Icons.bookmark),
      _buildAppBarAction(context, Icons.share),
      const SizedBox(
        width: 10,
      )
    ];
  }

  Widget _buildAppBarAction(BuildContext context, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Transform.scale(
        scale: 0.85,
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade100,
            border: Border.all(
              width: 1,
              color: Colors.grey.shade400,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade800,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Profile Details
  Widget _buildProfileDetails(double width) {
    return // Name and Username
        Column(
      children: [
        Text(
          widget.userName,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: width / 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          '@${widget.userHandle}',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
            fontSize: width / 26,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBioColumn() {
    return Column(
      children: [
        // Bio
        Text(
          'This is a sample page.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Connecting and Connects Count
  Widget _buildCountsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCountColumn(widget.connectingCount, 'Following'),
        const SizedBox(width: 30), // Space between the counts
        SizedBox(
          height: 30, // Add a fixed height to make the divider visible
          child: VerticalDivider(
            color: Colors.grey.shade300, // Color of the line
            thickness: 1, // Line thickness
            width: 1, // Set a small width for the divider to appear
          ),
        ),
        const SizedBox(width: 30), // Space between the counts
        _buildCountColumn(widget.connectsCount, 'Followers'),
      ],
    );
  }

  Widget _buildCountColumn(int count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            fontFamily: 'Lato',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton('Edit Profile', Colors.grey.shade800),
        const SizedBox(width: 10),
        _buildActionButton('Share Profile', Colors.grey.shade800),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {},
          icon: Icon(
            IconlyBold.arrow_down_circle,
            size: 24,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.grey.shade800,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        )
      ],
    );
  }

  Widget _buildActionButton(String label, Color bgColor) {
    return ElevatedButton.icon(
      onPressed: () {},
      label: Text(label!,
          style: TextStyle(
              fontFamily: 'Lato', fontWeight: FontWeight.w400, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Tab Bar
  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade50,
      width: double.infinity,
      height: 30,
      child: Center(
        child: Container(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            children: [
              _buildTabButton('Posts', true),
              _buildTabButton('Media'),
              _showAppBarTitle ? _buildTabButton('Media') : const SizedBox(),
              _buildTabButton('Events'),
              _buildTabButton('About'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, [bool isActive = false]) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
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

  // Placeholder Post List
  Widget _buildPostList() {
    return Column(
      children: List.generate(100, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Sample Post ${index + 1}",
            style: GoogleFonts.lato(),
          ),
        );
      }),
    );
  }
}

class SliverRowHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverRowHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 30.0;

  @override
  double get minExtent => 30.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
