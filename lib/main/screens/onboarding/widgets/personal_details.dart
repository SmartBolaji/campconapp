// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_textfield.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:provider/provider.dart';

class PersonalDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const PersonalDetails({required this.formKey, super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                CustomTxtfield(
                  label: 'What is your name?',
                  hintText: 'Enter your full name',
                  controller: authProvider.nameController,
                  enabled: !authProvider.isLoading,
                  prefixIcon: null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
                CustomTxtfield(
                  label: 'Choose your username',
                  hintText: 'Enter username',
                  controller: authProvider.usernameController,
                  enabled: !authProvider.isLoading,
                  prefixIcon: null,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Username can only contain letters, numbers and underscore';
                    }
                    if (authProvider.isUsernameAvailable == false) {
                      return '';
                    }
                    return null;
                  },
                  suffixIcon:
                      authProvider.usernameController.text.trim().isEmpty
                          ? null
                          : authProvider.isCheckingUsername
                              ? Icons.autorenew
                              : authProvider.isUsernameAvailable == true
                                  ? Icons.check_circle
                                  : authProvider.isUsernameAvailable == false
                                      ? Icons.cancel
                                      : null,
                  onChanged: (value) async {
                    if (value.trim().length >= 3) {
                      await authProvider
                          .checkUsernameAvailability(value.trim());
                    } else {
                      authProvider.resetUsernameCheck();
                    }
                  },
                ),
                SizedBox(height: 8.h),

                // Username availability indicator
                if (authProvider.usernameController.text.trim().length >= 3)
                  _buildUsernameStatus(authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsernameStatus(AuthProvider authProvider) {
    if (authProvider.isCheckingUsername) {
      return Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.info),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Checking availability...',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      );
    }

    if (authProvider.isUsernameAvailable == true) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.success,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Username is available',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (authProvider.isUsernameAvailable == false) {
      return Row(
        children: [
          Icon(
            Icons.cancel,
            color: AppTheme.error,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Username is already taken',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
