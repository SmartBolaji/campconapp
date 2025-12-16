import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/custom_toast.dart';
import 'package:campcon/main/widgets/sign_upflow.dart/set_password.dart';
import 'package:campcon/main/widgets/sign_upflow.dart/personal_details.dart';
import 'package:campcon/main/widgets/sign_upflow.dart/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AccountSetup extends StatefulWidget {
  const AccountSetup({super.key});

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  final _personalDetailsFormKey = GlobalKey<FormState>();
  final _setPasswordFormKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Constants.background,
  //     statusBarIconBrightness: Brightness.dark,
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: Container(
        color: Constants.background,
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
                      if (_currentStep > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 18.sp,
                      color: Constants.black,
                    ),
                  ),
                  Text(
                    "Set Up Your Account",
                    style: TextConstants.boldText.copyWith(
                      fontSize: 20.sp,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              SizedBox(height: 30.h),

              // Progress indicator
              Row(
                children: List.generate(_totalSteps * 2 - 1, (index) {
                  if (index.isOdd) {
                    return SizedBox(width: 3.w);
                  }

                  final stepIndex = index ~/ 2;
                  final isActive = stepIndex <= _currentStep;

                  return Expanded(
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppTheme.primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 30.h),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentStep = index),
                  children: [
                    PersonalDetails(formKey: _personalDetailsFormKey),
                    PasswordSettings(formKey: _setPasswordFormKey),
                    const ProfilePic(),
                  ],
                ),
              ),

              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  final isLastStep = _currentStep == _totalSteps - 1;

                  String buttonText = 'Continue';
                  if (isLastStep) {
                    if (provider.isLoading) {
                      if (provider.profileImage != null) {
                        buttonText = 'Uploading image...';
                      } else {
                        buttonText = 'Creating account...';
                      }
                    } else {
                      buttonText = 'Complete';
                    }
                  } else if (provider.isLoading) {
                    buttonText = 'Please wait...';
                  }

                  return Column(
                    children: [
                      CustomButton(
                        text: buttonText,
                        onPressed: provider.isLoading
                            ? () {}
                            : () => _handleContinue(context, provider),
                        backgroundColor: Constants.primaryDark,
                        textColor: Constants.black,
                        // useWidth: false,
                      ),
                      SizedBox(height: 20.h),
                      if (isLastStep && !provider.isLoading)
                        GestureDetector(
                          onTap: () => _handleSkip(context, provider),
                          child: Text(
                            "Skip for now",
                            style: TextConstants.smallText,
                          ),
                        ),
                      SizedBox(height: 30.h),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleContinue(
      BuildContext context, AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      // Validate personal details
      if (_personalDetailsFormKey.currentState?.validate() ?? false) {
        if (authProvider.isUsernameAvailable != true) {
          showCustomToast(
            context,
            'Please choose an available username',
            type: ToastType.error,
          );
          return;
        }
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      // Validate and update password
      if (_setPasswordFormKey.currentState?.validate() ?? false) {
        bool success = await authProvider.updatePassword(
          authProvider.passwordController.text,
        );

        if (success) {
          // if (mounted) {
          //   showCustomToast(
          //     context,
          //     'Password updated successfully!',
          //     type: ToastType.success,
          //   );
          // }

          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          if (mounted && authProvider.errorMessage != null) {
            showCustomToast(
              context,
              authProvider.errorMessage!,
              type: ToastType.error,
            );
          }
        }
      }
    } else if (_currentStep == _totalSteps - 1) {
      // Complete setup
      await _handleFinish(context, authProvider);
    }
  }

  Future<void> _handleFinish(
      BuildContext context, AuthProvider authProvider) async {
    authProvider.clearError();

    bool success = await authProvider.completeProfileSetup();

    if (success) {
      if (mounted) {
        // Navigate to main screen
        _navigateToMain(context);
      }
    } else {
      if (authProvider.errorMessage != null &&
          authProvider.errorMessage!.isNotEmpty) {
        if (mounted) {
          showCustomToast(
            context,
            authProvider.errorMessage!,
            type: ToastType.error,
          );
        }
      }
    }
  }

  Future<void> _handleSkip(
      BuildContext context, AuthProvider authProvider) async {
    bool success = await authProvider.completeProfileSetup();
    if (success && mounted) {
      _navigateToMain(context);
    }
  }

  void _navigateToMain(BuildContext context) {
    // Pop the account setup screen
    Navigator.of(context).pop();

    // Pop the create account bottom sheet
    Navigator.of(context).pop();

    // The AuthenticationWrapper will automatically navigate to MainScreen
  }
}
