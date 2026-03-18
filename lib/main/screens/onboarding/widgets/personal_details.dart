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
                      return 'Only letters, numbers and underscore';
                    }
                    if (authProvider.isUsernameAvailable == false) {
                      return 'Username is already taken';
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
                  suffixIconColor: authProvider.isCheckingUsername
                      ? AppTheme.textLight
                      : authProvider.isUsernameAvailable == true
                          ? AppTheme.success
                          : authProvider.isUsernameAvailable == false
                              ? AppTheme.error
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
              ],
            ),
          );
        },
      ),
    );
  }
}
