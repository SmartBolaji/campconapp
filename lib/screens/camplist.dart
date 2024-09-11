import 'package:campcon/screens/points.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  // Sample checklist data with more relevant academic and administrative tasks
  List<ChecklistItem> checklist = [
    ChecklistItem(
        description: 'Complete course registration', isCompleted: false),
    ChecklistItem(description: 'Pay school fees', isCompleted: false),
    ChecklistItem(description: 'Obtain authority to pay', isCompleted: false),
    ChecklistItem(
        description: 'Submit scholarship application', isCompleted: false),
    ChecklistItem(
        description: 'Collect course materials from the library',
        isCompleted: true),
    ChecklistItem(
        description: 'Meet with academic advisor', isCompleted: false),
    ChecklistItem(description: 'Check semester results', isCompleted: true),
    ChecklistItem(
        description: 'Renew hostel accommodation', isCompleted: false),
    ChecklistItem(
        description: 'Update personal information on student portal',
        isCompleted: false),
    ChecklistItem(
        description: 'Attend department orientation', isCompleted: true),
    ChecklistItem(description: 'Submit project proposal', isCompleted: false),
    ChecklistItem(
        description: 'Register for extra-curricular activities',
        isCompleted: false),
  ];

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Container(
        color: Colors.grey.shade50,
        padding: EdgeInsets.only(top: screenHeight / 16.8),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth / 20,
                  right: screenWidth / 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: screenWidth / 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       PageTransition(
                    //         child: const PointsScreen(),
                    //         type: PageTransitionType.rightToLeft,
                    //         duration: const Duration(milliseconds: 500),
                    //         reverseDuration: const Duration(milliseconds: 500),
                    //       ),
                    //     );
                    //   },
                    //   child: Icon(
                    //     IconlyBold.setting,
                    //     size: screenWidth / 15,
                    //     color: Colors.grey.shade800,
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camplist',
                      style: TextStyle(
                        fontFamily: 'Trebuchet',
                        fontSize: screenWidth / 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep track of your school tasks and stay organized with this camplist, covering everything from academics to admin duties.',
                      style: TextStyle(
                        fontFamily: 'Trebuchet',
                        fontSize: screenWidth / 25,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverRowHeaderDelegate(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          topButtons(
                              onTap: () {},
                              text: 'All',
                              onSelect: true,
                              index: 0),
                          topButtons(
                              onTap: () {},
                              text: 'Faculty',
                              onSelect: false,
                              index: 1),
                          topButtons(
                              onTap: () {},
                              text: 'Dept',
                              onSelect: false,
                              index: 2),
                          topButtons(
                              onTap: () {},
                              text: 'School',
                              onSelect: false,
                              index: 3),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 0, bottom: 0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return checklistItem(
                    description: checklist[index].description,
                    isCompleted: checklist[index].isCompleted,
                    onChanged: (bool? value) {
                      setState(() {
                        checklist[index].isCompleted = value ?? false;
                      });
                    },
                  );
                },
                childCount: checklist.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topButtons({
    required Function onTap,
    required String text,
    required bool onSelect,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(left: index == 0 ? 15 : 15, right: 15),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: onSelect ? const Color(0xFFBA9E02) : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Trebuchet',
            fontSize: screenWidth / 25,
            color: onSelect ? const Color(0xFFBA9E02) : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget checklistItem({
    required String description,
    required bool isCompleted,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.only(left: 25, right: 15, bottom: 15, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon(
          //   Icons.task_rounded,
          //   size: screenWidth / 15,
          // ),
          // const SizedBox(width: 20),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: screenWidth / 23,
                fontFamily: 'Trebuchet',
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 40),
          Transform.scale(
            scale: 1.5, // Increase size of the checkbox
            child: Checkbox(
              value: isCompleted,
              onChanged: onChanged,
              activeColor: const Color(0xFFBA9E02),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40), // Add border radius
              ),
              side: BorderSide(
                color: Colors.grey.shade200, // Border color of the checkbox
                width: 2, // Border width
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem {
  String description;
  bool isCompleted;

  ChecklistItem({required this.description, required this.isCompleted});
}

class SliverRowHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverRowHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
