import 'package:campcon/services/task_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);
    // varibles
    Color primary = const Color(0xFF2c2221);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                  value: 0.15, // Current progress
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
                    // Container(
                    //   margin: EdgeInsets.symmetric(
                    //       horizontal: screenWidth / 12,
                    //       vertical: screenHeight / 60),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Flexible(
                    //         child: Text(
                    //           'Become a campster!',
                    //           style: TextStyle(
                    //               fontFamily: 'Trebuchet',
                    //               fontSize: screenWidth / 15,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.grey.shade600,
                    //               letterSpacing: 0),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Main Content
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth / 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          // Padding(
                          //   padding: EdgeInsets.only(bottom: screenHeight / 30),
                          //   child: Text(
                          //     'Are you a...',
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //       fontFamily: 'Trebuchet',
                          //       fontSize: screenWidth / 18,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.grey.shade800,
                          //     ),
                          //   ),
                          // ),
                          // Buttons
                          GestureDetector(
                            onTap: () {
                              // Navigate or perform action for student
                            },
                            child: RoleButton(
                              icon: Icons.school,
                              text: 'Student',
                              subText: 'For those enrolled in an institution.',
                              color: Colors.blueAccent.shade400,
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                            ),
                          ),
                          SizedBox(height: screenHeight / 50),
                          GestureDetector(
                            onTap: () {
                              // Navigate or perform action for non-student
                            },
                            child: RoleButton(
                              icon: Icons.business_center,
                              text: 'Non-Student',
                              subText:
                                  'For those not in an academic institution.',
                              color: Colors.orangeAccent.shade400,
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                  fontFamily: 'Trebuchet',
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
}

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subText;
  final Color color;
  final double screenHeight;
  final double screenWidth;

  const RoleButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.subText,
    required this.color,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenWidth / 40),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 1, color: Colors.grey.shade300)
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.shade300,
          //     offset: const Offset(0, 4),
          //     blurRadius: 10,
          //   ),
          // ],
          ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: screenWidth / 7,
            height: screenHeight / 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: screenWidth / 12,
            ),
          ),
          // Text and Subtext
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: screenWidth / 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: screenHeight / 100),
                  Text(
                    subText,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: screenWidth / 30,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
