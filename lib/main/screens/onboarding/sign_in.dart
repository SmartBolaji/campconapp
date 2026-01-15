import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/main_screen.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Don't dispose provider controllers here - they're managed by the provider
    super.dispose();
  }

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
                    "Sign In",
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
                      label: 'Email or username',
                      hintText: 'Enter your email or username',
                      controller: authProvider.emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: null,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email or username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.h),
                    CustomTxtfield(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: authProvider.passwordController,
                      isPassword: true,
                      prefixIcon: null,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          bool success = await authProvider.forgotPassword();
                          if (success) {
                            showCustomToast(
                              context,
                              'Password reset email sent! Check your inbox.',
                              type: ToastType.success,
                            );
                          } else if (authProvider.errorMessage != null) {
                            showCustomToast(
                              context,
                              authProvider.errorMessage!,
                              type: ToastType.error,
                            );
                          }
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextConstants.smallText.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text:
                          authProvider.isLoading ? "Signing In..." : "Continue",
                      onPressed: authProvider.isLoading
                          ? () {}
                          : () => _handleSignIn(context, authProvider),
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
                        bool success = await authProvider.signInWithGoogle();
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        } else {
                          if (authProvider.errorMessage != null &&
                              authProvider.errorMessage!.isNotEmpty) {
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
                          text: "Don't have an account? ",
                          style: TextConstants.smallText
                              .copyWith(color: AppTheme.textLight),
                          children: [
                            TextSpan(
                              text: 'Create account',
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

  Future<void> _handleSignIn(
      BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();

      // Remove focus from text fields
      FocusScope.of(context).unfocus();

      bool success = await authProvider.signIn();
      if (success) {
        if (mounted) {
          // Use root navigator to pop all routes back to the main app root
          // This ensures we exit any bottom sheets/dialogs first
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        }
      } else {
        if (authProvider.errorMessage != null &&
            authProvider.errorMessage!.isNotEmpty) {
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
