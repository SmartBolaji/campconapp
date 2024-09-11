// ignore_for_file: use_build_context_synchronously
import 'dart:math';

import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:campcon/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WthPointsScreen extends StatefulWidget {
  const WthPointsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WthPointsScreen> createState() => _WthPointsScreenState();
}

class _WthPointsScreenState extends State<WthPointsScreen> {
  TextEditingController pointController = TextEditingController();
  TextEditingController mPinController = TextEditingController();

  // Late variables
  // late List<String> digitList;
  late SharedPreferences sharedPreferences;

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool circular = false;

  Color primary = Colors.blue.shade300;

  // Session
  String select0 = 'Payment Method';
  String txnid = '';

  List<String> payList = [
    'Payment Method',
    'Google Pay',
    'Phone Pe',
    'PayTm',
  ];

  // Create a unique txn id
  String genUniqueCode(int length) {
    final random = Random();
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; // Define the characters to use in the code
    final codeList = List.generate(
        length, (index) => characters[random.nextInt(characters.length)]);
    final code = codeList.join();
    return code;
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    txnid = genUniqueCode(11);

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
                'Withdraw',
                style: TextStyle(
                  fontFamily: 'Nexa Bold',
                  fontSize: screenWidth / 17,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const PointsScreen(),
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      IconlyBold.wallet,
                      size: screenWidth / 15,
                      color: Colors.blue.shade50,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(taskData.points.toString(),
                        style: TextStyle(
                            fontFamily: 'Nexa Bold',
                            fontSize: screenWidth / 22,
                            color: Colors.white)),
                  ],
                ),
              )
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
                  // Show to all
                  customField('Enter Point', null, null, pointController, false,
                      false, (value) {}),
                  customField('Minimum Withdraw is 1000', IconlyBold.message,
                      null, null, false, true, null),
                  customSelect(context, payList, select0, (String sel) {
                    setState(() {
                      select0 = sel;
                    });
                  }),
                  // customField('MPin', null, null, mPinController, true, false,
                  //     (value) {}),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      if (pointController.text.isEmpty ||
                          double.parse(pointController.text.trim()) < 1000 ||
                          double.parse(pointController.text.trim()) >
                              taskData.points) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Invalid point value, make change and try again!',
                              style: TextStyle(
                                fontFamily: 'Nexa Light',
                                fontSize: screenWidth / 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        setState(() {
                          circular = false;
                        });
                      }

                      // else if (taskData.mpin !=
                      //     int.parse(mPinController.text.trim())) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       backgroundColor: Colors.blue.shade300,
                      //       content: Text(
                      //         'Wrong mpin, try again!',
                      //         style: TextStyle(
                      //           fontFamily: 'Nexa Light',
                      //           fontSize: screenWidth / 30,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      //   setState(() {
                      //     circular = false;
                      //   });
                      // }

                      else {
                        // get the current mobileid
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection('Users')
                            .where('id', isEqualTo: taskData.id)
                            .get();

                        // Retreive the point value and deduct the bid point
                        double pts = snap.docs[0]['points'] -
                            double.parse(pointController.text.trim());

                        // Set a new point value
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(snap.docs[0].id)
                            .update({
                          'points': pts,
                        }).then((_) {
                          taskData.savePts(pts);
                        });

                        try {
                          await FirebaseFirestore.instance
                              .collection('Transactions')
                              .doc()
                              .set({
                            'id': taskData.id,
                            'points': double.parse(pointController.text.trim()),
                            'type': 'Withdrawal',
                            'method': select0,
                            'status': 'Pending',
                            'created': DateTime.now(),
                            'txnid': txnid,
                          }).then(
                            (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.blue.shade300,
                                  content: Text(
                                    'Withdrawal processing!',
                                    style: TextStyle(
                                      fontFamily: 'Nexa Light',
                                      fontSize: screenWidth / 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              setState(() {
                                circular = false;
                              });
                            },
                          );
                        } catch (e) {
                          // print(e.toString());
                        }
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
                keyboardType: TextInputType.number,
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
