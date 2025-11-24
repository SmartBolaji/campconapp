import 'package:flutter/material.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/bookmark.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/home_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/market_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/message.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/notification.dart';
import 'package:campcon/main/widgets/dialogs/user_type_dialog.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _hasShownDialog = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    MessageScreen(),
    BookmarkScreen(),
    NotificationScreen(),
    MarketScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Show dialog after a delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUserTypeDialogAfterDelay();
    });
  }

  void _showUserTypeDialogAfterDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _hasShownDialog) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Only show if user hasn't set their type yet
      if (authProvider.currentUser?.isStudent == true) {
        _hasShownDialog = true;

        UserTypeDialog.show(
          context,
          onSelection: (isStudent, {studentDetails, interests}) async {
            // Update user type with all collected data
            await authProvider.updateUserType(
              isStudent,
              studentDetails: studentDetails,
              interests: interests,
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use AnimatedSwitcher to switch screens smoothly
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          // Customize your animation here (e.g. slide, fade)
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0), // slide slightly from right
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1
                ? Icons.chat_bubble
                : Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                _currentIndex == 2 ? Icons.bookmark : Icons.bookmark_border),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 3
                ? Icons.notifications
                : Icons.notifications_none),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 4 ? Icons.store : Icons.store_outlined),
            label: 'Market',
          ),
        ],
      ),
    );
  }
}
