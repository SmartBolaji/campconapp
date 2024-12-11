import 'package:campcon/screens/light_screen/lighttracker.dart';
import 'package:campcon/screens/initial_screen/story_carousel.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/screens/publish.dart';
import 'package:campcon/widgets/posts.dart';
import 'package:campcon/widgets/homesuggest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  String formatRelativeTime(DateTime addedDate) {
    return timeago.format(addedDate, locale: 'short');
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !_isFabVisible) {
        setState(() => _isFabVisible = true);
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
    final taskData = Provider.of<TaskData>(context);

    final List<User> mockUsers = [
      User(
          name: 'Alice Johnson',
          handle: 'alice_j',
          imageUrl: 'assets/images/social.jpeg'),
      User(
          name: 'Bob Smith',
          handle: 'bob_s',
          imageUrl: 'assets/images/social.jpeg'),
      User(
          name: 'Charlie Brown',
          handle: 'charlie_b',
          imageUrl: 'assets/images/social.jpeg'),
    ];

    final storyImages = [
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
      'assets/images/social.jpeg',
    ];

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                child: const PostPage(),
                type: PageTransitionType.bottomToTop,
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.grey.shade800,
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              floating: true,
              delegate: SliverRowHeaderDelegate(
                child: Container(
                  padding: const EdgeInsets.only(top: 0),
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: screenWidth / 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _navigateTo(context, const PointsScreen()),
                              child: Icon(Icons.account_circle_outlined,
                                  size: screenWidth / 15,
                                  color: Colors.grey.shade800),
                            ),
                            Image.asset(
                              'assets/images/logo2.png',
                              width: screenWidth / 3,
                              height: 55,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _navigateTo(context, const LightScreen()),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.lightbulb,
                                    size: screenWidth / 15,
                                    color: Colors.yellow.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          topButtons(
                              onTap: () {},
                              text: 'Explore',
                              onSelect: true,
                              index: 0),
                          topButtons(
                              onTap: () {},
                              text: 'Connects',
                              onSelect: false,
                              index: 1),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StoryViewCarousel(storyImages: storyImages),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final postWithAuthor = taskData.snapWithAuthors[index];
                  final postData = postWithAuthor['post'];
                  final authorData = postWithAuthor['author'];
                  final DateTime addedDate =
                      (postData['addedDate'] as Timestamp).toDate();
                  final String relativeTime = formatRelativeTime(addedDate);

                  return PostWidget(
                    userHandle: authorData?['userId'] ?? 'Unknown',
                    userName: authorData?['name'] ?? 'Unknown',
                    userImageUrl: 'assets/images/social.jpeg',
                    content: postData['content'] ?? '',
                    time: relativeTime,
                    likesCount: postData['likesCount'] ?? 0,
                    dislikesCount: postData['dislikesCount'] ?? 0,
                    repliesCount: postData['repliesCount'] ?? 0,
                    bookmarksCount: postData['bookmarksCount'] ?? 0,
                    isLiked: false,
                    isBookmarked: false,
                    isDisliked: true,
                    onLike: () {},
                    onDislike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    onMore: () {},
                    height: screenHeight,
                    width: screenWidth,
                  );
                },
                childCount: taskData.snapWithAuthors.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SuggestionWidget(
                suggestedUsers: mockUsers,
                onConnect: (user) {},
                height: screenHeight,
                width: screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topButtons({
    required Function onTap,
    required String text,
    required bool onSelect,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.only(left: index == 0 ? 16 : 7, right: 20),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: onSelect ? const Color(0xFFBA9E02) : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Trebuchet',
            fontSize: screenWidth / 25,
            color: onSelect ? const Color(0xFFBA9E02) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageTransition(
        child: screen,
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
      ),
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
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
