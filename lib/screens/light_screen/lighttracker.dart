
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class LightScreen extends StatefulWidget {
  const LightScreen({super.key});

  @override
  State<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends State<LightScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;

  List<ChecklistItem> checklist = [
    ChecklistItem(description: 'Awo Hall', isCompleted: false),
    ChecklistItem(description: 'Queen Elizabeth II Hall', isCompleted: false),
    ChecklistItem(description: 'Independence Hall', isCompleted: false),
    ChecklistItem(description: 'Kuti Hall', isCompleted: false),
    ChecklistItem(description: 'Obafemi Awolowo Hall', isCompleted: false),
    ChecklistItem(description: 'S. L. Afolabi Hall', isCompleted: false),
    ChecklistItem(description: 'Nnamdi Azikiwe Hall', isCompleted: false),
    ChecklistItem(description: 'Covenant Hall', isCompleted: false),
    ChecklistItem(description: 'Arugba Hall', isCompleted: false),
    ChecklistItem(description: 'Olayide Hall', isCompleted: false),
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
                        Navigator.pop(context);
                      },
                      child: Icon(
                        IconlyLight.close_square,
                        size: 28,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'LightTracker',
                          style: TextStyle(
                            fontFamily: 'Trebuchet',
                            fontSize: screenWidth / 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.lightbulb,
                            size: screenWidth / 15,
                            color: Colors.yellow.shade700),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay updated on power availability in real-time.',
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
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: SliverRowHeaderDelegate(
            //     child: Column(
            //       children: [
            //         Container(
            //           color: Colors.grey.shade50,
            //           padding: const EdgeInsets.symmetric(vertical: 10),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               topButtons(
            //                   onTap: () {},
            //                   text: 'Within Campus',
            //                   onSelect: true,
            //                   index: 0),
            //               topButtons(
            //                   onTap: () {},
            //                   text: 'Outside Campus',
            //                   onSelect: false,
            //                   index: 1),
            //             ],
            //           ),
            //         ),
            //         Container(
            //           margin: const EdgeInsets.only(top: 0, bottom: 0),
            //           decoration: BoxDecoration(
            //             border: Border(
            //               bottom: BorderSide(
            //                 width: 1,
            //                 color: Colors.grey.shade400,
            //               ),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return checklistItem(
                    description: checklist[index].description,
                    isCompleted: index == 2 || index == 4
                        ? true
                        : checklist[index].isCompleted,
                    onToggle: () {},
                  );
                },
                childCount: checklist.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            )
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
        margin: EdgeInsets.only(left: index == 0 ? 15 : 7, right: 15),
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
    required VoidCallback onToggle, // Callback for toggling the state
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
          GestureDetector(
            onTap: onToggle, // Toggle bulb state when tapped
            child: Icon(
              isCompleted ? Icons.lightbulb : Icons.lightbulb_outline,
              size: screenWidth / 15, // Adjust size as needed
              color:
                  isCompleted ? Colors.yellow.shade700 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16, // Adjust font size as needed
                fontFamily: 'Trebuchet',
                color: Colors.grey.shade800,
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
