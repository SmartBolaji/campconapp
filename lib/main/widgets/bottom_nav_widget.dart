import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/animated_provider.dart';
import 'package:campcon/main/provider/notify_provider.dart';

typedef NavTapCallback = void Function(int index);

class BottomNavWidget extends StatefulWidget {
  final int currentIndex;
  final NavTapCallback onTap;

  const BottomNavWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  late final List<AnimatedProvider> _navAnimations;

  @override
  void initState() {
    super.initState();
    _navAnimations = List.generate(5, (_) => AnimatedProvider());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navAnimations.asMap().forEach((i, anim) {
        if (i == widget.currentIndex) anim.show();
      });
    });
  }

  @override
  void didUpdateWidget(covariant BottomNavWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _navAnimations[oldWidget.currentIndex].hide();
      _navAnimations[widget.currentIndex].show();
    }
  }

  @override
  void dispose() {
    for (var a in _navAnimations) a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: appColors.surface,
        border: Border(
          top: BorderSide(
            color: appColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, IconlyBold.home, IconlyLight.home),
              _buildNavItem(1, IconlyBold.message, IconlyLight.message),
              _buildNavItem(2, IconlyBold.document, IconlyLight.document),
              _buildNavItem(
                  3, IconlyBold.notification, IconlyLight.notification),
              _buildNavItem(4, IconlyBold.bag, IconlyLight.bag),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData boldIcon,
    IconData lightIcon,
  ) {
    return ChangeNotifierProvider<AnimatedProvider>.value(
      value: _navAnimations[index],
      child: Consumer<AnimatedProvider>(
        builder: (context, animation, child) {
          final isSelected = widget.currentIndex == index;
          final colorScheme = Theme.of(context).colorScheme;

          return Expanded(
            child: GestureDetector(
              onTapDown: (_) => animation.pressButton(),
              onTapUp: (_) {
                animation.releaseButton();
                widget.onTap(index);
              },
              onTapCancel: () => animation.releaseButton(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: animation.isButtonPressed ? 0.85 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(8.w),
                            child: Icon(
                              isSelected ? boldIcon : lightIcon,
                              color: isSelected
                                  ? colorScheme.primary
                                  : context.appColors.textSecondary,
                              size: isSelected ? 22.sp : 24.sp,
                            ),
                          ),
                          // Notification badge (only for notification icon, index 3)
                          if (index == 3)
                            Consumer<NotifyProvider>(
                              builder: (context, notifyProvider, child) {
                                final unreadCount = notifyProvider.unreadCount;
                                if (unreadCount == 0) {
                                  return SizedBox.shrink();
                                }

                                final displayCount = unreadCount > 9
                                    ? '9+'
                                    : unreadCount.toString();

                                return Positioned(
                                  top: -0.h,
                                  right: 5.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          displayCount == '9+' ? 4.w : 5.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.error,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      displayCount,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Bottom indicator
                    // AnimatedContainer(
                    //   duration: const Duration(milliseconds: 250),
                    //   curve: Curves.easeInOut,
                    //   height: 3.h,
                    //   width: isSelected ? 24.w : 0,
                    //   decoration: BoxDecoration(
                    //     color: AppTheme.primary,
                    //     borderRadius: BorderRadius.circular(1.5.r),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// OLD ROUNDED FLOATING VERSION (COMMENTED OUT)
// ============================================

/*
class _BottomNavWidgetState extends State<BottomNavWidget> {
  late final List<AnimatedProvider> _navAnimations;

  @override
  void initState() {
    super.initState();
    _navAnimations = List.generate(5, (_) => AnimatedProvider());
    // show initial selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navAnimations.asMap().forEach((i, anim) {
        if (i == widget.currentIndex) anim.show();
      });
    });
  }

  @override
  void didUpdateWidget(covariant BottomNavWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // hide previous, show new
      _navAnimations[oldWidget.currentIndex].hide();
      _navAnimations[widget.currentIndex].show();
    }
  }

  @override
  void dispose() {
    for (var a in _navAnimations) a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 20),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppTheme.border.withValues(alpha: 0.25)),
            ),
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnimatedNavItem(0, Ph.house_fill, Ph.house_fill),
                    _buildAnimatedNavItem(
                        1, Ph.chat_centered_fill, Ph.chat_centered_fill),
                    _buildAnimatedNavItem(
                        2, Ph.notebook_fill, Ph.notebook_fill),
                    _buildAnimatedNavItem(3, Ph.bell_fill, Ph.bell_fill),
                    _buildAnimatedNavItem(
                        4, Ph.shopping_bag_fill, Ph.shopping_bag_fill),
                  ],
                ),
              ),
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
          final isSelected = widget.currentIndex == index;

          return GestureDetector(
            onTapDown: (_) => animation.pressButton(),
            onTapUp: (_) {
              animation.releaseButton();
              widget.onTap(index);
            },
            onTapCancel: () => animation.releaseButton(),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 48.w,
              height: 48.h,
              transform: Matrix4.identity()
                ..scale(animation.isButtonPressed ? 0.9 : 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: animation.isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                    ),
                  ),
                  if (animation.isButtonPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
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
                            : AppTheme.textPrimary.withValues(alpha: 0.8),
                        size: 30.sp,
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
*/
