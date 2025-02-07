import 'dart:async';
import 'dart:math';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/onboarding/suggestions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({Key? key}) : super(key: key);

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  late List<String> suggestedUsernames;
  QuerySnapshot? _snap;
  int _snapCount = 0;
  // Init the auth package
  final firebase_auth.FirebaseAuth firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final TextEditingController idController = TextEditingController();

  // When you want to set the initial text
  void setInitialText(String name) {
    final randomNum = "${idG.generate(1000)}";
    idController.text = '$name$randomNum'; // Combine name with random number
  }

  // Assuming taskData.name is available in your provider
  @override
  void initState() {
    super.initState();
    final name = Provider.of<TaskData>(context, listen: false).name;
    suggestedUsernames = generateUsernames(name);
    setInitialText(
        name.replaceAll(' ', '')); // Set the combined text as initial text
  }

  // Function to handle username selection
  void _onUsernameSelected(String username) {
    idController.text = username;
    _onUsernameChanged(username); // Update with the selected username
  }

  Timer? _debounce;
  bool _isUsernameAvailable = true;

  @override
  void dispose() {
    idController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Function to generate random usernames
  List<String> generateUsernames(String baseName) {
    final random = Random();
    final nameParts = baseName.split(' '); // Split the base name into parts

    return List.generate(3, (index) {
      // Shuffle name parts
      nameParts.shuffle(random);
      // Combine the shuffled parts with a random number
      return '${nameParts.join('')}${random.nextInt(900) + 100}';
    });
  }

  void _onUsernameChanged(String username) {
    // Cancel the previous debounce timer
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (username.isNotEmpty) {
        bool available = await _checkUsernameAvailability(username);
        setState(() {
          _isUsernameAvailable = available;
        });
      } else {
        setState(() {
          _isUsernameAvailable = false;
        });
      }
    });
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('userCheck',
            isEqualTo: username.toLowerCase()) // Case-insensitive check
        .get();

    return result.docs.isEmpty; // Username is available if no document found
  }

  // Method to load suggestions
  Future<void> loadData(
      {required List<String> newTags, required String uid}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: uid)
          .where('tags', arrayContainsAny: newTags)
          .orderBy(
              'typeOrder') // Order the documents by typeOrder (1 = Official, 2 = Business, 3 = Individual)
          .limit(10)
          .get();

      // If no documents are found in Firestore, try loading from cache
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isNotEqualTo: uid)
            .where('tags', arrayContainsAny: newTags)
            .orderBy(
                'typeOrder') // Order the documents by typeOrder (1 = Official, 2 = Business, 3 = Individual)
            .limit(10)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }

      // Set the snap count, limited to a maximum of 30
      setState(() {
        _snapCount = (_snap?.size ?? 0) > 30 ? 30 : _snap?.size ?? 0;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = const Color(0xFF2c2221);
  late SharedPreferences sharedPreferences;

  // String _id = '';
  String _warn = 'This username is not available. Please try another!';

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
                  value: 1, // Current progress
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
                            'Pick a unique username!',
                            style: TextStyle(
                                fontFamily: 'Lato',
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
                        margin:
                            EdgeInsets.symmetric(horizontal: screenWidth / 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customField(
                              'username',
                              Icons.alternate_email,
                              _isUsernameAvailable ? Icons.check : Icons.close,
                              _isUsernameAvailable
                                  ? Colors.green.shade800
                                  : Colors.red,
                              idController,
                              false,
                              _onUsernameChanged,
                              () {},
                            ),
                            // show warning in text
                            // if (!_isUsernameAvailable &&
                            //     idController.text.isNotEmpty)
                            //   Column(
                            //     children: [
                            //       Text(
                            //         _warn,
                            //         style: TextStyle(
                            //             fontFamily: 'Trebuchet',
                            //             fontSize: screenWidth / 30,
                            //             color: Colors.grey.shade900,
                            //             letterSpacing: 0),
                            //       ),
                            //       const SizedBox(
                            //         height: 5,
                            //       ),
                            //     ],
                            //   ),
                            // Display each generated username as tappable text
                            Wrap(
                              spacing: 8.0,
                              children: suggestedUsernames.map((username) {
                                return GestureDetector(
                                  onTap: () => _onUsernameSelected(username),
                                  child: Chip(
                                    label: Text(
                                      '@$username',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize: screenWidth / 30,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                );
                              }).toList(),
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
                                    taskData.circular,
                                    magHeight: screenHeight / 100,
                                    bgColor: !_isUsernameAvailable
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade800,
                                    bdColor: !_isUsernameAvailable
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade800,
                                    txtColor: Colors.white,
                                    txt: 'SIGNUP',
                                    onTap: !_isUsernameAvailable &&
                                            idController.text.isNotEmpty
                                        ? () {}
                                        : () async {
                                            // Keypad closes
                                            FocusScope.of(context).unfocus();

                                            // start rolling
                                            taskData.updateCircle(
                                                context, true);

                                            try {
                                              // Convert the email to remove the space
                                              String idInput =
                                                  idController.text.trim();

                                              // Convert the email to lowercase for a case-insensitive query
                                              String idInputCheck = idController
                                                  .text
                                                  .trim()
                                                  .toLowerCase();

                                              QuerySnapshot snap =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .where('userCheck',
                                                          isEqualTo:
                                                              idInputCheck)
                                                      .get();

                                              // most of these checks are unimportant, as we already set measures
                                              if (snap.docs.isNotEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        Colors.grey.shade800,
                                                    content: Text(
                                                      'This username already exists in our record, use a different email and try again!',
                                                      style: TextStyle(
                                                        fontFamily: 'Lato',
                                                        fontSize:
                                                            screenWidth / 28,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                                // stop rolling
                                                taskData.updateCircle(
                                                    context, false);
                                              } else {
                                                // assign variable
                                                DateTime now = DateTime.now();
                                                String uid =
                                                    'ab${now.millisecondsSinceEpoch}';

                                                // Save the values
                                                taskData.updateSign(
                                                  context,
                                                  uid,
                                                  taskData.name,
                                                  idInput,
                                                  taskData.email,
                                                  taskData.pass,
                                                );

                                                // variables
                                                List<String> tags = [
                                                  taskData.sch.toLowerCase(),
                                                  taskData.level.toLowerCase(),
                                                  taskData.faculty
                                                      .toLowerCase(),
                                                  taskData.dept.toLowerCase(),
                                                  taskData.loc.toLowerCase(),
                                                  'campcon'
                                                ];

                                                List<String> coverImg = [];

                                                // save tags
                                                taskData.updateTags(
                                                    context, tags);

                                                // fetch the _snap data using function
                                                await loadData(
                                                    newTags: tags, uid: uid);

                                                try {
                                                  // Create a new account using user's email and password
                                                  // firebase_auth.UserCredential
                                                  //     userCredential =
                                                  await firebaseAuth
                                                      .createUserWithEmailAndPassword(
                                                          email: taskData.email,
                                                          password:
                                                              taskData.pass);

                                                  // Save the username
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(uid)
                                                      .set({
                                                    'uid': uid,
                                                    'name': taskData.name,
                                                    'bio': '',
                                                    'location': '',
                                                    'url': '',
                                                    'email': taskData.email,
                                                    'sch': taskData.sch,
                                                    'level': taskData.level,
                                                    'faculty': taskData.faculty,
                                                    'dept': taskData.dept,
                                                    'hostel': taskData.loc,
                                                    'userId': idInput,
                                                    'userCheck': idInputCheck,
                                                    'tags': tags,
                                                    'coverImg': coverImg,
                                                    'profileImg': '',
                                                    'type':
                                                        'Individual', // "Official", "Business", or "Individual"
                                                    'typeOrder':
                                                        3, // 1 for "Official", 2 for "Business", 3 for "Individual"
                                                    'connects': 0,
                                                    'connecting': 0,
                                                    'createdAt': now,
                                                  });

                                                  if (_snap != null) {
                                                    // stop rolling
                                                    taskData.updateCircle(
                                                        context, false);
                                                  }

                                                  if (_snap != null) {
                                                    // navigate to suggestion page
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                      context,
                                                      PageTransition(
                                                        child: SuggestScreen(
                                                          snap: _snap,
                                                          currentSize:
                                                              _snapCount,
                                                        ),
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        reverseDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                      ),
                                                      (Route<dynamic> route) =>
                                                          false, // Removes all previous screens
                                                    );
                                                  }
                                                } on FirebaseAuthException catch (e) {
                                                  // stop rolling
                                                  taskData.updateCircle(
                                                      context, false);

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          Colors.grey.shade800,
                                                      content: Text(
                                                        'An error occurred: ${e.toString()}',
                                                        style: TextStyle(
                                                          fontFamily: 'Lato',
                                                          fontSize:
                                                              screenWidth / 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              taskData.updateCircle(
                                                  context, false);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.grey.shade800,
                                                  content: Text(
                                                    'An error occurred: ${e.toString()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Lato',
                                                      fontSize:
                                                          screenWidth / 30,
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
      Color? suffixColor,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              color: primary,
              size: screenWidth / 30,
            ),
            const SizedBox(
              width: 3,
            ),
            Expanded(
              child: TextFormField(
                style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                onChanged: (value) {
                  onChanged(value);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // Prevent spaces
                ],
                enableSuggestions: false,
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: InputBorder.none,
                  labelText: hint,
                  labelStyle: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                  suffix: GestureDetector(
                    onTap: () {
                      onTap();
                    },
                    child: CircleAvatar(
                      radius: screenWidth / 35,
                      backgroundColor: suffixColor,
                      child: Icon(
                        suffixicon,
                        color: Colors.white,
                        size: screenWidth / 30,
                      ),
                    ),
                  ),
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            )
          ],
        ),
      ),
    );
  }
}
