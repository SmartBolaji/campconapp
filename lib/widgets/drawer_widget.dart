import 'package:campcon/screens/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade100, // Set the status bar color
      statusBarIconBrightness:
          Brightness.dark, // For light text on dark background
    ));

    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), // No radius on the top-right
            bottomRight: Radius.circular(0), // No radius on the bottom-right
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 30, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        'assets/images/social.jpeg',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Peter Opad.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lato',
                      ),
                    ),
                    Text(
                      '@Peter',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(width: 1, color: Colors.grey.shade400),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '10',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 30), // Space between the counts
                          Container(
                            height:
                                40, // Add a fixed height to make the divider visible
                            child: VerticalDivider(
                              color: Colors.grey.shade400, // Color of the line
                              thickness: 1, // Line thickness
                              width:
                                  1, // Set a small width for the divider to appear
                            ),
                          ),
                          SizedBox(
                              width:
                                  30), // Space between the line and the second column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '20',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  fontFamily: 'Lato',
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: const Divider(),
              ),

              // Drawer Items
              CustomDrawerTile(
                icon: FeatherIcons.user,
                title: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          coverImageUrl: 'assets/images/social.jpeg',
                          profileImageUrl: 'assets/images/social.jpeg',
                          userName: 'Peter Opad.',
                          userHandle: 'Peter',
                          connectsCount: 20,
                          connectingCount: 40),
                    ),
                  );
                }, // Define navigation logic here
              ),
              const CustomDrawerTile(
                icon: FeatherIcons.bookmark,
                title: 'Bookmark',
                onTap: null, // Define navigation logic here
              ),
              // Notifications with circular number
              const CustomDrawerTile(
                icon: FeatherIcons.bell,
                title: 'Notifications',
                onTap: null, // Define navigation logic here
              ),
              // const CustomDrawerTile(
              //   icon: FeatherIcons.bookOpen,
              //   title: 'Resources',
              //   onTap: null, // Define navigation logic here
              // ),
              const CustomDrawerTile(
                icon: FeatherIcons.trendingUp,
                title: 'Promote',
                onTap: null, // Define navigation logic here
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: const Divider(),
              ),
              const CustomDrawerTile(
                icon: FeatherIcons.settings,
                title: 'Settings',
                onTap: null, // Define navigation logic here
              ),
              const CustomDrawerTile(
                icon: FeatherIcons.helpCircle,
                title: 'Help',
                onTap: null, // Define navigation logic here
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: const Divider(),
              ),

              // Logout
              const CustomDrawerTile(
                icon: FeatherIcons.logOut,
                title: 'Logout',
                onTap: null, // Define logout logic here
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Drawer Tile Widget
class CustomDrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const CustomDrawerTile({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade800),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap!();
      },
      trailing: title == 'Notifications'
          ? Container(
              width: 25, // Fixed width to avoid infinite width error
              height: 25, // Height of the circle
              decoration: BoxDecoration(
                color: Color(0xFFBA9E02), // Circle color
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '3', // Example number for notifications
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
