import 'package:campcon/services/task_data.dart';
import 'package:campcon/onboarding/setpass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late SharedPreferences sharedPreferences;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controller when the widget is removed from the widget tree.
    emailController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);
    // varibles
    Color primary = const Color(0xFF2c2221);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                              'Become a campster!',
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
                              screenHeight,
                              screenWidth,
                              'NAME',
                              Icons.alternate_email,
                              null,
                              nameController,
                              TextCapitalization.words,
                              false,
                              (String name) {
                                // name = _name;
                                // print('show: $name');
                              },
                              () {},
                            ),
                            customField(
                              screenHeight,
                              screenWidth,
                              'EMAIL',
                              Icons.alternate_email,
                              null,
                              emailController,
                              TextCapitalization.sentences,
                              false,
                              (String email) {},
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
                                    screenHeight,
                                    screenWidth,
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
                                        // Convert the email to lowercase for a case-insensitive query
                                        String emailInput = emailController.text
                                            .trim()
                                            .toLowerCase();

                                        QuerySnapshot snap =
                                            await FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .where('email',
                                                    isEqualTo: emailInput)
                                                .get();

                                        if (nameController.text.isEmpty ||
                                            emailController.text.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  Colors.grey.shade800,
                                              content: Text(
                                                'Please enter a valid name and email.',
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
                                        } else if (snap.docs.isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  Colors.grey.shade800,
                                              content: Text(
                                                'This account already exists in our record, use a different email and try again!',
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

                                          // Save the email in lowercase to ensure consistency
                                          taskData.updateSign(
                                            context,
                                            taskData.uid,
                                            nameController.text.trim(),
                                            taskData.userid,
                                            emailInput, // Store the lowercase email
                                            taskData.pass,
                                          );

                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              child: const PassScreen(),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              reverseDuration: const Duration(
                                                  milliseconds: 500),
                                            ),
                                          );
                                        }
                                      } catch (e) {
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
      double screenHeight, double screenWidth, bool circular,
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

  Widget customField(
      double screenHeight,
      double screenWidth,
      String hint,
      IconData icon,
      IconData? suffixicon,
      TextEditingController controller,
      TextCapitalization type,
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
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 30,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                textCapitalization: type,
                onChanged: (value) {
                  onChanged(value);
                },
                enableSuggestions: true,
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
