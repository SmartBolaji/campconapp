import 'package:campcon/model/vars.dart';
import 'package:campcon/onboarding/namescreen.dart';
import 'package:campcon/services/task_data.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchScreen extends StatefulWidget {
  const SchScreen({Key? key}) : super(key: key);

  @override
  State<SchScreen> createState() => _SchScreenState();
}

class _SchScreenState extends State<SchScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool circular = false;
  Color primary = const Color(0xFF2c2221);
  late SharedPreferences sharedPreferences;

  String? _sch;
  String? _level;
  String? _loc;
  String? _selectedDepartment;
  String? _selectedFaculty;

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
              Padding(
                padding: EdgeInsets.only(
                    top: screenHeight / 30, bottom: 20, right: 20, left: 20),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(20),
                  value: 0.75, // Current progress
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
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth / 12,
                          vertical: screenHeight / 60),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'We want to know you and help you!',
                              style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: screenWidth / 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        margin:
                            EdgeInsets.symmetric(horizontal: screenWidth / 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            customDropdown(
                              screenWidth: screenWidth,
                              hintText: 'SELECT SCHOOL',
                              selectedValue: _sch,
                              items: UsableData().schoolList,
                              onChanged: (value) {
                                setState(() {
                                  _sch = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            customMapDropdown(
                              screenWidth: screenWidth,
                              hintText: 'SELECT DEPARTMENT',
                              selectedValue: _selectedDepartment,
                              items: UsableData()
                                  .departments, // Pass the list of maps with department and faculty
                              onChanged: (String? department, String? faculty) {
                                setState(() {
                                  _selectedDepartment = department;
                                  _selectedFaculty = faculty;
                                });
                                // Now you can save selectedFaculty to Firestore if needed
                                print(
                                    "Selected Department: $_selectedDepartment, Faculty: $_selectedFaculty");
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            customDropdown(
                              screenWidth: screenWidth,
                              hintText: 'SELECT LEVEL',
                              selectedValue: _level,
                              items: UsableData().levelList,
                              onChanged: (value) {
                                setState(() {
                                  _level = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            customDropdown(
                              screenWidth: screenWidth,
                              hintText: 'SELECT LOCATION',
                              selectedValue: _loc,
                              items: UsableData().loclist,
                              onChanged: (value) {
                                setState(() {
                                  _loc = value;
                                });
                              },
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
                                    txt: 'SKIP', onTap: () async {
                                  // Skip this setup
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: const UsernameScreen(),
                                      type: PageTransitionType.rightToLeft,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      reverseDuration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
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
                                  txt: 'NEXT',
                                  onTap: () {
                                    // save locally
                                    taskData.updateSchool(
                                        context,
                                        _sch,
                                        _level,
                                        _selectedDepartment,
                                        _selectedFaculty,
                                        _loc);

                                    // naviage
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: const UsernameScreen(),
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
                            // SizedBox(
                            //   height: screenHeight / 20,
                            // ),
                          ],
                        )),
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
                                  fontFamily: 'Lato',
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
                      fontFamily: 'Lato',
                      fontSize: screenWidth / 25,
                      fontWeight: FontWeight.bold,
                      color: txtColor,
                      letterSpacing: 0),
                ),
        ),
      ),
    );
  }

  Widget customDropdown({
    required String hintText,
    required String? selectedValue,
    required List<String> items,
    required Function(String?) onChanged,
    required double screenWidth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors
            .grey.shade100, // Light background color for dropdown container
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey.shade400,
          ),
        ),
        boxShadow: const [
          // BoxShadow(
          //   color: Colors.grey.shade300,
          //   blurRadius: 5,
          //   offset: Offset(0, 2),
          // ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
        value: selectedValue,
        hint: Text(
          hintText,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: screenWidth / 30,
            color: Colors.grey.shade800,
          ),
        ),
        isExpanded: true,
        underline: Container(), // Remove default underline
        onChanged: onChanged,
        icon: Icon(
          Icons.arrow_drop_down,
          color: selectedValue != null && selectedValue.isNotEmpty
              ? const Color(0xFFBA9E02)
              : Colors.grey.shade800,
          size: 28,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: screenWidth / 30,
                  color: item == selectedValue
                      ? const Color(0xFFBA9E02)
                      : Colors.grey.shade800,
                  // fontWeight: item == selectedValue
                  //     ? FontWeight.bold
                  //     : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
        style: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget customMapDropdown({
    required String hintText,
    required String? selectedValue,
    required List<Map<String, String>> items,
    required Function(String? selectedDepartment, String? selectedFaculty)
        onChanged,
    required double screenWidth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey.shade400,
          ),
        ),
        boxShadow: const [
          // BoxShadow(
          //   color: Colors.grey.shade300,
          //   blurRadius: 5,
          //   offset: Offset(0, 2),
          // ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Colors.white,
        value: selectedValue,
        hint: Text(
          hintText,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: screenWidth / 30,
            color: Colors.grey.shade800,
          ),
        ),
        isExpanded: true,
        underline: Container(),
        onChanged: (String? newValue) {
          final selectedItem = items.firstWhere(
            (item) => item['department'] == newValue,
            orElse: () => {'department': '', 'faculty': ''},
          );
          onChanged(newValue, selectedItem['faculty']);
        },
        icon: Icon(
          Icons.arrow_drop_down,
          color: selectedValue != null && selectedValue.isNotEmpty
              ? const Color(0xFFBA9E02)
              : Colors.grey.shade800,
          size: 28,
        ),
        items: items.map((Map<String, String> item) {
          return DropdownMenuItem<String>(
            value: item['department'],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                item['department']!,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: screenWidth / 30,
                  color: item['department'] == selectedValue
                      ? const Color(0xFFBA9E02)
                      : Colors.grey.shade800,
                  // fontWeight: item['department'] == selectedValue
                  //     ? FontWeight.bold
                  //     : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: screenWidth / 30,
          color: Colors.black,
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
              padding: EdgeInsets.only(right: screenWidth / 30),
              child: TextFormField(
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: screenWidth / 30,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                controller: controller,
                onChanged: (value) {
                  onChanged(value);
                },
                enableSuggestions: false,
                // autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: screenHeight / 50),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontFamily: 'Lato',
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
