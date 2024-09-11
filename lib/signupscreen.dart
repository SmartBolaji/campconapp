import 'package:campcon/mainscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/setpass.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight / 30, bottom: 20, right: 20, left: 20),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(20),
                  value: 0.25, // Current progress
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.grey.shade900, // Progress color
                  minHeight: 5.0, // Thickness of the line
                ),
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
                          Flexible(
                            child: Text(
                              'Hey! Create your account on Campcon.',
                              style: TextStyle(
                                  fontFamily: 'Trebuchet',
                                  fontSize: screenWidth / 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(horizontal: screenWidth / 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customField(
                              'NAME',
                              Icons.alternate_email,
                              null,
                              idController,
                              false,
                              (String id) {
                                // setState(() {
                                //   _id = int.parse(id);
                                // });
                              },
                              () {},
                            ),
                            customField(
                              'EMAIL',
                              Icons.alternate_email,
                              null,
                              idController,
                              false,
                              (String id) {
                                // setState(() {
                                //   _id = int.parse(id);
                                // });
                              },
                              () {},
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: actionButton(
                                    context,
                                    taskData,
                                    magHeight: screenHeight / 100,
                                    bgColor: Colors.grey.shade800,
                                    bdColor: Colors.grey.shade800,
                                    txtColor: Colors.white,
                                    txt: 'Next',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: const PassScreen(),
                                          type: PageTransitionType.rightToLeft,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          reverseDuration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: screenHeight / 20,
                            // ),
                          ],
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth / 12,
                          vertical: screenHeight / 25),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to next screen or home screen
                          Navigator.pop(context);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: screenWidth / 29,
                              color: primary,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Back',
                              style: TextStyle(
                                  fontSize: screenWidth / 25,
                                  fontFamily: 'Trebuchet',
                                  fontWeight: FontWeight.bold,
                                  color: primary),
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
        width: screenWidth / 3,
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
          // SizedBox(
          //   width: screenWidth / 20,
          // ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 30),
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
                      EdgeInsets.symmetric(vertical: screenHeight / 80),
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
