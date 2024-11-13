import 'package:campcon/mainscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/usersuggest.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestScreen extends StatefulWidget {
  final QuerySnapshot? snap;
  final int? currentSize;

  const SuggestScreen({Key? key, this.snap, this.currentSize})
      : super(key: key);

  @override
  State<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends State<SuggestScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = const Color(0xFF2c2221);
  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: screenHeight / 13, bottom: screenHeight / 40),
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to next screen or home screen
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const MainScreen(),
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: screenWidth / 25,
                          fontFamily: 'Trebuchet',
                          color: primary),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: screenWidth / 29,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: screenHeight / 200,
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: screenHeight / 30, bottom: screenHeight / 160),
                    child: Image.asset(
                      'assets/images/logo2.png',
                      width: screenWidth / 3,
                      height: screenHeight / 9,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth / 12,
                        vertical: screenHeight / 60),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Follow 1 or more to continue...',
                          style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(horizontal: screenWidth / 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          children: List.generate(
                            widget.currentSize!,
                            (index) {
                              final doc = widget.snap!.docs[index];
                              String name = doc.get('name');
                              String userAt = '@${doc.get('userId')}';
                              String bio = doc.get('bio');
                              String uid = doc.get('uid');

                              return UserSuggestion(
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                assetImage: 'assets/images/social.jpeg',
                                user: name,
                                userAt: userAt,
                                userBio: bio,
                                userId: uid,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth / 12,
                        vertical: screenHeight / 25),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to next screen or home screen
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const MainScreen(),
                            type: PageTransitionType.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Done',
                            style: TextStyle(
                                fontSize: screenWidth / 25,
                                fontFamily: 'Trebuchet',
                                fontWeight: FontWeight.bold,
                                color: primary),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: screenWidth / 29,
                            color: primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector actionButton(
      BuildContext context, TaskData taskData, bool circular,
      {required double magHeight,
      required Color bgColor,
      required Color bdColor,
      required txtColor,
      required String txt,
      required Function onTap}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        height: screenHeight / 14,
        width: screenWidth / 2.9,
        // margin: EdgeInsets.only(top: magHeight),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 2, color: bdColor)),
        child: Center(
          child: circular
              ? Transform.scale(
                  scale: 0.5, child: CircularProgressIndicator(color: txtColor))
              : Text(
                  txt,
                  style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: screenWidth / 25,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                      letterSpacing: 0),
                ),
        ),
      ),
    );
  }
}
