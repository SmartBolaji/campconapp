import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/provider/animated_dialog_provider.dart';

class CompletionDialog extends StatefulWidget {
  final String userName;
  final VoidCallback onComplete;

  const CompletionDialog({
    super.key,
    required this.userName,
    required this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    required VoidCallback onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AnimatedDialogProvider()..show(),
        child: CompletionDialog(
          userName: userName,
          onComplete: onComplete,
        ),
      ),
    );
  }

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _celebrationController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _iconBounceAnimation;

  @override
  void initState() {
    super.initState();

    // Main dialog animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Celebration particles animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    );

    // Icon bounce animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconBounceAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _iconController.forward();
      _celebrationController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrationController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: AppTheme.surface,
          child: Consumer<AnimatedDialogProvider>(
            builder: (context, provider, child) {
              return AnimatedOpacity(
                opacity: provider.isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated celebration icon
                      ScaleTransition(
                        scale: _iconBounceAnimation,
                        child: _buildCelebrationIcon(),
                      ),

                      SizedBox(height: 24.h),

                      // Success message
                      _buildAnimatedText(
                        'All Set!',
                        TextConstants.boldText.copyWith(
                          fontSize: 28.sp,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        delay: 200,
                      ),

                      SizedBox(height: 12.h),

                      // Welcome message
                      // _buildAnimatedText(
                      //   'Welcome to Campcon, ${widget.userName}!',
                      //   TextConstants.mediumText.copyWith(
                      //     fontSize: 16.sp,
                      //     color: AppTheme.textSecondary,
                      //   ),
                      //   delay: 300,
                      // ),

                      // SizedBox(height: 8.h),

                      // Subtitle message
                      _buildAnimatedText(
                        'Your profile is ready.\nLet\'s explore campus life together! 🎓',
                        TextConstants.smallText.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.textLight,
                          height: 1.5,
                        ),
                        delay: 400,
                      ),

                      SizedBox(height: 32.h),

                      // Features preview
                      _buildFeaturesList(),

                      SizedBox(height: 32.h),

                      // Get started button
                      _buildAnimatedButton(delay: 600),

                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated background circle
        FadeTransition(
          opacity: _celebrationAnimation,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.2),
                  AppTheme.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // Main icon container
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            FeatherIcons.check,
            size: 40.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        // Celebration particles
        ..._buildCelebrationParticles(),
      ],
    );
  }

  List<Widget> _buildCelebrationParticles() {
    return List.generate(8, (index) {
      final angle = (index * 45) * 3.14159 / 180;
      return AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          final distance = 40.w * _celebrationAnimation.value;
          final opacity = 1.0 - _celebrationAnimation.value;
          return Positioned(
            left: 60.w + (distance * cos(angle)),
            top: 60.h + (distance * sin(angle)),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildFeaturesList() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Column(
              children: [
                _buildFeatureItem(
                  FeatherIcons.users,
                  'Connect with students',
                  delay: 0,
                ),
                SizedBox(height: 12.h),
                _buildFeatureItem(
                  FeatherIcons.calendar,
                  'Discover campus events',
                  delay: 100,
                ),
                SizedBox(height: 12.h),
                _buildFeatureItem(
                  FeatherIcons.messageCircle,
                  'Join conversations',
                  delay: 200,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, {required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  text,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(String text, TextStyle style,
      {required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Consumer<AnimatedDialogProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTapDown: (_) => provider.pressButton(),
                  onTapUp: (_) async {
                    provider.releaseButton();
                    await _controller.reverse();
                    if (mounted) {
                      Navigator.of(context).pop();
                      widget.onComplete();
                    }
                  },
                  onTapCancel: () => provider.releaseButton(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(40.r),
                      boxShadow: !provider.isButtonPressed
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    transform: Matrix4.identity()
                      ..scale(provider.isButtonPressed ? 0.95 : 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          FeatherIcons.arrowRight,
                          size: 18.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double cos(double angle) => (angle * 180 / 3.14159).cos();
  double sin(double angle) => (angle * 180 / 3.14159).sin();
}

// Extension to add cos and sin methods
extension on double {
  double cos() {
    return (this * 3.14159 / 180).cosRadians();
  }

  double sin() {
    return (this * 3.14159 / 180).sinRadians();
  }

  double cosRadians() {
    // Taylor series approximation for cosine
    double x = this;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double sinRadians() {
    // Taylor series approximation for sine
    double x = this;
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}
