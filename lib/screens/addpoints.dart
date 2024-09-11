import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPointsScreen extends StatefulWidget {
  const AddPointsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddPointsScreen> createState() => _AddPointsScreenState();
}

class _AddPointsScreenState extends State<AddPointsScreen> {
  TextEditingController pointController = TextEditingController();

  // Late variables
  // late List<String> digitList;
  late SharedPreferences sharedPreferences;

  // Get the current date
  DateTime now = DateTime.now();

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  Color primary = Colors.blue.shade300;

  // Session
  String select0 = 'Payment Method';

  List<String> payList = [
    'Payment Method',
    'Google Pay',
    'Phone Pe',
    'PayTm',
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   checkCharacterLimit();
  // }

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
                'Add Fund',
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
                  customField('Minimum Deposit is 500', IconlyBold.message,
                      null, null, false, true, null),
                  customSelect(context, payList, select0, (String sel) {
                    setState(() {
                      select0 = sel;
                      print('Result: $select0');
                    });
                  }),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      String id = pointController.text.trim();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.blue.shade300,
                          content: Text(
                            'Unavailable, try again later!',
                            style: TextStyle(
                              fontFamily: 'Nexa Light',
                              fontSize: screenWidth / 30,
                              color: Colors.white,
                            ),
                          )));
                      // if (id.isEmpty) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //           content: Text('Employee id is empty!')));
                      // } else if (password.isEmpty) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //           content: Text('Password is empty!')));
                      // } else {
                      //   QuerySnapshot snap = await FirebaseFirestore.instance
                      //       .collection('Employee')
                      //       .where('id', isEqualTo: id)
                      //       .get();

                      //   try {
                      //     if (password == snap.docs[0]['password']) {
                      //       User.employeeid = id;

                      //       sharedPreferences =
                      //           await SharedPreferences.getInstance();

                      //       sharedPreferences
                      //           .setString('employeeid', id)
                      //           .then((_) {
                      //         Navigator.pushReplacement(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) =>
                      //                      const MainScreen()));
                      //       });
                      //     } else {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //           const SnackBar(
                      //               content: Text('Password is not correct!')));
                      //     }
                      //   } catch (e) {
                      //     String error = '';

                      //     if (e.toString() ==
                      //         'RangeError (index): Invalid value: Valid value range is empty: 0') {
                      //       setState(() {
                      //         error = 'Employee id does not exist!';
                      //       });
                      //     } else {
                      //       setState(() {
                      //         error = 'Error occurred!';
                      //       });
                      //     }
                      //     ScaffoldMessenger.of(context)
                      //         .showSnackBar(SnackBar(content: Text(error)));
                      //   }
                      // }
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
                        child: Text(
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
