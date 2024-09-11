import 'package:campcon/mainscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/signupscreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestScreen extends StatefulWidget {
  const SuggestScreen({Key? key}) : super(key: key);

  @override
  State<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends State<SuggestScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = const Color(0xFF2c2221);
  bool pass = true;
  bool circular = false;
  late SharedPreferences sharedPreferences;

  int _id = 0;
  String _password = '';
  String _warn = 'This username is available!';

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
                        suggestMethod(
                            assetImage: 'assets/images/social.jpeg',
                            user: 'University of Ibadan',
                            userAt: '@unibadan'),
                        const SizedBox(
                          height: 3,
                        ),
                        suggestMethod(
                            assetImage: 'assets/images/social.jpeg',
                            user: 'Student Union of UI',
                            userAt: '@unionstudent'),
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

  Container suggestMethod(
      {required String assetImage,
      required String user,
      required String userAt}) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 0,
        right: 0,
      ),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10), // Circular border radius
      //   border: Border.all(color: Colors.grey.shade300), // Grey border
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              assetImage,
              width: 30,
              height: 30,
            ),
          ),
          const SizedBox(width: 10), // Space between avatar and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user, // Replace with the actual person's name
                  style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: screenWidth / 30,
                      fontWeight: FontWeight.bold
                      // fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  userAt, // Replace with the actual person's name
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 40,
                    // fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800, // Background color of the button
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Button padding
            child: Text(
              'Follow',
              style: TextStyle(
                fontFamily: 'Trebuchet',
                color: Colors.white,
                fontSize: screenWidth / 40,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector actionButton(BuildContext context, TaskData taskData,
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

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: screenWidth / 26, fontFamily: 'Nexa Bold'),
      ),
    );
  }

  Widget fgtPass(String title, {required Function onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Text(
          title,
          style: TextStyle(
              fontSize: screenWidth / 30,
              fontFamily: 'Trebuchet',
              color: primary),
        ),
      ),
    );
  }

  Widget customField(
      String hint,
      IconData icon,
      IconData? suffixicon,
      TextEditingController controller,
      bool obscure,
      Function(String) onChanged,
      Function onTap) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade400),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            // width: screenWidth / 15,
            child: Icon(
              icon,
              color: primary,
              size: screenWidth / 20,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: screenWidth / 30, left: screenWidth / 50),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 30,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                onChanged: (value) {
                  onChanged(value);
                },
                enableSuggestions: false,
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: screenHeight / 50),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: screenWidth / 30,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      onTap();
                    },
                    child: Icon(
                      suffixicon,
                      color: Colors.grey.shade600,
                      size: screenWidth / 20,
                    ),
                  ),
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }
}
