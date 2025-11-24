import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/other_screen/editprofile.dart';
import 'package:campcon/main/screens/other_screen/settings_screen.dart';
import 'package:campcon/main/widgets/profile_widget/profile_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({
    this.userId,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? profileUser;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Start loading profile data immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(builder: (context, authProvider, child) {
        // Check if the current user exists and get their data

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null) {
          return Center(child: Text('Error: $errorMessage'));
        }

        // The user object we are displaying (must be non-null here)
        final user = profileUser!;

        // Check if the displayed profile is the current user's profile
        final bool isCurrent = user.uid == authProvider.currentUser?.uid;

        return DefaultTabController(
          length: 3,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 40),
              child: Center(
                  child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.arrow_back),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    child: user.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.profileImageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 50),
                            ),
                          )
                        : const Icon(Icons.person, size: 50),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    user.name ?? "No Name",
                    style: TextConstants.smallText
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    " @${user.username}",
                    style: TextConstants.smallText,
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    textAlign: TextAlign.center,
                    user.aboutMe ?? "No bio provided.",
                    style: TextConstants.smallText,
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "136 ",
                          style: TextConstants.smallText
                              .copyWith(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: ' Follow',
                                style: TextConstants.smallText),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      RichText(
                        text: TextSpan(
                          text: "106 ",
                          style: TextConstants.smallText
                              .copyWith(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: ' Following',
                                style: TextConstants.smallText),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCurrent) ...[
                        // Current User: Edit, Share, Settings
                        ProfileButton(
                          text: "Edit",
                          onTap: () {
                          
                    showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        // Return your sign-in/account creation widget here
                        return Editprofile();
                      },
                    );
                 
                          },
                        ),
                        SizedBox(width: 15.w),
                        ProfileButton(
                          text: "Share",
                          onTap: () {
                            // Share profile link
                          },
                        ),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const SettingsScreen(),
                                duration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Constants.backgroundColor,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.settings),
                          ),
                        )
                      ] else ...[
                        // Other User: Follow/Unfollow, Message, Share
                        ProfileButton(
                          text: "Follow", // Or Unfollow based on state
                          onTap: () {},
                        ),
                        SizedBox(width: 15.w),
                        ProfileButton(
                          text: "Message",
                          onTap: () {},
                        ),
                        SizedBox(width: 15.w),
                        ProfileButton(
                          text: "Share",
                          onTap: () {},
                        ),
                      ]
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // The TabBar for navigation
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TabBar(
                      isScrollable: false,
                      labelColor: Constants.primaryDark,
                      unselectedLabelColor: Constants.textLight,
                      indicatorColor: Constants.primaryDark,
                      tabs: const [
                        Tab(text: "Posts"),
                        Tab(text: "Media"),
                        Tab(text: "Saved"),
                      ],
                    ),
                  ),

                  // The TabBarView to display different content for each tab
                  SizedBox(
                    height: 500.h,
                    child: const TabBarView(
                      children: [
                        // Yourt= widgets for each tab
                        Center(child: Text("Posts Screen")),
                        Center(child: Text("Media Screen")),
                        Center(child: Text("Saved Screen")),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _loadUserProfile() async {
    // We use listen: false here because we are outside of the build method
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Determine which user ID to load
      String targetUserId =
          widget.userId ?? authProvider.currentUser?.uid ?? '';

      if (targetUserId.isEmpty) {
        setState(() {
          errorMessage = 'User not logged in or ID not provided.';
          isLoading = false;
        });
        return;
      }

      // 2. Optimization: If viewing own profile, use cached data from AuthProvider
      if (targetUserId == authProvider.currentUser?.uid) {
        setState(() {
          profileUser = authProvider.currentUser;
          isLoading = false;
        });
        return;
      }

      // 3. Fetch from Firestore for other users
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          profileUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'User profile data not found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading profile: ${e.toString()}';
        isLoading = false;
      });
    }
  }
}
