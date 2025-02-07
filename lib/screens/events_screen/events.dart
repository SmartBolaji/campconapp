import 'package:campcon/floatingbutton.dart';
import 'package:campcon/screens/events_screen/categ_event.dart';
import 'package:campcon/screens/events_screen/event_tile.dart';
import 'package:campcon/screens/events_screen/event_view.dart';
import 'package:campcon/screens/events_screen/featured_tile.dart';
import 'package:campcon/screens/events_screen/my_tickets.dart';
import 'package:campcon/widgets/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFabVisible = true;

  final List<Map<String, dynamic>> events = [
    {
      'title': 'Phoenix Lounge',
      'location': 'Palms Mall Shopping Complex, Ibadan',
      'food': 'Yes',
      'date': 'Nov 29 - 10 PM',
      'imageUrl': 'assets/images/social.jpeg',
      'reservations': 120,
      'totalSeats': 2000,
    },
    {
      'title': 'Tech Connect Meetup',
      'location': 'Innovation Hub, Lagos',
      'food': 'Not Sure',
      'date': 'Dec 3 - 4 PM',
      'imageUrl': 'assets/images/social.jpeg',
      'reservations': 75,
      'totalSeats': 150,
    },
    {
      'title': 'Music Night',
      'location': 'Eko Hotel, Lagos',
      'food': 'No',
      'date': 'Dec 5 - 8 PM',
      'imageUrl': 'assets/images/social.jpeg',
      'reservations': 180,
      'totalSeats': 250,
    },
    {
      'title': 'Art Exhibition',
      'location': 'Freedom Park, Lagos',
      'food': 'Yes',
      'date': 'Dec 10 - 2 PM',
      'imageUrl': 'assets/images/social.jpeg',
      'reservations': 50,
      'totalSeats': 100,
    },
    {
      'title': 'Food Festival',
      'location': 'Heritage Garden, Abuja',
      'food': 'No',
      'date': 'Dec 12 - 11 AM',
      'imageUrl': 'assets/images/social.jpeg',
      'reservations': 200,
      'totalSeats': 300,
    },
  ];

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButton: FloatingButton(isFabVisible: _isFabVisible),
      backgroundColor: Colors.grey.shade50,
      body: Container(
        color: Colors.grey.shade50,
        padding: EdgeInsets.only(top: screenHeight / 16.8),
        child: CustomScrollView(
          slivers: [
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
                          'Events',
                          style: TextStyle(
                            fontFamily: 'Lato',
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
                              onTap: () {
                                // show my own tickets
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyTicketsPage()));
                              },
                              child: const Icon(
                                IconlyLight.ticket_star,
                                size: 25,
                                // color: Color(0xFFBA9E02),
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
            SliverToBoxAdapter(child: CategoriesWidget()),
            // Sliding Events
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 200, // Height of the sliding area
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: events.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return featuredEventItem(
                          title: event['title'],
                          location: event['location'],
                          date: event['date'],
                          imageUrl: event['imageUrl'],
                          attendingProfiles: const [
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                          ],
                          reservations: event['reservations'],
                          totalSeats: event['totalSeats'],
                          onPressed: () {},
                        );
                      },
                    ),
                  ),
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      events.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFFBA9E02)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = events[index];
                  return eventItem(
                    title: event['title'],
                    location: event['location'],
                    date: event['date'],
                    imageUrl: event['imageUrl'],
                    reservations: event['reservations'],
                    totalSeats: event['totalSeats'],
                    onTap: () {
                      NavigationHelper.navigateTo(
                        context,
                        EventViewPage(
                          title: event['title'],
                          location: event['location'],
                          food: event['food'],
                          date: DateTime.now(),
                          imageUrls: const [
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                          ],
                          attendingProfiles: const [
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                            'assets/images/social.jpeg',
                          ],
                          reservations: event['reservations'],
                          totalSeats: event['totalSeats'],
                          price: 'FREE',
                          time: '6PM',
                        ),
                      );
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
