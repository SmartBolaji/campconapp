import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddUpiScreen extends StatefulWidget {
  const AddUpiScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AddUpiScreen> createState() => _AddUpiScreenState();
}

class _AddUpiScreenState extends State<AddUpiScreen> {
  // Late variables
  late TextEditingController bankController;
  late TextEditingController achController;
  late TextEditingController acnController;
  late TextEditingController ifscController;
  late TextEditingController paytmController;
  late TextEditingController phonePeController;
  late TextEditingController gPayController;
  late SharedPreferences sharedPreferences;

  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool circular = false;
  Color primary = Colors.blue.shade300;
  // Get the current date
  DateTime now = DateTime.now();

  late Future<void> fetchDataFuture;

  @override
  void initState() {
    super.initState();
    bankController = TextEditingController();
    achController = TextEditingController();
    acnController = TextEditingController();
    ifscController = TextEditingController();
    paytmController = TextEditingController();
    phonePeController = TextEditingController();
    gPayController = TextEditingController();

    fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    final taskData = Provider.of<TaskData>(context, listen: false);
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: taskData.id)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        bankController.text = snap.docs[0]['bank'] ?? '';
        achController.text = snap.docs[0]['acctholder'] ?? '';
        acnController.text = snap.docs[0]['acctno'].toString();
        ifscController.text = snap.docs[0]['ifsc'].toString();
        paytmController.text = snap.docs[0]['paytm'].toString();
        phonePeController.text = snap.docs[0]['phonepe'].toString();
        gPayController.text = snap.docs[0]['gpay'].toString();
      });
    }
  }

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
                'Payment Details',
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
                  // Show to all
                  customField('Bank Name', null, null, bankController, false,
                      false, false, (value) {}),
                  customField('Account Holder Name', null, null, achController,
                      false, false, false, (value) {}),
                  customField('Account Number', null, null, acnController,
                      false, false, true, (value) {}),
                  customField('IFSC Code', null, null, ifscController, false,
                      false, true, (value) {}),
                  customField('PayTm Number', null, null, paytmController,
                      false, false, true, (value) {}),
                  customField('PhonePe Number', null, null, phonePeController,
                      false, false, true, (value) {}),
                  customField('Google Pay Number', null, null, gPayController,
                      false, false, true, (value) {}),
                  Container(
                    width: screenWidth,
                    padding: const EdgeInsets.all(15),
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
                    child: Text(
                      'Fill all the information carefully, we are not responsible for any mistake.',
                      style: TextStyle(
                          fontFamily: 'Nexa Bold',
                          fontSize: screenWidth / 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Keypad closes
                      FocusScope.of(context).unfocus();

                      setState(() {
                        circular = true;
                      });

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
                          'bank': bankController.text.trim(),
                          'acctholder': achController.text.trim(),
                          'acctno': acnController.text.trim() != ''
                              ? int.parse(acnController.text.trim())
                              : 0,
                          'ifsc': int.parse(ifscController.text.trim()),
                          'paytm': int.parse(paytmController.text.trim()),
                          'phonepe': int.parse(phonePeController.text.trim()),
                          'gpay': int.parse(gPayController.text.trim()),
                        }).then(
                          (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.blue.shade300,
                                content: Text(
                                  'Saved!',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.blue.shade300,
                            content: Text(
                              e.toString(),
                              style: TextStyle(
                                fontFamily: 'Nexa Light',
                                fontSize: screenWidth / 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
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
                                'Save',
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
      bool numbersOnly,
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
