import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_screen.dart';
import 'package:campcon/main/widgets/event/event_upload_bar.dart'; // ✅ Add this
import 'package:campcon/main/widgets/market/market_upload_bar.dart';
import 'package:flutter/material.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/screens/bottom_nav_screens/resource_folder/resource_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/home_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/market_screen.dart';
import 'package:campcon/main/screens/bottom_nav_screens/notification_screen.dart';
import 'package:campcon/main/widgets/dialogs/user_type_dialog.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/animated_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/widgets/upload_progress_bar.dart';
import 'package:campcon/main/widgets/bottom_nav_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _hasShownDialog = false;
  final List<AnimatedProvider> _navAnimations =
      List.generate(5, (_) => AnimatedProvider());

  final List<Widget> _screens = const [
    HomeScreen(),
    MessagingScreen(),
    ResourcesScreen(),
    NotificationScreen(),
    MarketScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppTheme.surface,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Show initial selected item animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navAnimations[0].show();
      _showUserTypeDialogAfterDelay();
    });
  }

  @override
  void dispose() {
    for (var anim in _navAnimations) {
      anim.dispose();
    }
    super.dispose();
  }

  void _showUserTypeDialogAfterDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _hasShownDialog) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentUser?.isStudent != null) {
        _hasShownDialog = true;

        UserTypeDialog.show(
          context,
          onSelection: (isStudent, {studentDetails, interests}) async {
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

  void _onNavTap(int index) {
    if (_currentIndex == index) return;

    // Haptic feedback
    HapticFeedback.selectionClick();

    // Hide old icon animation
    _navAnimations[_currentIndex].hide();

    // Show new icon animation
    _navAnimations[index].show();

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _screens[_currentIndex],
          ),

          // Upload Progress Bar (Posts)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: UploadProgressBar(),
          ),

          // Market Upload Progress Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: UploadMarketProgressBar(),
          ),

          // ✅ Event Upload Progress Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: EventUploadProgressBar(),
          ),

          // Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavWidget(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}
