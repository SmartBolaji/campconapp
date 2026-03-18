import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/main_screen.dart';
import 'package:campcon/main/screens/onboarding/account_setUp.dart';
import 'package:campcon/main/screens/onboarding/sign_in.dart';
import 'package:campcon/main/screens/onboarding/verification_screen.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:campcon/main/widgets/sheet_widget.dart';
import 'package:campcon/main/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appColors = context.appColors;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: authProvider.isLoading,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                color: appColors.surface,
                padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Create Your \nCampcon Account",
                          style: TextConstants.mediumText,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          CustomTxtfield(
                            label: 'Email',
                            hintText: 'Enter your email',
                            controller: authProvider.emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: null,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          if ((authProvider.errorMessage ?? '').isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppTheme.error.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Text(
                                authProvider.errorMessage!,
                                style: TextConstants.smallText.copyWith(
                                  color: AppTheme.error,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 25.h),
                          CustomButton(
                            text: authProvider.isLoading
                                ? "Sending code..."
                                : "Continue",
                            onPressed: authProvider.isLoading
                                ? () {}
                                : () => _handleSendOTP(context, authProvider),
                            backgroundColor: AppTheme.primaryDark,
                            textColor: AppTheme.textPrimary,
                            useWidth: false,
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.border)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text("OR", style: TextConstants.smallText),
                              ),
                              Expanded(child: Divider(color: AppTheme.border)),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          SocialAuthButton(
                            text: "Continue with Google",
                            imagePath: 'assets/images/googleIcon.png',
                            onPressed: () async {
                              Map<String, dynamic> result =
                                  await authProvider.createAccountWithGoogle();

                              if (result['success']) {
                                if (result['needsProfileSetup']) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AccountSetup(
                                          // isGoogleSignUp: true,
                                          ),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen()),
                                  );
                                }
                              } else {
                                if (authProvider.errorMessage != null) {
                                  showCustomToast(
                                    context,
                                    authProvider.errorMessage!,
                                    type: ToastType.error,
                                  );
                                }
                              }
                            },
                          ),
                          SizedBox(height: 15.h),
                          SocialAuthButton(
                            text: "Continue with Apple",
                            icon: Icons.apple,
                            onPressed: () {
                              showCustomToast(
                                context,
                                'Apple sign-in coming soon!',
                                type: ToastType.info,
                              );
                            },
                          ),
                          SizedBox(height: 60.h),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                final navigator =
                                    Navigator.of(context, rootNavigator: true);
                                navigator.pop();
                                Future.delayed(Duration.zero, () {
                                  CustomBottomSheet.show(
                                    context: navigator.context,
                                    barrierColor: const Color(0xFFE1AF4B),
                                    child: const SignIn(),
                                  );
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextConstants.smallText
                                      .copyWith(color: AppTheme.textLight),
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextConstants.smallText.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (authProvider.isLoading) ...[
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.18))),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 12.h),
                    Text(
                      'Preparing your account...',
                      style: TextConstants.smallText.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleSendOTP(
      BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();
      FocusScope.of(context).unfocus();

      bool success = await authProvider.sendEmailOTP();

      if (success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        }
      } else {
        if (authProvider.errorMessage != null) {
          showCustomToast(
            context,
            authProvider.errorMessage!,
            type: ToastType.error,
          );
        }
      }
    }
  }
}
