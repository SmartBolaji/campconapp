import 'package:campcon/screens/lighttracker.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/screens/publish.dart';
import 'package:campcon/widgets/posts.dart';
import 'package:campcon/widgets/homesuggest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/drawer_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> fetchDataFuture;
  final Uri _url = Uri.parse('https://flutter.dev');
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  QuerySnapshot? _snap;
  QuerySnapshot? _snap1;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int currentSize = 0;

  // Variables (admin)
  int adminId = 0;
  String alertMsg = '';
  String whatsNo = '';
  String whatsLink = '';
  String callNo = '';
  String howToPlay = '';

  // Functions
  Future<void> _launchUrl({required String url}) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  // Method to load games data
  Future<void> loadMrkData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Games')
          .where('status', isEqualTo: 'Active')
          .where('mrksection', isEqualTo: 'Mumbai')
          .orderBy('created', descending: false)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Games')
            .where('status', isEqualTo: 'Active')
            .where('mrksection', isEqualTo: 'Mumbai')
            .orderBy('created', descending: false)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }
      if (_snap!.size > 30) {
        setState(() {
          currentSize = 30; // Update to 20
        });
      } else {
        setState(() {
          currentSize = _snap!.size; // Update default
        });
      }
    } catch (e) {
      e.toString();
    }
  }

  // load the app settings
  Future<void> loadSettingsData() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('Settings').get();
      if (snap.docs.isEmpty) {
        _snap1 = await FirebaseFirestore.instance
            .collection('Settings')
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap1 = snap;
      }

      if (_snap1!.docs[0].exists) {
        final doc = _snap1!.docs[0];
        adminId = doc.get('adminid');
        alertMsg = doc.get('alertmsg');
        whatsNo = doc.get('whatsno');
        whatsLink = doc.get('whatslink');
        callNo = doc.get('callno');
        howToPlay = doc.get('howtoplay');
      }
      setState(() {});
    } catch (e) {
      e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSettingsData();
    fetchDataFuture = loadMrkData();

    // Attach a listener to the ScrollController
    _scrollController.addListener(
      () {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isFabVisible) {
            setState(() {
              _isFabVisible = false;
            });
          }
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isFabVisible) {
            setState(() {
              _isFabVisible = true;
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    // Mock user data
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

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: () {
            // Your action here
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
          backgroundColor: Colors.grey.shade800,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: 15, left: screenWidth / 20, right: screenWidth / 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const PointsScreen(),
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: screenWidth / 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo2.png',
                      width: screenWidth / 3,
                      height: screenHeight / 9,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const LightScreen(),
                              type: PageTransitionType.rightToLeft,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFBA9E02)
                                    .withOpacity(0.6), // Glow color
                                blurRadius: 20, // How much the glow spreads
                                spreadRadius:
                                    3, // How much glow extends beyond the icon
                              ),
                            ],
                          ),
                          child: Icon(
                            FontAwesomeIcons.lightbulb,
                            size: screenWidth / 15,
                            color: const Color(0xFFBA9E02), // Core icon color
                          ),
                        ))
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  topButtons(
                      onTap: () {}, text: 'Explore', onSelect: true, index: 0),
                  topButtons(
                      onTap: () {},
                      text: 'Connects',
                      onSelect: false,
                      index: 0),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              children: [
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "We would like to inform all students and staff that the University of Ibadan will hold its annual convocation ceremony from November 15-17. Graduating students are required to complete all necessary clearance procedures by November 10.",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 \n\nIt's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 0,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    onShare: () {},
                    height: screenHeight,
                    width: screenWidth),
                SuggestionWidget(
                    suggestedUsers: mockUsers,
                    onConnect: (user) {},
                    height: screenHeight,
                    width: screenWidth)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget topButtons(
      {required Function onTap,
      required String text,
      required bool onSelect,
      required int index}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(left: index == 0 ? 16 : 7, right: 20),
        padding: const EdgeInsets.only(top: 6, bottom: 6, right: 0, left: 0),
        // width: screenWidth / 2.2,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: onSelect ? const Color(0xFFBA9E02) : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontSize: screenWidth / 25,
                color:
                    onSelect ? const Color(0xFFBA9E02) : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
