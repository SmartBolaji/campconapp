import 'package:campcon/mainscreen.dart';
import 'package:campcon/onboarding/namescreen.dart';
import 'package:campcon/onboarding/schscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassScreen extends StatefulWidget {
  const PassScreen({Key? key}) : super(key: key);

  @override
  State<PassScreen> createState() => _PassScreenState();
}

class _PassScreenState extends State<PassScreen> {
  TextEditingController passController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the widget tree.
    passController.dispose();
    super.dispose();
  }

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = const Color(0xFF2c2221);
  bool pass = true;
  bool circular = false;
  late SharedPreferences sharedPreferences;
  Color _strengthColor = Colors.grey;
  IconData _strengthIcon = Icons.lock_outline;
  String _warn = '';

  void _onPasswordChanged(String password) {
    setState(() {
      _warn = _evaluatePasswordStrength(password);
    });
  }

  // password strenght checker
  String _evaluatePasswordStrength(String password) {
    if (password.length < 8) {
      _strengthColor = Colors.red;
      _strengthIcon = Icons.error;
      return 'Too Short';
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacter = password.contains(RegExp(r'[@$!%*?&]'));

    int strengthPoints = 0;
    if (hasUppercase) strengthPoints++;
    if (hasLowercase) strengthPoints++;
    if (hasDigit) strengthPoints++;
    if (hasSpecialCharacter) strengthPoints++;

    if (strengthPoints >= 4) {
      _strengthColor = Colors.green;
      _strengthIcon = Icons.check_circle;
      return 'Strong';
    }
    if (strengthPoints == 3) {
      _strengthColor = Colors.orange;
      _strengthIcon = Icons.check;
      return 'Medium';
    }

    _strengthColor = Colors.red;
    _strengthIcon = Icons.warning;
    return 'Weak';
  }

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
                  value: 0.5, // Current progress
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
                          Text(
                            'You need a password',
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: screenWidth / 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 0),
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
                                'PASSWORD',
                                Icons.password,
                                pass ? Icons.visibility_off : Icons.visibility,
                                passController,
                                pass, (String pass) {
                              setState(() {
                                _onPasswordChanged(pass);
                              });
                            }, () {
                              setState(() {
                                pass = !pass;
                              });
                            }),
                            // only show if value is not empty
                            if (passController.text.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(_strengthIcon,
                                          color: _strengthColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _warn,
                                          style: TextStyle(
                                            fontFamily: 'Trebuchet',
                                            fontSize: screenWidth / 30,
                                            color: _strengthColor,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Add a progress bar to represent password strength visually
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (_strengthColor ==
                                              Colors.green)
                                          ? 1.0
                                          : (_strengthColor == Colors.orange)
                                              ? 0.7
                                              : (_strengthColor == Colors.red &&
                                                      _warn == 'Weak')
                                                  ? 0.4
                                                  : 0.2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _strengthColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: actionButton(
                                    context,
                                    taskData,
                                    taskData.circular,
                                    magHeight: screenHeight / 100,
                                    bgColor: Colors.grey.shade800,
                                    bdColor: Colors.grey.shade800,
                                    txtColor: Colors.white,
                                    txt: 'NEXT',
                                    onTap: () async {
                                      // start rolling
                                      taskData.updateCircle(context, true);

                                      try {
                                        // Trim the password to remove space
                                        String passInput =
                                            passController.text.trim();

                                        if (passInput.length < 8) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  Colors.grey.shade800,
                                              content: Text(
                                                'The password cannot be less than 8 characters, add more letters or symbols and try again!',
                                                style: TextStyle(
                                                  fontFamily: 'Trebuchet',
                                                  fontSize: screenWidth / 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                          // stop rolling
                                          taskData.updateCircle(context, false);
                                        } else {
                                          // stop rolling
                                          taskData.updateCircle(context, false);

                                          // Save the password locally
                                          taskData.updateSign(
                                            context,
                                            taskData.uid,
                                            taskData.name,
                                            taskData.userid,
                                            taskData.email,
                                            passInput,
                                          );

                                          // dynamic naviagation
                                          if (taskData.role == 'Student') {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: const SchScreen(),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                reverseDuration: const Duration(
                                                    milliseconds: 500),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: const UsernameScreen(),
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                reverseDuration: const Duration(
                                                    milliseconds: 500),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        // stop rolling
                                        taskData.updateCircle(context, false);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.grey.shade800,
                                            content: Text(
                                              'An error occurred: ${e.toString()}',
                                              style: TextStyle(
                                                fontFamily: 'Trebuchet',
                                                fontSize: screenWidth / 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
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
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.bold,
                                  // fontStyle: FontStyle.italic,
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
                      fontFamily: 'Lato',
                      fontSize: screenWidth / 25,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                      letterSpacing: 0),
                ),
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
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade400),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // SizedBox(
          //   width: screenWidth / 20,
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: screenWidth / 30,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                textCapitalization: TextCapitalization.words,
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
                      fontFamily: 'Lato',
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
