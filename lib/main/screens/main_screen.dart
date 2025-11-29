import 'package:flutter/material.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/bookmark.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/home_folder/home_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/market_folder/market_screen.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/message.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/notification.dart';
import 'package:campcon/main/widgets/dialogs/user_type_dialog.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/animated_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/widgets/upload_progress_bar.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

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
    MessageScreen(),
    BookmarkScreen(),
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

      if (authProvider.currentUser?.isStudent == true) {
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
      body: Stack(
        children: [
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: UploadProgressBar(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedNavItem(0, Ph.house_fill, Ph.house),
                _buildAnimatedNavItem(1, Ph.chats_circle_fill, Ph.chats_circle),
                _buildAnimatedNavItem(
                    2, Ph.bookmark_simple_fill, Ph.bookmark_simple),
                _buildAnimatedNavItem(3, Ph.bell_fill, Ph.bell),
                _buildAnimatedNavItem(4, Ph.shopping_bag_fill, Ph.shopping_bag),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(
      int index, String filledIcon, String outlineIcon) {
    return ChangeNotifierProvider<AnimatedProvider>.value(
      value: _navAnimations[index],
      child: Consumer<AnimatedProvider>(
        builder: (context, animation, child) {
          final isSelected = _currentIndex == index;

          return GestureDetector(
            onTapDown: (_) => animation.pressButton(),
            onTapUp: (_) {
              animation.releaseButton();
              _onNavTap(index);
            },
            onTapCancel: () => animation.releaseButton(),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              padding: EdgeInsets.all(animation.isButtonPressed ? 2 : 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle with animation
                  AnimatedScale(
                    scale: animation.isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  // Icon with scale animation
                  AnimatedScale(
                    scale: animation.isVisible ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: animation.isVisible ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Iconify(
                        isSelected ? filledIcon : outlineIcon,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),

                  // Bottom indicator dot with slide animation
                  if (isSelected)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      bottom: animation.isContentVisible ? 2 : -10,
                      child: AnimatedOpacity(
                        opacity: animation.isContentVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
