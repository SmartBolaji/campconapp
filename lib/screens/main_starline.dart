import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/play.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/all_tile.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlayStarlineScreen extends StatefulWidget {
  const PlayStarlineScreen({super.key});

  @override
  State<PlayStarlineScreen> createState() => _PlayStarlineState();
}

class _PlayStarlineState extends State<PlayStarlineScreen> {
  late Future<void> fetchDataFuture;

  QuerySnapshot? _snap;
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  int currentSize = 0;

  // Functions

  // Direct the user to their default browser
  void launchURL(String? url) async {
    if (await canLaunchUrlString(url!)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Method to load games data
  Future<void> loadMrkData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Games')
          .where('status', isEqualTo: 'Active')
          .where('mrksection', isEqualTo: 'Starline')
          .orderBy('created', descending: false)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Games')
            .where('status', isEqualTo: 'Active')
            .where('mrksection', isEqualTo: 'Starline')
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

  @override
  void initState() {
    super.initState();
    fetchDataFuture = loadMrkData();
  }

  @override
  Widget build(BuildContext context) {
    // // Provider
    // final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: screenHeight / 30,
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STARLINE',
                style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: screenWidth / 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: 20,
                top: 5,
              ),
              children: [
                _snap == null
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight / 8,
                        ),
                        child: CircleAvatar(
                            backgroundColor: Colors.blue.shade400,
                            radius: 50,
                            child: const CircularProgressIndicator(
                                color: Colors.white)),
                      )
                    : ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          currentSize,
                          (index) {
                            final doc = _snap!.docs[index];
                            String market = doc.get('mrkname');
                            String mrkSection = doc.get('mrksection');
                            String mrkOpen = doc.get('mrkopen');
                            String mrkClose = doc.get('mrkclose');
                            String mrkDigit = doc.get('digit').toString();
                            String mrkOpenPana = doc.get('openpana').toString();
                            String mrkClosePana =
                                doc.get('closepana').toString();

                            return AllTile(
                              allTitle: market,
                              allsub1: mrkOpen,
                              allsub2:
                                  mrkDigit == '1000' || mrkOpenPana == '1000'
                                      ? 'XXX-X'
                                      : '$mrkOpenPana-$mrkDigit',
                              allisChecked:
                                  mrkDigit == '1000' || mrkOpenPana == '1000'
                                      ? false
                                      : true,
                              allonTapCallback: () {
                                mrkDigit == '1000' || mrkOpenPana == '1000'
                                    ? Navigator.push(
                                        context,
                                        PageTransition(
                                          child: PlayScreen(
                                            mainTitle: market,
                                            mainSection: mrkSection,
                                          ),
                                          type: PageTransitionType.bottomToTop,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          reverseDuration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      )
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'Market Close!',
                                            style: TextStyle(
                                              fontFamily: 'Nexa Light',
                                              fontSize: screenWidth / 30,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            );
                            // : const SizedBox();
                          },
                        ),
                      ),
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
          color: Colors.blue.shade900,
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
