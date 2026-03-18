import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PasswordSettings extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const PasswordSettings({required this.formKey, super.key});

  @override
  State<PasswordSettings> createState() => _PasswordSettingsState();
}

class _PasswordSettingsState extends State<PasswordSettings> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Choose a strong password to secure your account',
                //   style: TextConstants.smallText.copyWith(
                //     color: AppTheme.textSecondary,
                //   ),
                // ),
                // SizedBox(height: 25.h),

                // Password field
                CustomTxtfield(
                  label: 'Set your password',
                  hintText: 'Enter your password',
                  controller: authProvider.passwordController,
                  enabled: !authProvider.isLoading,
                  isPassword: true,
                  prefixIcon: null,
                  onChanged: (value) {
                    // Trigger rebuild to update requirements UI
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain at least one lowercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain at least one number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Password requirements
                // Container(
                //   padding: EdgeInsets.all(15.sp),
                //   decoration: BoxDecoration(
                //     color: AppTheme.buttonBorder.withValues(alpha: 0.3),
                //     borderRadius: BorderRadius.circular(12.r),
                //     border: Border.all(
                //       color: AppTheme.textLight,
                //       width: 1,
                //     ),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Password Requirements:',
                //         style: TextConstants.smallText.copyWith(
                //           fontWeight: FontWeight.bold,
                //           color: AppTheme.textPrimary,
                //         ),
                //       ),
                //       SizedBox(height: 8.h),
                //       _buildRequirement(
                //         'At least 8 characters',
                //         authProvider.passwordController.text.length >= 8,
                //       ),
                //       _buildRequirement(
                //         'One uppercase letter (A-Z)',
                //         RegExp(r'[A-Z]')
                //             .hasMatch(authProvider.passwordController.text),
                //       ),
                //       _buildRequirement(
                //         'One lowercase letter (a-z)',
                //         RegExp(r'[a-z]')
                //             .hasMatch(authProvider.passwordController.text),
                //       ),
                //       _buildRequirement(
                //         'One number (0-9)',
                //         RegExp(r'[0-9]')
                //             .hasMatch(authProvider.passwordController.text),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
