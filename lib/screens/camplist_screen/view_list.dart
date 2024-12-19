import 'package:campcon/screens/camplist_screen/categ_list.dart';
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
        description: 'Complete course registration',
        isCompleted: false,
        date: '05 AM'),
    ChecklistItem(
        description: 'Pay school fees', isCompleted: false, date: '05:30 AM'),
    ChecklistItem(
        description: 'Obtain authority to pay',
        isCompleted: false,
        date: '06 AM'),
    ChecklistItem(
        description: 'Submit scholarship application',
        isCompleted: false,
        date: '08 AM'),
    ChecklistItem(
        description: 'Collect course materials from the library',
        isCompleted: true,
        date: '10 AM'),
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
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: EdgeInsets.only(
            //       left: screenWidth / 20,
            //       right: screenWidth / 20,
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         GestureDetector(
            //           onTap: () {
            //             Navigator.push(
            //               context,
            //               PageTransition(
            //                 child: const PointsScreen(),
            //                 type: PageTransitionType.rightToLeft,
            //                 duration: const Duration(milliseconds: 500),
            //                 reverseDuration: const Duration(milliseconds: 500),
            //               ),
            //             );
            //           },
            //           child: Icon(
            //             Icons.account_circle_outlined,
            //             size: screenWidth / 15,
            //             color: Colors.grey.shade800,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Row(
                          children: [
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: const Icon(
                            //     IconlyBroken.plus,
                            //     size: 25,
                            //   ),
                            // ),
                            // const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                IconlyBroken.search,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                IconlyLight.filter,
                                size: 25,
                                color: Color(0xFFBA9E02),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: CamplistCategoryWidget()),
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
                    date: checklist[index].date, // Pass the date here
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
    required String date, // Add date as a new parameter
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Date information (day and date)
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Actual Day
              // Text(
              //   'Day: ${date.split('-')[2]}', // Extract day from the date string
              //   style: TextStyle(
              //     fontSize: screenWidth / 30,
              //     fontFamily: 'Trebuchet',
              //     color: Colors.grey.shade700,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 5),
              // Full Date with line underneath
              Text(
                date,
                style: TextStyle(
                  fontSize: screenWidth / 30,
                  fontFamily: 'Trebuchet',
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: screenWidth / 5.8, // Line width
                height: 1,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(
              width: 20), // Spacing between the left and right columns

          // Right column: Description and checkbox
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.grey.shade200 : Colors.transparent,
                border: Border.all(width: 1, color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  // BoxShadow(
                  //
                  //   blurRadius: 5,
                  //   spreadRadius: 2,
                  //   offset: const Offset(0, 2),
                  // ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Description text
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
                  // Checkbox with custom styling
                  Transform.scale(
                    scale: 1.5, // Increase size of the checkbox
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: onChanged,
                      activeColor: const Color(0xFFBA9E02),
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(40), // Rounded corners
                      ),
                      side: BorderSide(
                        color: Colors
                            .grey.shade200, // Border color of the checkbox
                        width: 2, // Border width
                      ),
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

class ChecklistItem {
  String description;
  bool isCompleted;
  String date; // Add a date property

  ChecklistItem({
    required this.description,
    required this.isCompleted,
    required this.date,
  });
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
