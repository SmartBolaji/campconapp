import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/onboarding/account_setUp.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the OTP input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final appColors = context.appColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: appColors.background,
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 70.sp),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              authProvider.clearError();
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 18.sp,
                              color: appColors.textPrimary,
                            ),
                          ),
                          Text(
                            "Enter Verification Code",
                            style: TextConstants.boldText.copyWith(
                              fontSize: 20.sp,
                            ),
                          ),
                          const SizedBox(width: 24),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      // Instruction Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "We sent a 6-digit code to\n",
                          style: TextConstants.smallText.copyWith(
                            color: appColors.textLight,
                            fontSize: 15.sp,
                          ),
                          children: [
                            TextSpan(
                              text: authProvider.emailController.text,
                              style: TextConstants.smallText.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 35.h),

                      // OTP Input using Pinput
                      Pinput(
                        controller: _otpController,
                        focusNode: _focusNode,
                        length: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        defaultPinTheme: PinTheme(
                          width: 50.w,
                          height: 55.h,
                          textStyle: TextConstants.boldText.copyWith(
                            fontSize: 22.sp,
                            color: appColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: appColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 50.w,
                          height: 55.h,
                          textStyle: TextConstants.boldText.copyWith(
                            fontSize: 22.sp,
                            color: appColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: appColors.textLight,
                              width: 2,
                            ),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 50.w,
                          height: 55.h,
                          textStyle: TextConstants.boldText.copyWith(
                            fontSize: 22.sp,
                            color: appColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: appColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: appColors.textLight,
                              width: 1,
                            ),
                          ),
                        ),
                        errorPinTheme: PinTheme(
                          width: 50.w,
                          height: 55.h,
                          textStyle: TextConstants.boldText.copyWith(
                            fontSize: 22.sp,
                            color: AppTheme.error,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppTheme.error,
                              width: 1,
                            ),
                          ),
                        ),
                        onCompleted: (code) {
                          // Auto-verify when 6 digits entered
                          _handleVerifyOTP(authProvider);
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Error message
                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 15.h),
                          child: Container(
                            padding: EdgeInsets.all(12.sp),
                            decoration: BoxDecoration(
                              color: Constants.error.withValues(alpha: 0.1),
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

                      SizedBox(height: 15.h),

                      // Resend Code section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (authProvider.canResend)
                            Text(
                              "Didn't receive the code? ",
                              style: TextConstants.smallText.copyWith(
                                color: Constants.textLight,
                                fontSize: 14.sp,
                              ),
                            ),
                          GestureDetector(
                            onTap: authProvider.canResend &&
                                    !authProvider.isLoading
                                ? () => _handleResendOTP(authProvider)
                                : null,
                            child: Text(
                              authProvider.canResend
                                  ? "Resend"
                                  : "Resend in ${authProvider.resendCountdown}s",
                              style: TextConstants.smallText.copyWith(
                                color: authProvider.canResend
                                    ? Constants.primaryColors
                                    : Constants.textLight,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40.h),

                      // Verify Button
                      CustomButton(
                        text:
                            authProvider.isLoading ? "Verifying..." : "Verify",
                        onPressed: authProvider.isLoading
                            ? () {}
                            : () => _handleVerifyOTP(authProvider),
                        backgroundColor: Constants.primaryDark,
                        textColor: Constants.black,
                        useWidth: false,
                      ),
                      SizedBox(height: 25.h),

                      // Help text
                      // Container(
                      //   padding: EdgeInsets.all(15.sp),
                      //   decoration: BoxDecoration(
                      //     color: Constants.primarybackground.withValues(alpha: 0.3),
                      //     borderRadius: BorderRadius.circular(12.r),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.info_outline,
                      //           color: Constants.primaryColors, size: 20.sp),
                      //       SizedBox(width: 10.w),
                      //       Expanded(
                      //         child: Text(
                      //           "The verification code will arrive within a few seconds. If you don't see it, check your spam folder.",
                      //           style: TextConstants.smallText.copyWith(
                      //             fontSize: 12.sp,
                      //             color: Constants.textSecondary,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleVerifyOTP(AuthProvider authProvider) async {
    String otp = _otpController.text.trim();

    if (otp.length != 6) {
      authProvider.setError('Please enter the complete 6-digit code');
      return;
    }

    authProvider.clearError();

    bool success = await authProvider.verifyEmailOTP(otp);

    if (success && mounted) {
      showCustomToast(
        context,
        'Email verified successfully!',
        type: ToastType.success,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AccountSetup()),
        );
      }
    } else {
      // Clear the OTP field on error
      _otpController.clear();
      _focusNode.requestFocus();
    }
  }

  Future<void> _handleResendOTP(AuthProvider authProvider) async {
    authProvider.clearError();
    _otpController.clear();

    bool success = await authProvider.resendOTP();

    if (success && mounted) {
      showCustomToast(
        context,
        'Verification code sent!',
        type: ToastType.success,
      );
      _focusNode.requestFocus();
    }
  }
}
