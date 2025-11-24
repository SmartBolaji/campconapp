import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';

import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/main_screen.dart';

import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    Provider.of<AuthProvider>(context, listen: false).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sign In",
                        style: TextConstants.mediumText,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  CustomTxtfield(
                    label: 'Email or Phone number',
                    hintText: 'Enter your email or phone',
                    controller: authProvider.emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
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
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 8.h),

                  Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () async {
                          await authProvider.forgotPassword();
                        },
                        child: Text(
                          "Forget Password",
                          style: TextConstants.smallText
                              .copyWith(color: Constants.primaryColors),
                        ),
                      )),
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: authProvider.isLoading ? "Loading...." : "Continue",
                    onPressed: () => _handleSignIn(context, authProvider),
                    backgroundColor: Constants.primaryDark,
                    textColor: Constants.black,
                  ),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "OR",
                          style: TextConstants.smallText,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(25.r),
                    child: CustomButton(
                      text: "Continue with Google",
                      onPressed: () async {
                        bool success = await authProvider.signInWithGoogle();
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        } else {
                          if (authProvider.errorMessage != null &&
                              authProvider.errorMessage!.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProvider.errorMessage!),
                                backgroundColor: Constants.error,
                              ),
                            );
                          }
                        }
                      },
                      backgroundColor: Colors.transparent,
                      textColor: Constants.textPrimary,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(25.r),
                    child: CustomButton(
                      text: "Continue with Apple",
                      onPressed: () {},
                      backgroundColor: Colors.transparent,
                      textColor: Constants.textPrimary,
                    ),
                  ),
                  SizedBox(height: 60.h),

                  // Already have account
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextConstants.smallText
                            .copyWith(color: Constants.textLight),
                        children: [
                          TextSpan(
                            text: 'Create account',
                            style: TextConstants.smallText
                                .copyWith(color: Constants.primaryColors),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSignIn(
      BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      authProvider.clearError();

      bool success = await authProvider.signIn();
      if (success) {
        if (mounted) {
          // Close the bottom sheet
          Navigator.of(context).pop();

          // The AuthenticationWrapper will automatically navigate to MainScreen
          // because authProvider.isAuthenticated is now true
        }
      } else {
        if (authProvider.errorMessage != null &&
            authProvider.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Constants.error,
            ),
          );
        }
      }
    }
  }
}
