import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/mainscreen.dart';
import 'package:campcon/screens/chg_pass.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    double screenHeight = 0.0;
    double screenWidth = 0.0;

    Color primary = Colors.blue.shade300;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                child: MainScreen(),
                type: PageTransitionType.topToBottom,
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 500),
              ),
            );
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
                'Profile',
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
            customField(screenWidth, screenHeight, taskData.name,
                Icons.account_circle, null, null, false, true, null),
            customField(screenWidth, screenHeight, taskData.id.toString(),
                Icons.phone_rounded, null, null, false, true, null),
            onTapButton(screenWidth, screenHeight, 'Change Password',
                Colors.grey.shade800, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChgPassScreen()));
            }),
            onTapButton(screenWidth, screenHeight, 'Logout', Colors.red, () {})
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
}
