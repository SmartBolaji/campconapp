import 'package:campcon/screens/addpoints.dart';
import 'package:campcon/screens/camplist.dart';
import 'package:campcon/screens/events.dart';
import 'package:campcon/screens/homepage.dart';
import 'package:campcon/screens/lighttracker.dart';
import 'package:campcon/screens/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/admin/admin_panel.dart';
import 'package:flutter/material.dart';
import 'package:campcon/screens/points.dart';
import 'package:campcon/services/task_data.dart';
import 'package:campcon/widgets/drawer_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<void> fetchDataFuture;
  final Uri _url = Uri.parse('https://flutter.dev');

  QuerySnapshot? _snap;
  QuerySnapshot? _snap1;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  int currentSize = 0;

  // Variables (admin)
  int adminId = 0;
  String alertMsg = '';
  String whatsNo = '';
  String whatsLink = '';
  String callNo = '';
  String howToPlay = '';

  int _currentIndex = 0;

  // List of screens to navigate on tap
  final List<Widget> _screens = [
    // Add your screens here
    const HomeScreen(),
    const SearchScreen(),
    const EventScreen(),
    const AddPointsScreen(),
    const LightScreen(),
    const ChecklistScreen(),
  ];

  // Function to handle the bottom navigation bar tap
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Functions
  Future<void> _launchUrl({required String url}) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  // Method to load games data
  Future<void> loadMrkData() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Games')
          .where('status', isEqualTo: 'Active')
          .where('mrksection', isEqualTo: 'Mumbai')
          .orderBy('created', descending: false)
          .get();
      if (snap.docs.isEmpty) {
        _snap = await FirebaseFirestore.instance
            .collection('Games')
            .where('status', isEqualTo: 'Active')
            .where('mrksection', isEqualTo: 'Mumbai')
            .orderBy('created', descending: false)
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap = snap;
      }
      if (_snap!.size > 30) {
        setState(() {
          currentSize = 30; // Update to 20
        });
      } else {
        setState(() {
          currentSize = _snap!.size; // Update default
        });
      }
    } catch (e) {
      e.toString();
    }
  }

  // load the app settings
  Future<void> loadSettingsData() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('Settings').get();
      if (snap.docs.isEmpty) {
        _snap1 = await FirebaseFirestore.instance
            .collection('Settings')
            .get(const GetOptions(source: Source.cache));
      } else {
        _snap1 = snap;
      }

      if (_snap1!.docs[0].exists) {
        final doc = _snap1!.docs[0];
        adminId = doc.get('adminid');
        alertMsg = doc.get('alertmsg');
        whatsNo = doc.get('whatsno');
        whatsLink = doc.get('whatslink');
        callNo = doc.get('callno');
        howToPlay = doc.get('howtoplay');
      }
      setState(() {});
    } catch (e) {
      e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSettingsData();
    fetchDataFuture = loadMrkData();
  }

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        // Start of the Floating Action Button
        floatingActionButton: taskData.id == adminId
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const AdminPanelScreen(),
                      type: PageTransitionType.bottomToTop,
                      duration: const Duration(milliseconds: 1000),
                      reverseDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                backgroundColor: Colors.blue.shade300,
                child: Icon(
                  Icons.vpn_key,
                  color: Colors.white,
                  size: screenWidth / 25,
                ))
            : null,
        // End of Floating Action Button
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.grey.shade800,
          selectedItemColor: const Color(0xFFBA9E02),
          currentIndex: _currentIndex,
          onTap: _onTap,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                IconlyLight.home,
                size: 28,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                IconlyLight.search,
                size: 28,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                IconlyLight.calendar,
                size: 28,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                IconlyLight.user_1,
                size: 28,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.lightbulb_circle_outlined,
                size: 28,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                IconlyLight.tick_square,
                size: 28,
              ),
              label: '',
            ),
          ],
        ),
        drawer: const SafeArea(child: DrawerWidget()),
        body: _screens[_currentIndex]);
  }
}
