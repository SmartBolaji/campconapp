import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:iconly/iconly.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/onboarding/loginscreen.dart';
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

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

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
              label: 'My Profile',
              icon: IconlyBold.profile,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const ProfileScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Add Points',
              icon: IconlyBold.wallet,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const AddPointsScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Withdraw Point',
              icon: FontAwesome5.dollar_sign,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const WthPointsScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Bid History',
              icon: IconlyBold.activity,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BidsScreen()));
              },
            ),
            listTiles(
              label: 'Transaction',
              icon: IconlyBold.more_circle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransactScreen()));
              },
            ),
            listTiles(
              label: 'Add UPI ID',
              icon: FontAwesome.bank,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const AddUpiScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Game Rates',
              icon: IconlyBold.game,
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const GameRatesScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Contact Us',
              icon: Icons.contact_support,
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const ContactsScreen(),
                    type: PageTransitionType.leftToRight,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                  ),
                );
              },
            ),
            listTiles(
              label: 'Rate App',
              icon: IconlyBold.star,
              onTap: () {
                Navigator.pop(context);
                launchURL('https://flutter.dev');
              },
            ),
            listTiles(
              label: 'How To Play',
              icon: IconlyBold.play,
              onTap: () {
                Navigator.pop(context);
                launchURL('https://paytmmakta.com');
              },
            ),
            listTiles(
              label: 'Share With Friends',
              icon: Icons.share,
              onTap: () async {
                // try {
                //   await Share.share('url',
                //       subject: 'Share our app with friends and bid.');
                // } catch (e) {
                //   GlobalMethods.errorDialog(
                //       errorMessage: e.toString(), context: context);
                // }
              },
            ),
            listTiles(
              label: 'Logout',
              icon: IconlyBold.logout,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);

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
