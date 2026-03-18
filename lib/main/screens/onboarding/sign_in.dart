import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/onboarding/create_account.dart';
import 'package:campcon/main/screens/main_screen.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:campcon/main/widgets/sheet_widget.dart';
import 'package:campcon/main/widgets/social_auth_button.dart';
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
                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                bool success =
                                    await authProvider.forgotPassword();
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
                            text: "Continue",
                            isLoading: authProvider.isLoading,
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
                              bool success =
                                  await authProvider.signInWithGoogle();
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
                                    child: const SignUpScreen(),
                                  );
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextConstants.smallText
                                      .copyWith(color: AppTheme.textLight),
                                  children: [
                                    TextSpan(
                                      text: 'Create account',
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
        // if (authProvider.isLoading) ...[
        //   Positioned.fill(
        //     child: Container(
        //       color: Colors.black.withValues(alpha: 0.18),
        //     ),
        //   ),
        //   Positioned.fill(
        //     child: Center(
        //       child: Container(
        //         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        //         decoration: BoxDecoration(
        //           color: AppTheme.surface,
        //           borderRadius: BorderRadius.circular(16.r),
        //         ),
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             CircularProgressIndicator(color: AppTheme.primary),
        //             SizedBox(height: 12.h),
        //             Text(
        //               'Signing you in...',
        //               style: TextConstants.smallText.copyWith(
        //                 color: AppTheme.textSecondary,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ],
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
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
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
