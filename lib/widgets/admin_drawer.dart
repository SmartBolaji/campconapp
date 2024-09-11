import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/admin/games.dart';
import 'package:campcon/admin/results.dart';
import 'package:campcon/admin/settings.dart';
import 'package:campcon/admin/transt.dart';
import 'package:campcon/admin/users.dart';
import 'package:campcon/loginscreen.dart';
import 'package:campcon/screens/addpoints.dart';
import 'package:campcon/screens/addupi.dart';
import 'package:campcon/screens/bids.dart';
import 'package:campcon/screens/contacts.dart';
import 'package:campcon/screens/game_rates.dart';
import 'package:campcon/screens/profile.dart';
import 'package:campcon/screens/transact.dart';
import 'package:campcon/screens/wthpoints.dart';
import 'package:campcon/services/task_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdminDrawerWidget extends StatelessWidget {
  const AdminDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider
    final taskData = Provider.of<TaskData>(context);

    double screenWidth = MediaQuery.of(context).size.width;

    // Functions
    // Direct the user to their default browser
    void launchURL(String? url) async {
      if (await canLaunchUrlString(url!)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Drawer(
      child: Material(
        color: Colors.black,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: Border(
                      bottom: BorderSide(
                    width: 0,
                    color: Colors.grey.shade900,
                  ))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: screenWidth / 4,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskData.name,
                        style: TextStyle(
                            fontFamily: 'Nexa Bold',
                            fontSize: screenWidth / 23,
                            color: Colors.white),
                      ),
                      Text(
                        taskData.id.toString(),
                        style: TextStyle(
                            fontFamily: 'Nexa Bold',
                            fontSize: screenWidth / 23,
                            color: Colors.blue.shade300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            listTiles(
              label: 'Users',
              icon: IconlyBold.profile,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const UsersScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Games',
              icon: RpgAwesome.perspective_dice_one,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const GamesScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Transactions',
              icon: FontAwesome5.tasks,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const TranstScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Declare Results',
              icon: Icons.announcement,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResultsScreen()));
              },
            ),
            listTiles(
              label: 'Settings',
              icon: IconlyBold.setting,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminSettings()));
              },
            ),
            listTiles(
              label: 'Logout',
              icon: IconlyBold.logout,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));

                Future.delayed(const Duration(seconds: 2), () {
                  // Remove key
                  taskData.saveLogsOut();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile listTiles(
      {required String label,
      required Function onTap,
      required IconData icon}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontFamily: 'Nexa Bold'),
      ),
      onTap: () {
        onTap();
      },
    );
  }
}
