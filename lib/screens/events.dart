import 'package:campcon/screens/points.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
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

  List<EventItem> events = [
    EventItem(
      title: 'Campus Festival',
      date: 'September 20, 2024',
      reservations: 120,
      isAttending: false,
      imageUrl: 'assets/images/social.jpeg',
    ),
    EventItem(
      title: 'Career Fair',
      date: 'October 5, 2024',
      reservations: 75,
      isAttending: true,
      imageUrl: 'assets/images/social.jpeg',
    ),
    // Add more events as needed
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Events',
                          style: TextStyle(
                            fontFamily: 'Trebuchet',
                            fontSize: screenWidth / 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Row(
                          children: [
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
                              text: 'Within Campus',
                              icon: null,
                              onSelect: true,
                              index: 0),
                          topButtons(
                              onTap: () {},
                              text: 'Outside Campus',
                              icon: null,
                              onSelect: false,
                              index: 1),
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
                  return eventItem(
                    title: events[index].title,
                    date: events[index].date,
                    reservations: events[index].reservations,
                    isAttending: events[index].isAttending,
                    imageUrl: events[index].imageUrl, // Added imageUrl
                    onAttendPressed: (bool? value) {
                      setState(() {
                        events[index].isAttending = value ?? false;
                      });
                    },
                  );
                },
                childCount: events.length,
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
    required IconData? icon,
    required bool onSelect,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin:
            EdgeInsets.only(left: index == 0 ? screenWidth / 20 : 7, right: 15),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: onSelect ? const Color(0xFFBA9E02) : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontSize: screenWidth / 25,
                color:
                    onSelect ? const Color(0xFFBA9E02) : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            icon != null
                ? Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        icon,
                        size: 25,
                        color: const Color(0xFFBA9E02),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
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

  Widget eventItem({
    required String title,
    required String date,
    required int reservations,
    required bool isAttending,
    required String imageUrl,
    required Function(bool?) onAttendPressed,
  }) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      padding: const EdgeInsets.only(),
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
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.asset(
              imageUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          // Text and button section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth / 23,
                      fontFamily: 'Trebuchet',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: screenWidth / 30,
                      fontFamily: 'Trebuchet',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  // Seat
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '10 / 200 seats',
                      style: TextStyle(
                        fontSize: screenWidth / 30,
                        fontFamily: 'Trebuchet',
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  // booking
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isAttending ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      isAttending ? 'Attending' : 'Ticket',
                      style: TextStyle(
                        fontSize: screenWidth / 30,
                        fontFamily: 'Trebuchet',
                        color: Colors.grey.shade50,
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

  ChecklistItem({required this.description, required this.isCompleted});
}

class EventItem {
  String title;
  String date;
  int reservations;
  bool isAttending;
  String imageUrl; // Added field for image URL

  EventItem({
    required this.title,
    required this.date,
    required this.reservations,
    required this.isAttending,
    required this.imageUrl, // Initialize the image URL
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
