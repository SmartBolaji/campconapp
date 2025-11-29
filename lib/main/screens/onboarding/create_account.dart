import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/screens/main_screen.dart';
import 'package:campcon/main/screens/onboarding/account_setUp.dart';
import 'package:campcon/main/screens/onboarding/verification_screen.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
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

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          color: AppTheme.surface,
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
                    SizedBox(height: 25.h),
                    CustomButton(
                      text: authProvider.isLoading ? "Sending..." : "Continue",
                      onPressed: authProvider.isLoading
                          ? () {}
                          : () => _handleCreateAccount(context, authProvider),
                      backgroundColor: AppTheme.primaryDark,
                      textColor: AppTheme.textPrimary,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.border)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("OR", style: TextConstants.smallText),
                        ),
                        Expanded(child: Divider(color: AppTheme.border)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _SocialAuthButton(
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
                                builder: (context) => const AccountSetup(),
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
                    _SocialAuthButton(
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
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextConstants.smallText
                              .copyWith(color: AppTheme.textLight),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextConstants.smallText
                                  .copyWith(color: AppTheme.primary),
                            ),
                          ],
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
    );
  }

  Future<void> _handleCreateAccount(
      BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();

      bool success = await authProvider.createAccount();

      // remove the focus from text fields
      FocusScope.of(context).unfocus();

      if (success) {
        // Show success toast
        // showCustomToast(
        //   context,
        //   'Verification email sent! Check your inbox.',
        //   type: ToastType.success,
        // );

        // Navigate to verification screen
        await Future.delayed(const Duration(milliseconds: 500));
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

// Reusable Social Auth Button Widget
class _SocialAuthButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onPressed;

  const _SocialAuthButton({
    required this.text,
    this.icon,
    this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border, width: 1.5),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath!,
                    width: 24.w,
                    height: 24.h,
                  )
                else if (icon != null)
                  Icon(icon, size: 24.sp, color: AppTheme.textPrimary),
                SizedBox(width: 10.w),
                Text(
                  text,
                  style: TextConstants.smallText
                      .copyWith(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
