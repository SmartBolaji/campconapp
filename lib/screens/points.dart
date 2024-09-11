import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:campcon/screens/addpoints.dart';
import 'package:campcon/screens/transact.dart';
import 'package:campcon/screens/wthpoints.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    double screenHeight = 0.0;
    double screenWidth = 0.0;

    // Color primary = Colors.blue.shade300;
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
                'Wallet',
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
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
          top: 15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // customField(screenWidth, screenHeight, taskData.name,
            //     Icons.account_circle, null, null, false, true, null),
            customField(
                screenWidth,
                screenHeight,
                taskData.points.toString(),
                IconlyBold.wallet,
                Icons.refresh_outlined,
                null,
                false,
                true,
                null, () async {
              // get the current mobileid
              QuerySnapshot snap = await FirebaseFirestore.instance
                  .collection('Users')
                  .where('id', isEqualTo: taskData.id)
                  .get();

              // Retreive the point value and assign the value
              double pts = snap.docs[0]['points'];

              // Update the local storage
              taskData.savePts(pts);

              // Alert
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
            }),
            onTapButton(
                screenWidth, screenHeight, 'Add Fund', Colors.grey.shade800,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPointsScreen()));
            }),
            onTapButton(
                screenWidth, screenHeight, 'Withdraw', Colors.grey.shade800,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WthPointsScreen()));
            }),
            onTapButton(
                screenWidth, screenHeight, 'Transaction', Colors.grey.shade800,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TransactScreen()));
            }),
          ],
        ),
      ),
    );
  }

  GestureDetector onTapButton(double screenWidth, double screenHeight,
      String mainText, Color color, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 60,
        width: screenWidth,
        margin: EdgeInsets.only(top: screenHeight / 60),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Center(
          child: Text(
            mainText,
            style: TextStyle(
                fontFamily: 'Nexa Bold',
                fontSize: screenWidth / 28,
                color: Colors.white,
                letterSpacing: 2),
          ),
        ),
      ),
    );
  }

  Widget customField(
      double screenWidth,
      double screenHeight,
      String hint,
      IconData? icon,
      IconData? suffixicon,
      TextEditingController? controller,
      bool obscure,
      bool readOnly,
      Function(String)? onChanged,
      Function onTap) {
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
                    color: Colors.blue.shade300,
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
                  suffixIcon: GestureDetector(
                    onTap: () {
                      onTap();
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
}
