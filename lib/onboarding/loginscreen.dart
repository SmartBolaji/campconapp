import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/fgt_pass.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/onboarding/signupscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              SizedBox(
                height: screenHeight / 5.4,
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
                        )),
                    Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(horizontal: screenWidth / 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // fieldTitle('Mobile Number'),
                            customField(
                              'EMAIL, OR USERNAME',
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
                                'PASSWORD',
                                Icons.password,
                                pass ? Icons.visibility_off : Icons.visibility,
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
                                // fieldTitle('Password'),
                                fgtPass('Forget Password?', onTap: () {
                                  // Navigate to next screen or home screen
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
                                  // Navigator.push(
                                  //   context,
                                  //   PageTransition(
                                  //     child: const ForgetPassScreen(),
                                  //     type: PageTransitionType.leftToRight,
                                  //     duration:
                                  //         const Duration(milliseconds: 500),
                                  //     reverseDuration:
                                  //         const Duration(milliseconds: 500),
                                  //   ),
                                  // );
                                })
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                actionButton(context, taskData,
                                    magHeight: screenHeight / 40,
                                    bgColor: Colors.grey.shade400,
                                    bdColor: Colors.grey.shade400,
                                    txtColor: Colors.grey.shade700,
                                    txt: 'LOGIN', onTap: () async {
                                  // Keypad closes
                                  FocusScope.of(context).unfocus();

                                  // Start rolling
                                  setState(() {
                                    circular = true;
                                  });

                                  if (_id == 0 && _password == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                Colors.blue.shade300,
                                            content: Text(
                                              'Enter a valid number and password and try again!',
                                              style: TextStyle(
                                                fontFamily: 'Nexa Light',
                                                fontSize: screenWidth / 30,
                                                color: Colors.white,
                                              ),
                                            )));
                                    // Stop rolling
                                    setState(() {
                                      circular = false;
                                    });
                                  } else if (_id == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                Colors.blue.shade300,
                                            content: Text(
                                              'Mobile number is empty, try again!',
                                              style: TextStyle(
                                                fontFamily: 'Nexa Light',
                                                fontSize: screenWidth / 30,
                                                color: Colors.white,
                                              ),
                                            )));
                                    // Stop rolling
                                    setState(() {
                                      circular = false;
                                    });
                                  } else if (_password == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                Colors.blue.shade300,
                                            content: Text(
                                              'Password is empty, make changes and try again!',
                                              style: TextStyle(
                                                fontFamily: 'Nexa Light',
                                                fontSize: screenWidth / 30,
                                                color: Colors.white,
                                              ),
                                            )));
                                    // Stop rolling
                                    setState(() {
                                      circular = false;
                                    });
                                  } else {
                                    try {
                                      QuerySnapshot snap =
                                          await FirebaseFirestore.instance
                                              .collection('Users')
                                              .where('id', isEqualTo: _id)
                                              .get();

                                      // Variables
                                      String name = snap.docs[0]['name'];
                                      double pts = snap.docs[0]['points'];
                                      int mpin = snap.docs[0]['mpin'];

                                      if (snap.docs[0].exists &&
                                          _password == snap.docs[0]['pass']) {
                                        taskData.saveLogs(_id, name, pts, mpin);
                                        Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                            child: const MainScreen(),
                                            type:
                                                PageTransitionType.rightToLeft,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            reverseDuration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                backgroundColor:
                                                    Colors.blue.shade300,
                                                content: Text(
                                                  'Password is not correct!',
                                                  style: TextStyle(
                                                    fontFamily: 'Nexa Light',
                                                    fontSize: screenWidth / 30,
                                                    color: Colors.white,
                                                  ),
                                                )));
                                      }
                                    } catch (e) {
                                      print(e.toString());
                                      String error = '';

                                      if (e.toString() ==
                                          'RangeError (index): Invalid value: Valid value range is empty: 0') {
                                        setState(() {
                                          error =
                                              'Invalid account, does not exist!';
                                        });
                                      } else {
                                        setState(() {
                                          error = 'Error occurred!';
                                        });
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              backgroundColor:
                                                  Colors.blue.shade300,
                                              content: Text(
                                                error,
                                                style: TextStyle(
                                                  fontFamily: 'Trebuchet',
                                                  fontSize: screenWidth / 30,
                                                  color: Colors.white,
                                                ),
                                              )));
                                    }
                                    // Stop rolling
                                    setState(() {
                                      circular = false;
                                    });
                                  }
                                }),
                                const SizedBox(
                                  width: 5,
                                ),
                                actionButton(
                                  context,
                                  taskData,
                                  magHeight: screenHeight / 100,
                                  bgColor: Colors.grey.shade800,
                                  bdColor: Colors.grey.shade800,
                                  txtColor: Colors.white,
                                  txt: 'SIGNUP',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: const SignUpScreen(),
                                        type: PageTransitionType.rightToLeft,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        reverseDuration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
              color: Color(0xFFBA9E02)),
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
              padding: EdgeInsets.only(right: screenWidth / 150),
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
