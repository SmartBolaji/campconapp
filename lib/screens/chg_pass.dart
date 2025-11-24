
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChgPassScreen extends StatefulWidget {
  const ChgPassScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ChgPassScreen> createState() => _ChgPassScreenState();
}

class _ChgPassScreenState extends State<ChgPassScreen> {
  TextEditingController newPassController = TextEditingController();
  TextEditingController mPinController = TextEditingController();

  // Late variables
  // late List<String> digitList;
  late SharedPreferences sharedPreferences;

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool pass = true;
  bool mpass = true;
  bool circular = false;
  // Valid variables
  String _password = '';
  int _mPin = 0;

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
                'Change Password',
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
                  customField(
                      'Enter New Password',
                      null,
                      pass ? Icons.visibility_off : Icons.visibility,
                      newPassController,
                      pass,
                      false,
                      false, (value) {
                    setState(() {
                      _password = value;
                    });
                  }, () {
                    setState(() {
                      pass = !pass;
                    });
                  }),
                  customField(
                      'MPin',
                      null,
                      mpass ? Icons.visibility_off : Icons.visibility,
                      mPinController,
                      mpass,
                      false,
                      true, (value) {
                    setState(() {
                      _mPin = int.parse(value);
                    });
                  }, () {
                    setState(() {
                      mpass = !mpass;
                    });
                  }),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

                      if (newPassController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'New password can not be empty!',
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
                      } else if (taskData.mpin !=
                          int.parse(mPinController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              'Wrong mpin, try again!',
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

                        try {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(snap.docs[0].id)
                              .update({
                            'pass': newPassController.text.toString(),
                          }).then(
                            (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.blue.shade300,
                                  content: Text(
                                    'Success!',
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
      numbersOnly,
      Function(String)? onChanged,
      Function? onTap) {
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
                  suffixIcon: GestureDetector(
                    onTap: () {
                      onTap!();
                    },
                    child: Icon(
                      suffixicon,
                      color: Colors.grey.shade600,
                      size: screenWidth / 15,
                    ),
                  ),
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
