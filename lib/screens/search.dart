import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const SafeArea(child: DrawerWidget()),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              children: const [
                SizedBox(
                  height: 200,
                ),

                Icon(
                  IconlyBold.search,
                  size: 100,
                )
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
          )
        ],
      ),
    );
  }

  Widget topButtons(
      {required Function onTap,
      required IconData icon,
      required String text,
      required double screenWidth}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding:
            const EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
        // width: screenWidth / 2.2,
        decoration: BoxDecoration(
          color: text == 'PLAY STARLINE' || text == 'How To Play'
              ? Colors.grey.shade800
              : Colors.blue.shade900,
          borderRadius: const BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth / 15,
              color: Colors.white,
            ),
            const SizedBox(
              width: 7,
            ),
            Text(
              text,
              style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: screenWidth / 28,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
