import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/onboarding/account_setUp.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isChecking = false;
  AuthProvider? _authProvider; // Store reference here

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Constants.background,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Start auto-checking in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _authProvider?.startEmailVerificationCheck();
    });
  }

  @override
  void dispose() {
    // Stop checking when leaving screen using stored reference
    _authProvider?.stopVerificationCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Auto-navigate when verified
          if (authProvider.isEmailVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountSetup()),
                );
              }
            });
          }

          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 70.sp),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            authProvider.stopVerificationCheck();
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 18.sp,
                            color: Constants.black,
                          ),
                        ),
                        Text(
                          "Check Your Email",
                          style: TextConstants.boldText.copyWith(
                            fontSize: 20.sp,
                          ),
                        ),
                        const SizedBox(
                            width: 24), // Match the back button width
                      ],
                    ),
                    SizedBox(height: 40.h),

                    // Email Icon
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 100.sp,
                      color: Constants.primaryColors,
                    ),
                    SizedBox(height: 30.h),

                    // Instruction Text
                    Text(
                      "Verification Link Sent!",
                      style: TextConstants.boldText.copyWith(fontSize: 24.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15.h),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "We've sent a verification link to\n",
                        style: TextConstants.smallText.copyWith(
                          color: Constants.textLight,
                          fontSize: 15.sp,
                        ),
                        children: [
                          TextSpan(
                            text: authProvider.emailController.text,
                            style: TextConstants.smallText.copyWith(
                              color: Constants.primaryColors,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.h),

                    Text(
                      "Click the link in the email to verify your account",
                      style: TextConstants.smallText.copyWith(
                        color: Constants.textLight,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),

                    // Checking status indicator (only show when NOT manually checking)
                    if (!_isChecking)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Constants.primaryColors,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Checking verification status...",
                            style: TextConstants.smallText.copyWith(
                              color: Constants.textLight,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 30.h),

                    // Error message
                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: Constants.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Constants.error, size: 20.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextConstants.smallText.copyWith(
                                    color: Constants.error,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // I've Verified Button (Primary Action)
                    CustomButton(
                      text: _isChecking
                          ? "Checking..."
                          : "I've Verified My Email",
                      onPressed: _isChecking
                          ? () {} // Disabled when checking
                          : () => _handleCheckVerification(authProvider),
                      backgroundColor: Constants.primaryDark,
                      textColor: Constants.black,
                    ),
                    SizedBox(height: 15.h),

                    // Resend Link Button (Secondary Action)
                    CustomButton(
                      text: authProvider.isLoading
                          ? "Sending..."
                          : authProvider.canResend
                              ? "Resend Verification Link"
                              : "Resend in ${authProvider.resendCountdown}s",
                      onPressed: () {
                        if (authProvider.canResend &&
                            !authProvider.isLoading &&
                            !_isChecking) {
                          _handleResendVerification(authProvider);
                        }
                      },
                      backgroundColor: authProvider.canResend
                          ? Constants.primarybackground
                          : Constants.border,
                      textColor: authProvider.canResend
                          ? Constants.textPrimary
                          : Constants.textLight,
                    ),
                    SizedBox(height: 25.h),

                    // Help text
                    Container(
                      padding: EdgeInsets.all(15.sp),
                      decoration: BoxDecoration(
                        color: Constants.primarybackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Constants.primaryColors, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "Check your spam folder if you don't see the email",
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: Constants.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCheckVerification(AuthProvider authProvider) async {
    if (!mounted) return;

    setState(() => _isChecking = true);
    authProvider.clearError();

    // Check verification status
    bool isVerified = await authProvider.checkEmailVerified();

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (isVerified) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10.w),
              const Expanded(
                child: Text('Email verified successfully!'),
              ),
            ],
          ),
          backgroundColor: Constants.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to account setup
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountSetup()),
        );
      }
    } else {
      // Show error message
      authProvider.setError(
          'Email not verified yet. Please check your email and click the verification link.');

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Row(
      //         children: [
      //           const Icon(Icons.error_outline, color: Colors.white),
      //           SizedBox(width: 10.w),
      //           const Expanded(
      //             child: Text(
      //                 'Email not verified yet. Please check your email first.'),
      //           ),
      //         ],
      //       ),
      //       backgroundColor: Constants.error,
      //       behavior: SnackBarBehavior.floating,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10.r),
      //       ),
      //       duration: const Duration(seconds: 3),
      //     ),
      //   );
      // }
    }
  }

  Future<void> _handleResendVerification(AuthProvider authProvider) async {
    authProvider.clearError();

    bool success = await authProvider.resendVerificationEmail();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.email, color: Colors.white),
              SizedBox(width: 10.w),
              const Expanded(
                child: Text('Verification email sent successfully!'),
              ),
            ],
          ),
          backgroundColor: Constants.primaryColors,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
}
