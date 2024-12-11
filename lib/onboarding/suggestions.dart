import 'package:campcon/mainscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/usersuggest.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuggestScreen extends StatelessWidget {
  final QuerySnapshot? snap;
  final int? currentSize;

  const SuggestScreen({Key? key, this.snap, this.currentSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Color primary = const Color(0xFF2c2221);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: screenHeight / 13, bottom: screenHeight / 80),
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16),
              child: GestureDetector(
                onTap: () async {
                  // verify and navigate
                  if (taskData.email.isNotEmpty) {
                    // Load user content
                    await taskData.loadSnap(newTags: taskData.tags, limit: 10);
                    if (taskData.snapShot != null &&
                        taskData.snapWithAuthors.isNotEmpty) {
                      // Navigate to MainScreen
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                          child: const MainScreen(),
                          type: PageTransitionType.rightToLeft,
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 500),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
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
            Container(
              // decoration: const BoxDecoration(color: Colors.white),
              // margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight / 160),
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
                            currentSize!,
                            (index) {
                              final doc = snap!.docs[index];
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
                  actionButton(
                    screenHeight,
                    screenWidth,
                    context,
                    taskData,
                    false,
                    magHeight: 20,
                    bgColor: Colors.grey.shade800,
                    bdColor: Colors.grey.shade800,
                    txtColor: Colors.white,
                    txt: 'Done',
                    onTap: () async {
                      // verify and navigate
                      if (taskData.email.isNotEmpty) {
                        // Load user content
                        await taskData.loadSnap(
                            newTags: taskData.tags, limit: 10);
                        if (taskData.snapShot != null &&
                            taskData.snapWithAuthors.isNotEmpty) {
                          // Navigate to MainScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              child: const MainScreen(),
                              type: PageTransitionType.rightToLeft,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration:
                                  const Duration(milliseconds: 500),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  )
                  // Container(
                  //   margin: EdgeInsets.symmetric(
                  //       horizontal: screenWidth / 12,
                  //       vertical: screenHeight / 25),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       // Navigate to next screen or home screen
                  //       Navigator.push(
                  //         context,
                  //         PageTransition(
                  //           child: const MainScreen(),
                  //           type: PageTransitionType.rightToLeft,
                  //           duration: const Duration(milliseconds: 500),
                  //           reverseDuration: const Duration(milliseconds: 500),
                  //         ),
                  //       );
                  //     },
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Text(
                  //           'Done',
                  //           style: TextStyle(
                  //               fontSize: screenWidth / 25,
                  //               fontFamily: 'Trebuchet',
                  //               fontWeight: FontWeight.bold,
                  //               color: primary),
                  //         ),
                  //         const SizedBox(
                  //           width: 5,
                  //         ),
                  //         Icon(
                  //           Icons.arrow_forward_ios,
                  //           size: screenWidth / 29,
                  //           color: primary,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector actionButton(double screenHeight, double screenWidth,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
            margin: const EdgeInsets.only(right: 30, bottom: 30, top: 10),
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 2, color: bdColor)),
            child: Center(
              child: circular
                  ? Transform.scale(
                      scale: 0.5,
                      child: CircularProgressIndicator(color: txtColor))
                  : Row(
                      children: [
                        Text(
                          txt,
                          style: TextStyle(
                              fontFamily: 'Trebuchet',
                              fontSize: screenWidth / 25,
                              fontWeight: FontWeight.bold,
                              color: txtColor,
                              letterSpacing: 0),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: screenWidth / 29,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
