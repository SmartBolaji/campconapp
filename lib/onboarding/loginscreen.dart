import 'package:campcon/onboarding/role.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/fgt_pass.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
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
              Container(
                // decoration: const BoxDecoration(color: Colors.white),
                margin: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildInteractiveFeatureRow(),
                    Container(
                        margin:
                            EdgeInsets.only(top: 0, bottom: screenHeight / 160),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          width: screenWidth / 3,
                          height: screenHeight / 9,
                        )),
                    Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: Text(
                        'Connect with people on Campcon',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',
                          // fontStyle: FontStyle.italic,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(horizontal: screenWidth / 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customField(
                              'EMAIL, OR USERNAME',
                              Icons.alternate_email,
                              null,
                              TextCapitalization.sentences,
                              idController,
                              false,
                              (String id) {},
                              () {},
                            ),
                            customField(
                                'PASSWORD',
                                Icons.password,
                                pass ? Icons.visibility_off : Icons.visibility,
                                TextCapitalization.words,
                                passController,
                                pass, (String pass) {
                              setState(() {
                                _password = pass;
                              });
                            }, () {
                              setState(() {
                                pass = !pass;
                              });
                            }),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                fgtPass('Forget Password?', onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: const MainScreen(),
                                      type: PageTransitionType.rightToLeft,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      reverseDuration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                })
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            actionButton(
                              context,
                              taskData,
                              taskData.circular,
                              magHeight: screenHeight / 40,
                              bgColor: Colors.grey.shade400,
                              bdColor: Colors.grey.shade400,
                              txtColor: Colors.grey.shade700,
                              txt: 'LOGIN',
                              onTap: () async {
                                // Close the keyboard
                                FocusScope.of(context).unfocus();

                                // Start loading indicator
                                taskData.updateCircle(context, true);

                                try {
                                  // Get user input
                                  String idInput =
                                      idController.text.trim().toLowerCase();
                                  String password = passController.text.trim();

                                  // Validate input fields
                                  if (idInput.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.grey.shade800,
                                        content: Text(
                                          'Please enter a valid username or email and try again.',
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );

                                    // Stop loading indicator
                                    taskData.updateCircle(context, false);
                                    return;
                                  }

                                  // Initialize variables
                                  String? uid,
                                      email,
                                      userid,
                                      name,
                                      sch,
                                      level,
                                      dept,
                                      faculty,
                                      loc;
                                  List<dynamic> tags = [];

                                  // Determine if input is email or username
                                  final isEmail = RegExp(
                                          r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(idInput);

                                  if (isEmail) {
                                    email = idInput; // Input is an email
                                  } else {
                                    // Fetch email associated with username
                                    final querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('userCheck',
                                                isEqualTo: idInput)
                                            .limit(1)
                                            .get();

                                    if (querySnapshot.docs.isNotEmpty) {
                                      email = querySnapshot.docs.first['email'];
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.grey.shade800,
                                          content: Text(
                                            'Username not found.',
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );

                                      // Stop loading indicator
                                      taskData.updateCircle(context, false);
                                      return;
                                    }
                                  }

                                  // Authenticate user
                                  if (email != null) {
                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );

                                      // Fetch user details from Firestore
                                      final userSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .where('email', isEqualTo: email)
                                              .limit(1)
                                              .get();

                                      if (userSnapshot.docs.isNotEmpty) {
                                        var userDoc = userSnapshot.docs.first;
                                        email = userDoc['email'];
                                        uid = userDoc['uid'];
                                        userid = userDoc['userId'];
                                        name = userDoc['name'];
                                        sch = userDoc['sch'];
                                        level = userDoc['level'];
                                        dept = userDoc['dept'];
                                        faculty = userDoc['faculty'];
                                        loc = userDoc['hostel'];
                                        tags = userDoc['tags'];

                                        // Save data locally
                                        taskData.updateLogin(context, uid!,
                                            name!, userid!, email!);
                                        taskData.updateSchool(context, sch,
                                            level, dept, faculty, loc);
                                        taskData.updateTags(context, tags);

                                        // Load user content
                                        await taskData.loadSnap(
                                            newTags: tags, limit: 10);

                                        if (taskData.snapShot != null &&
                                            taskData
                                                .snapWithAuthors.isNotEmpty) {
                                          // Navigate to MainScreen
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            PageTransition(
                                              child: const MainScreen(),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              reverseDuration: const Duration(
                                                  milliseconds: 500),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        }
                                      }
                                    } catch (authError) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.grey.shade800,
                                          content: Text(
                                            'Login failed: ${authError.toString()}',
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  30,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Handle general errors
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.grey.shade800,
                                      content: Text(
                                        'An error occurred: ${e.toString()}',
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                } finally {
                                  // Stop loading indicator
                                  taskData.updateCircle(context, false);
                                }
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            actionButton(
                              context,
                              taskData,
                              circular,
                              magHeight: screenHeight / 100,
                              bgColor: Colors.grey.shade800,
                              bdColor: Colors.grey.shade800,
                              txtColor: Colors.white,
                              txt: 'SIGNUP',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const RoleScreen(),
                                    type: PageTransitionType.rightToLeft,
                                    duration: const Duration(milliseconds: 500),
                                    reverseDuration:
                                        const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: screenHeight / 20,
                            ),
                          ],
                        ))
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
        width: double.infinity,
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
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Color(0xFFBA9E02)),
        ),
      ),
    );
  }

  Widget customField(
      String hint,
      IconData icon,
      IconData? suffixicon,
      TextCapitalization type,
      TextEditingController controller,
      bool obscure,
      Function(String) onChanged,
      Function onTap) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade400),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 150),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: screenWidth / 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                controller: controller,
                onChanged: (value) {
                  onChanged(value);
                },
                enableSuggestions: true,
                autofocus: true,
                autocorrect: false,
                textCapitalization: type,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight / 50,
                      horizontal: screenHeight / 50),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth / 32,
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

// Interactive Feature Row
  Widget _buildInteractiveFeatureRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildFeatureBox(
              icon: IconlyLight.chat,
              label: 'Social Posts',
              gradientColors: [Colors.blue, Colors.blueAccent],
              onTap: () => print('Social Posts tapped'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: _buildFeatureBox(
              icon: IconlyLight.calendar,
              label: 'Events',
              gradientColors: [Colors.purple, Colors.pink],
              onTap: () => print('Events tapped'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: _buildFeatureBox(
              icon: IconlyBroken.tick_square,
              label: 'Camplist',
              gradientColors: [Colors.green, Colors.teal],
              onTap: () => print('Camplist tapped'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: _buildFeatureBox(
              icon: IconlyLight.camera,
              label: 'Camplist',
              gradientColors: [Colors.red, Colors.orange],
              onTap: () => print('Camplist tapped'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: 100.0,
        height: 70.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          // boxShadow: [
          //   BoxShadow(
          //     color: gradientColors.last.withOpacity(0.5),
          //     blurRadius: 10.0,
          //     offset: Offset(0, 5),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40.0),
            // SizedBox(height: 8.0),
            // Text(
            //   label,
            //   style: Theme.of(context).textTheme.titleSmall,
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}
