// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/bids.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaySetUpScreen extends StatefulWidget {
  final String mainTitle;
  final String mainSection;
  final String playType;
  final int playId;

  const PlaySetUpScreen(
      {Key? key,
      required this.mainTitle,
      required this.mainSection,
      required this.playType,
      required this.playId})
      : super(key: key);

  @override
  State<PlaySetUpScreen> createState() => _PlaySetUpScreenState();
}

class _PlaySetUpScreenState extends State<PlaySetUpScreen> {
  TextEditingController openPanaController = TextEditingController();
  TextEditingController closePanaController = TextEditingController();
  TextEditingController digitController = TextEditingController();
  TextEditingController pointController = TextEditingController();

  // Late variables
  // late List<String> digitList;
  late SharedPreferences sharedPreferences;

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int minCharacterLimit = 0;
  int newCharacterLimit = 1;

  String trackid = '';

  Color primary = Colors.blue.shade300;
  bool pass = true;
  bool pinpass = true;
  bool circular = false;

  // Session
  String select0 = 'Choose Session';

  List<String> sessList = [
    'Choose Session',
    'Open',
    'Close',
  ];

  // Functions
  String formatDate(DateTime date) {
    // Format the date as "EEEE" to get the day of the week (e.g., "Monday")
    String dayOfWeek = DateFormat('EEEE').format(date);
    // Format the date as "yyyy-MM-dd" (e.g., "2024-04-27")
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Combine the day of the week and the formatted date
    return '$dayOfWeek - $formattedDate';
  }

  // Check for character limit per play group
  void checkCharacterLimit() {
    if (widget.playId == 0) {
      minCharacterLimit = 1;
    } else if (widget.playId == 1) {
      minCharacterLimit = 2;
    } else if (widget.playId == 2 ||
        widget.playId == 3 ||
        widget.playId == 4 ||
        widget.playId == 5 ||
        widget.playId == 6) {
      minCharacterLimit = 3;
    }
  }

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
  void initState() {
    super.initState();
    checkCharacterLimit();
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    trackid = genUniqueCode(7);

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
                widget.mainTitle,
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
                  customField(formatDate(now), Icons.calendar_today, null, null,
                      false, true, null),
                  customField(widget.playType, RpgAwesome.perspective_dice_one,
                      null, null, false, true, null),
                  // Show to 1, 5 and 6
                  widget.playId == 1 || widget.playId == 5 || widget.playId == 6
                      ? const Center()
                      : customSelect(context, sessList, select0, (String sel) {
                          setState(() {
                            select0 = sel;
                          });
                        }),
                  // Show to 0 - 5
                  widget.playId == 0 ||
                          widget.playId == 1 ||
                          widget.playId == 2 ||
                          widget.playId == 3 ||
                          widget.playId == 4 ||
                          widget.playId == 5
                      ? customField(
                          'Enter Digit',
                          null,
                          null,
                          digitController,
                          false,
                          false,
                          (value) {
                            if (widget.playId != 5) {
                              if (value.length > minCharacterLimit) {
                                setState(() {
                                  digitController.clear();
                                });
                                final snackBar = SnackBar(
                                  content: Text(
                                    'Error: Input must be at least $minCharacterLimit characters',
                                    style: TextStyle(
                                      fontFamily: 'Nexa Bold',
                                      fontSize: screenWidth / 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue.shade300,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            } else {
                              if (value.length > newCharacterLimit) {
                                setState(() {
                                  digitController.clear();
                                });
                                final snackBar = SnackBar(
                                  content: Text(
                                    'Error: Input must be at least $newCharacterLimit characters',
                                    style: TextStyle(
                                      fontFamily: 'Nexa Bold',
                                      fontSize: screenWidth / 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue.shade300,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          },
                        )
                      : const Center(),
                  // Show to 6
                  widget.playId == 6
                      ? customField(
                          'Open Pana',
                          null,
                          null,
                          openPanaController,
                          false,
                          false,
                          (value) {
                            if (value.length > minCharacterLimit) {
                              setState(() {
                                openPanaController.clear();
                              });
                              final snackBar = SnackBar(
                                content: Text(
                                  'Error: Input must be at least $minCharacterLimit characters',
                                  style: TextStyle(
                                    fontFamily: 'Nexa Bold',
                                    fontSize: screenWidth / 25,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade300,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                        )
                      : const Center(),
                  // Show to 5 - 6
                  widget.playId == 5 || widget.playId == 6
                      ? customField(
                          'Close Pana',
                          null,
                          null,
                          closePanaController,
                          false,
                          false,
                          (value) {
                            if (value.length > minCharacterLimit) {
                              setState(() {
                                closePanaController.clear();
                              });
                              final snackBar = SnackBar(
                                content: Text(
                                  'Error: Input must be at least $minCharacterLimit characters',
                                  style: TextStyle(
                                    fontFamily: 'Nexa Bold',
                                    fontSize: screenWidth / 25,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade300,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                        )
                      : const Center(),
                  // Show to all
                  customField('Enter Point', null, null, pointController, false,
                      false, (value) {}),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      if (double.parse(pointController.text.trim()) < 10 ||
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
                      } else if (widget.playId != 1 &&
                          widget.playId != 5 &&
                          widget.playId != 6 &&
                          select0 == 'Choose Session') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Pick a session and try again!',
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
                      } else {
                        // get the current mobileid
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection('Users')
                            .where('id', isEqualTo: taskData.id)
                            .get();
                        // Variables
                        int digit = digitController.text.trim() == ''
                            ? 0
                            : int.parse(digitController.text.trim());
                        int oPana = openPanaController.text.trim() == ''
                            ? 0
                            : int.parse(openPanaController.text.trim());
                        int cPana = closePanaController.text.trim() == ''
                            ? 0
                            : int.parse(closePanaController.text.trim());
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
                              .collection('Bids')
                              .doc()
                              .set({
                            'id': taskData.id,
                            'market': widget.mainTitle,
                            'mrktype': widget.playType,
                            'mrksection': widget.mainSection,
                            'session':
                                select0 == 'Choose Session' ? '' : select0,
                            'digit': digit,
                            'openpana': oPana,
                            'closepana': cPana,
                            'points': double.parse(pointController.text.trim()),
                            'status': 'Booked',
                            'created': DateTime.now(),
                            'trackid': trackid,
                          }).then(
                            (_) {
                              alertDialog(
                                  context,
                                  'Bid Successful',
                                  'Total Stake',
                                  pointController.text.trim(),
                                  trackid, () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const BidsScreen(),
                                    type: PageTransitionType.topToBottom,
                                    inheritTheme: true,
                                    ctx: context,
                                  ),
                                );
                              });

                              setState(() {
                                circular = false;
                              });
                            },
                          );
                        } catch (e) {
                          e.toString();
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
                                'Play',
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
