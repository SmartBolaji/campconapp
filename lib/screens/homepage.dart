import 'package:campcon/screens/points.dart';
import 'package:campcon/widgets/posts.dart';
import 'package:campcon/widgets/homesuggest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                            child: const PointsScreen(),
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Icon(
                        IconlyBold.setting,
                        size: screenWidth / 15,
                        color: Colors.grey.shade800,
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  topButtons(
                      onTap: () {}, text: 'Explore', onSelect: false, index: 0),
                  topButtons(
                      onTap: () {}, text: 'Connects', onSelect: true, index: 0),
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
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              children: [
                PostWidget(
                    userHandle: 'UIibadan',
                    userName: 'University of Ibadan',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Learning how to optimize performance in Flutter apps. There's so much to discover! 📈 Any tips from fellow devs? #FlutterTips",
                    time: '2h',
                    likesCount: 198,
                    repliesCount: 10,
                    bookmarksCount: 5,
                    isLiked: true,
                    isBookmarked: true,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    height: screenHeight,
                    width: screenWidth),

                PostWidget(
                    userHandle: 'tech_guru',
                    userName: 'Tech Guru',
                    userImageUrl: 'assets/images/social.jpeg',
                    content:
                        "Just finished building my first Flutter app! 🚀 It's amazing how quickly you can create beautiful UIs. Now onto integrating Firebase for real-time data. Any advice on managing state efficiently? #FlutterDev #Firebase",
                    time: '1d',
                    likesCount: 320,
                    repliesCount: 20,
                    bookmarksCount: 7,
                    isLiked: false,
                    isBookmarked: false,
                    onLike: () {},
                    onReply: () {},
                    onBookmark: () {},
                    height: screenHeight,
                    width: screenWidth),

                SuggestionWidget(
                    suggestedUsers: mockUsers,
                    onConnect: (user) {},
                    height: screenHeight,
                    width: screenWidth)

                // _snap == null
                //     ? Padding(
                //         padding: EdgeInsets.only(
                //           top: screenHeight / 8,
                //         ),
                //         child: CircleAvatar(
                //             backgroundColor: Colors.blue.shade400,
                //             radius: 50,
                //             child: const CircularProgressIndicator(
                //                 color: Colors.white)),
                //       )
                //     : ListView(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         children: List.generate(
                //           currentSize,
                //           (index) {
                //             final doc = _snap!.docs[index];
                //             String market = doc.get('mrkname');
                //             String mrkSection = doc.get('mrksection');
                //             String mrkOpen = doc.get('mrkopen');
                //             String mrkClose = doc.get('mrkclose');
                //             String mrkDigit = doc.get('digit').toString();
                //             String mrkOpenPana = doc.get('openpana').toString();
                //             String mrkClosePana =
                //                 doc.get('closepana').toString();

                //             return AllTile(
                //               allTitle: market,
                //               allsub1: 'Open $mrkOpen | Close $mrkClose',
                //               allsub2: mrkDigit == '1000' ||
                //                       mrkOpenPana == '1000' ||
                //                       mrkClosePana == '1000'
                //                   ? 'XXX-XX-XXX'
                //                   : '$mrkOpenPana-$mrkDigit-$mrkClosePana',
                //               allisChecked: mrkDigit == '1000' ||
                //                       mrkOpenPana == '1000' ||
                //                       mrkClosePana == '1000'
                //                   ? false
                //                   : true,
                //               allonTapCallback: () {
                //                 mrkDigit == '1000' ||
                //                         mrkOpenPana == '1000' ||
                //                         mrkClosePana == '1000'
                //                     ? Navigator.push(
                //                         context,
                //                         PageTransition(
                //                           child: PlayScreen(
                //                             mainTitle: market,
                //                             mainSection: mrkSection,
                //                           ),
                //                           type: PageTransitionType.bottomToTop,
                //                           duration:
                //                               const Duration(milliseconds: 500),
                //                           reverseDuration:
                //                               const Duration(milliseconds: 500),
                //                         ),
                //                       )
                //                     : ScaffoldMessenger.of(context)
                //                         .showSnackBar(
                //                         SnackBar(
                //                           backgroundColor: Colors.red,
                //                           content: Text(
                //                             'Market Close!',
                //                             style: TextStyle(
                //                               fontFamily: 'Nexa Light',
                //                               fontSize: screenWidth / 30,
                //                               color: Colors.white,
                //                             ),
                //                           ),
                //                         ),
                //                       );
                //                 ;
                //               },
                //             );
                //             // : const SizedBox();
                //           },
                //         ),
                //       ),
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
