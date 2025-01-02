import 'package:campcon/floatingbutton.dart';
import 'package:campcon/screens/light_screen/lighttracker.dart';
import 'package:campcon/screens/initial_screen/story_carousel.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/screens/posts/post_view.dart';
import 'package:campcon/screens/publish.dart';
import 'package:campcon/widgets/drawer_widget.dart';
import 'package:campcon/screens/posts/posts.dart';
import 'package:campcon/widgets/homesuggest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
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

  String formatRelativeTime(DateTime addedDate) {
    return timeago.format(addedDate, locale: 'short');
  }

  String formatTime(DateTime dateTime) {
  final timeFormat = DateFormat('HH:mm'); // Format for time (24-hour format)
  final dateFormat = DateFormat('dd MMM yy'); // Format for date

  return '${timeFormat.format(dateTime)} · ${dateFormat.format(dateTime)}';
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
      floatingActionButton: FloatingButton(isFabVisible: _isFabVisible),
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
                            // Profile Image with Notification Dot
                            GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: Stack(
                                children: [
                                  // Profile Image
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 10, right: 10),
                                    child: SizedBox(
                                      width: screenWidth / 14,
                                      height: screenWidth / 14,
                                      child: const CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/social.jpeg'),
                                        backgroundColor:
                                            Colors.transparent, // Optional
                                      ),
                                    ),
                                  ),
                                  // Notification Dot
                                  Positioned(
                                    top: 2,
                                    right: 0,
                                    child: Container(
                                      width: screenWidth / 28,
                                      height: screenWidth / 28,
                                      decoration: const BoxDecoration(
                                        color: Color(
                                            0xFFBA9E02), // Notification background color
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '3', // Example notification count
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Lato',
                                            fontSize:
                                                9, // Adjust size as needed
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Logo
                            Image.asset(
                              'assets/images/logo2.png',
                              width: screenWidth / 3,
                              height: 55,
                            ),

                            // Lightbulb Icon
                            GestureDetector(
                              onTap: () =>
                                  _navigateTo(context, const LightScreen()),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color(0xFFBA9E02),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1,
                                        color: const Color(0xFFBA9E02))),
                                margin: const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 0),
                                child: SizedBox(
                                  width: screenWidth / 14,
                                  height: screenWidth / 14,
                                  child: Icon(
                                    Icons.lightbulb,
                                    size: screenWidth / 20,
                                    color: Colors.grey.shade50,
                                  ),
                                ),
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
                              text: 'Following',
                              onSelect: false,
                              index: 1),
                        ],
                      ),
                      Container(
                        // margin: const EdgeInsets.only(top: 5),
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

                  // Accessing like and dislike status
                  bool isLiked = postWithAuthor['isLiked'];
                  bool isDisliked = postWithAuthor['isDisliked'];

                  int likesCount = postData['likesCount'] ?? 0;
                  int dislikesCount = postData['dislikesCount'] ?? 0;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return PostWidget(
                        userHandle: authorData?['userId'] ?? 'Unknown',
                        userName: authorData?['name'] ?? 'Unknown',
                        userImageUrl: 'assets/images/social.jpeg',
                        content: postData['content'] ?? '',
                        time: relativeTime,
                        likesCount: likesCount,
                        dislikesCount: dislikesCount,
                        repliesCount: postData['repliesCount'] ?? 0,
                        bookmarksCount: postData['bookmarksCount'] ?? 0,
                        isLiked: isLiked,
                        isBookmarked: false,
                        isMedia: postData['media'] ?? false,
                        isDisliked: isDisliked,
                        onTap: () => _navigateTo(
                            context,
                            PostViewWidget(
                              userHandle: authorData?['userId'] ?? 'Unknown',
                              userName: authorData?['name'] ?? 'Unknown',
                              userImageUrl: 'assets/images/social.jpeg',
                              content: postData['content'] ?? '',
                              time: formatTime(addedDate),
                              likesCount: likesCount,
                              dislikesCount: dislikesCount,
                              repliesCount: postData['repliesCount'] ?? 0,
                              bookmarksCount: postData['bookmarksCount'] ?? 0,
                              isLiked: isLiked,
                              isBookmarked: false,
                              isMedia: postData['media'] ?? false,
                              isDisliked: isDisliked,
                              // isBookmarked: isBookmarked,
                              // isMedia: isMedia,
                              onLike: () {},
                              onDislike: () {},
                              onReply: () {},
                              onBookmark: () {},
                              onShare: () {},
                              onMore: () {},
                              // height: screenHeight,
                              // width: screenWidth,
                              imageUrls: storyImages,
                            )),
                        onLike: () async {
                          setState(() {
                            if (!isLiked) {
                              likesCount++;
                              isLiked = true;

                              if (isDisliked) {
                                dislikesCount--;
                                isDisliked = false;
                              }
                            } else {
                              likesCount--;
                              isLiked = false;
                            }

                            // Update the taskData for persistence
                            taskData.snapWithAuthors[index]['isLiked'] =
                                isLiked;
                            taskData.snapWithAuthors[index]['isDisliked'] =
                                isDisliked;
                            taskData.snapWithAuthors[index]['post']
                                ['likesCount'] = likesCount;
                            taskData.snapWithAuthors[index]['post']
                                ['dislikesCount'] = dislikesCount;
                          });

                          final postId = postData['postId'];
                          final userId = taskData.uid;

                          final likeDoc = FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('likes')
                              .doc(userId);

                          final dislikeDoc = FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('dislikes')
                              .doc(userId);

                          // Firestore logic
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final likeSnapshot = await transaction.get(likeDoc);
                            final dislikeSnapshot =
                                await transaction.get(dislikeDoc);

                            if (dislikeSnapshot.exists) {
                              transaction.delete(dislikeDoc);
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'dislikesCount': FieldValue.increment(-1)},
                              );
                            }

                            if (!likeSnapshot.exists) {
                              transaction.set(likeDoc, {
                                'likedby': userId,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'likesCount': FieldValue.increment(1)},
                              );
                            } else {
                              transaction.delete(likeDoc);
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'likesCount': FieldValue.increment(-1)},
                              );
                            }
                          });
                        },
                        onDislike: () async {
                          setState(() {
                            if (!isDisliked) {
                              dislikesCount++;
                              isDisliked = true;

                              if (isLiked) {
                                likesCount--;
                                isLiked = false;
                              }
                            } else {
                              dislikesCount--;
                              isDisliked = false;
                            }

                            // Update the taskData for persistence
                            taskData.snapWithAuthors[index]['isLiked'] =
                                isLiked;
                            taskData.snapWithAuthors[index]['isDisliked'] =
                                isDisliked;
                            taskData.snapWithAuthors[index]['post']
                                ['likesCount'] = likesCount;
                            taskData.snapWithAuthors[index]['post']
                                ['dislikesCount'] = dislikesCount;
                          });

                          final postId = postData['postId'];
                          final userId = taskData.uid;

                          final dislikeDoc = FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('dislikes')
                              .doc(userId);

                          final likeDoc = FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('likes')
                              .doc(userId);

                          // Firestore logic
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final likeSnapshot = await transaction.get(likeDoc);
                            final dislikeSnapshot =
                                await transaction.get(dislikeDoc);

                            if (likeSnapshot.exists) {
                              transaction.delete(likeDoc);
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'likesCount': FieldValue.increment(-1)},
                              );
                            }

                            if (!dislikeSnapshot.exists) {
                              transaction.set(dislikeDoc, {
                                'dislikedby': userId,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'dislikesCount': FieldValue.increment(1)},
                              );
                            } else {
                              transaction.delete(dislikeDoc);
                              transaction.update(
                                FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(postId),
                                {'dislikesCount': FieldValue.increment(-1)},
                              );
                            }
                          });
                        },
                        onReply: () {},
                        onBookmark: () {},
                        onShare: () {},
                        onMore: () {},
                        height: screenHeight,
                        width: screenWidth,
                        imageUrls: storyImages,
                      );
                    },
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
              width: 3,
              color: onSelect ? const Color(0xFFBA9E02) : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
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
  double get maxExtent => 94.0;

  @override
  double get minExtent => 94.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
