import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/onboarding/sign_in.dart';
import 'package:campcon/main/screens/onboarding/create_account.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFE1AF4B),
      statusBarIconBrightness: Brightness.dark,
    ));

    // BOUNCE animation for the logo
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // SLIDE IN animation for widgets
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo),
    );

    // FADE IN animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 40.sp),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 50),

                  // Centered logo + text
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/images/small_logo.png",
                              height: 60,
                              width: 60,
                            ),
                            Text("CAMPCON",
                                style: TextConstants.boldText.copyWith(
                                  fontSize: 32.sp,
                                  color: AppTheme.textPrimary,
                                )),
                            SizedBox(height: 10.h),
                            Text('The Campus Social App',
                                style: TextConstants.mediumText.copyWith(
                                  fontSize: 15.sp,
                                  color: AppTheme.textSecondary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Buttons at bottom
                  Column(
                    children: [
                      CustomButton(
                        text: "Sign In",
                        onPressed: () => CustomBottomSheet.show(
                          context: context,
                          barrierColor: const Color(0xFFE1AF4B),
                          child: const SignIn(),
                        ),
                        backgroundColor: AppTheme.primaryDark,
                        textColor: AppTheme.textPrimary,
                      ),
                      SizedBox(height: 15.h),
                      CustomButton(
                        text: "Create Account",
                        onPressed: () => CustomBottomSheet.show(
                          context: context,
                          barrierColor: const Color(0xFFE1AF4B),
                          child: const SignUpScreen(),
                        ),
                        textColor: AppTheme.primaryDark,
                        backgroundColor: AppTheme.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
