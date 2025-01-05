import 'package:campcon/floatingbutton.dart';
import 'package:campcon/screens/camplist_screen/lists.dart';
import 'package:campcon/screens/events_screen/events.dart';
import 'package:campcon/screens/initial_screen/homepage.dart';
import 'package:campcon/screens/search_screen/search.dart';
import 'package:campcon/widgets/drawer_widget.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int _currentIndex = 0;
  // bool _isFabVisible = true;

  // List of screens to navigate on tap
  final List<Widget> _screens = [
    // Add your screens here
    const HomeScreen(),
    const SearchScreen(),
    const EventScreen(),
    const ChecklistScreen(),
    // const ClubsScreen(),
  ];

  // Function to handle the bottom navigation bar tap
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        // floatingActionButton: FloatingButton(isFabVisible: _isFabVisible),
        backgroundColor: Colors.grey.shade100,
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(top: 0),
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: GNav(
              textStyle: const TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.5),
              backgroundColor: Colors.grey.shade100,
              color: Colors.grey.shade900,
              activeColor: Colors.black,
              tabBackgroundColor: const Color(0xffd9d9d9),
              gap: 3,
              onTabChange: _onTap,
              padding:
                  const EdgeInsets.only(top: 6, bottom: 6, right: 11, left: 11),
              tabs: const [
                GButton(icon: IconlyLight.home, iconSize: 21, text: 'Home'),
                GButton(icon: IconlyLight.search, iconSize: 21, text: 'Search'),
                GButton(
                    icon: IconlyLight.calendar, iconSize: 21, text: 'Event'),
                GButton(
                    icon: IconlyLight.tick_square, iconSize: 21, text: 'List'),
                // GButton(
                //     icon: IconlyLight.more_square, iconSize: 25, text: 'More'),
              ],
            ),
          ),
        ),
        drawer: const CustomDrawer(),
        body: _screens[_currentIndex]);
  }
}
