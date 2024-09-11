// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String verifyId;
  final int id;
  final int mpin;
  final String name;
  final String pass;
  final double points;
  const PhoneOtpScreen({
    Key? key,
    required this.verifyId,
    required this.id,
    required this.mpin,
    required this.name,
    required this.pass,
    required this.points,
  }) : super(key: key);

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  TextEditingController otpController = TextEditingController();

  // Late variables

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool circular = false;
  String _otp = '';

  Color primary = Colors.blue.shade300;

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                'Verify Number!',
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
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customField('Enter OTP', null, null, otpController, false,
                      false, false, (String otp) {
                    setState(() {
                      _otp = otp;
                    });
                  }),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      if (_otp == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Enter the valid otp and try again!',
                              style: TextStyle(
                                fontFamily: 'Nexa Light',
                                fontSize: screenWidth / 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        // Stop rolling
                        setState(() {
                          circular = false;
                        });
                      } else {
                        try {
                          final cred = PhoneAuthProvider.credential(
                              verificationId: widget.verifyId,
                              smsCode: otpController.text);

                          await FirebaseAuth.instance
                              .signInWithCredential(cred)
                              .then((_) async {
                            await FirebaseFirestore.instance
                                .collection('Users')
                                .doc()
                                .set({
                              'acctholder': '',
                              'acctno': 0,
                              'bank': '',
                              'created': DateTime.now(),
                              'googlepay': 0,
                              'gpay': 0,
                              'id': widget.id,
                              'ifsc': 0,
                              'mpin': widget.mpin,
                              'name': widget.name,
                              'pass': widget.pass,
                              'paytm': 0,
                              'phonepe': 0,
                              'points': widget.points,
                              // 'verified': false,
                            }).then((_) {
                              taskData.saveLogs(widget.id, widget.name,
                                  widget.points, taskData.mpin);
                            }).then((_) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                  child: const MainScreen(),
                                  type: PageTransitionType.leftToRight,
                                  duration: const Duration(milliseconds: 500),
                                  reverseDuration:
                                      const Duration(milliseconds: 500),
                                ),
                                (_) => false,
                              );
                            });
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.blue.shade300,
                              content: Text(
                                e.toString(),
                                style: TextStyle(
                                  fontFamily: 'Nexa Light',
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
                    },
                    child: Container(
                      height: 60,
                      width: screenWidth,
                      margin: EdgeInsets.only(top: screenHeight / 40),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Center(
                        child: circular
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator(
                                    color: Colors.white))
                            : Text(
                                'SUBMIT',
                                style: TextStyle(
                                    fontFamily: 'Nexa Bold',
                                    fontSize: screenWidth / 26,
                                    color: Colors.white,
                                    letterSpacing: 2),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 50,
                  ),
                ],
              ),
            )
          ],
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
              fontFamily: 'Nexa Bold',
              color: Colors.blue.shade300),
        ),
      ),
    );
  }

  Widget customField(
      String hint,
      IconData? icon,
      IconData? suffixicon,
      TextEditingController? controller,
      bool obscure,
      bool readOnly,
      numbersOnly,
      Function(String)? onChanged) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ]),
      child: Row(
        children: [
          readOnly
              ? SizedBox(
                  width: screenWidth / 6,
                  child: Icon(
                    icon,
                    color: primary,
                    size: screenWidth / 15,
                  ),
                )
              : SizedBox(
                  width: screenWidth / 10,
                ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 30),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Nexa Light',
                    fontSize: screenWidth / 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                readOnly: readOnly,
                // maxLength: 2,
                keyboardType: numbersOnly ? TextInputType.number : null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: readOnly ? screenHeight / 35 : screenHeight / 50,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: readOnly
                      ? TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)
                      : null,
                  // suffixIcon: GestureDetector(
                  //   onTap: () {
                  //     onTap();
                  //   },
                  //   child: Icon(
                  //     suffixicon,
                  //     color: Colors.grey.shade600,
                  //     size: screenWidth / 15,
                  //   ),
                  // ),
                ),
                maxLines: 1,
                obscureText: obscure,
                onChanged: (newChange) {
                  onChanged!(newChange);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget customSelect(BuildContext context, List<String>? items,
      String valueAll, Function(String) onChanged) {
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            )
          ]),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth / 10,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 30),
              child: DropdownButton<String>(
                dropdownColor: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
                hint: Text(
                  valueAll,
                  style: TextStyle(
                      fontFamily: 'Nexa Light',
                      fontSize: screenWidth / 21,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                value: valueAll,
                isExpanded: true,
                underline: Container(),
                onChanged: (newCat) {
                  onChanged(newCat!);
                },
                items: items!.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(
                            fontFamily: 'Nexa Light',
                            fontSize: screenWidth / 21,
                            // fontWeight: FontWeight.bold,
                            color: value != valueAll
                                ? Colors.black
                                : Colors.blue.shade800)),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
