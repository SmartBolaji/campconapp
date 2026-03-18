import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                if (user == null)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      children: [
                        SizedBox(height: 8.h),
                        _buildSectionHeader('Personal'),
                        SizedBox(height: 8.h),
                        _buildInfoCard(
                          icon: Ph.user,
                          label: 'Full Name',
                          value: user.name ?? '—',
                        ),
                        SizedBox(height: 8.h),
                        _buildInfoCard(
                          icon: Ph.at,
                          label: 'Username',
                          value: '@${user.username}',
                        ),
                        SizedBox(height: 8.h),
                        _buildInfoCard(
                          icon: Ph.envelope,
                          label: 'Email Address',
                          value: user.email,
                        ),
                        SizedBox(height: 8.h),
                        _buildEditableCard(
                          context: context,
                          icon: Ph.phone,
                          label: 'Phone Number',
                          value: user.phoneNumber.isNotEmpty
                              ? user.phoneNumber
                              : 'Not set',
                          onTap: () =>
                              _showPhoneEditDialog(context, user, authProvider),
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Account Details'),
                        SizedBox(height: 8.h),
                        _buildInfoCard(
                          icon: Ph.calendar,
                          label: 'Member Since',
                          value: DateFormat('MMMM d, y').format(user.createdAt),
                        ),
                        SizedBox(height: 8.h),
                        _buildInfoCard(
                          icon: Ph.student,
                          label: 'Account Type',
                          value: (user.isStudent == true)
                              ? 'Student'
                              : 'Non-Student',
                        ),
                        if (user.campus != null && user.campus!.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          _buildInfoCard(
                            icon: Ph.buildings,
                            label: 'Campus',
                            value: user.campus!,
                          ),
                        ],
                        if (user.level != null && user.level!.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          _buildInfoCard(
                            icon: Ph.graduation_cap,
                            label: 'Level',
                            value: user.level!,
                          ),
                        ],
                        if (user.department != null &&
                            user.department!.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          _buildInfoCard(
                            icon: Ph.bookmarks,
                            label: 'Department',
                            value: user.department!,
                          ),
                        ],
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Connected Accounts'),
                        SizedBox(height: 8.h),
                        _buildConnectedAccounts(context),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Account Information',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Text(
        title,
        style: TextConstants.smallText.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Iconify(icon, color: AppTheme.primary, size: 20.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 11.sp,
                    color: AppTheme.textLight,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Iconify(icon, color: AppTheme.primary, size: 20.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Iconify(
              Ph.pencil_simple,
              color: AppTheme.textLight,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccounts(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final providers = firebaseUser?.providerData ?? [];
    final hasEmail = providers.any((p) => p.providerId == 'password');
    final hasGoogle = providers.any((p) => p.providerId == 'google.com');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign-in methods',
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (hasEmail)
                _buildProviderChip(icon: Ph.envelope, label: 'Email'),
              if (hasGoogle)
                _buildProviderChip(icon: Ph.google_logo, label: 'Google'),
              if (!hasEmail && !hasGoogle)
                Text(
                  'No sign-in providers found',
                  style: TextConstants.smallText.copyWith(
                    color: AppTheme.textLight,
                    fontSize: 13.sp,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChip({
    required String icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, size: 16.sp, color: AppTheme.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhoneEditDialog(
      BuildContext context, UserModel user, AuthProvider authProvider) {
    final controller = TextEditingController(
        text: user.phoneNumber.isNotEmpty ? user.phoneNumber : '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                'Edit Phone Number',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: TextConstants.mediumText.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: '+234 800 000 0000',
                    hintStyle: TextConstants.smallText.copyWith(
                      color: AppTheme.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final phone = controller.text.trim();
                          setState(() => isSaving = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'phoneNumber': phone});
                            // Update local user
                            final updated = user.copyWith(phoneNumber: phone);
                            authProvider.updateCurrentUser(updated);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              showFloatingSnackBar(
                                  context, 'Phone number updated');
                            }
                          } catch (e) {
                            debugPrint('Phone update error: $e');
                            if (context.mounted) {
                              showFloatingSnackBar(
                                  context, 'Failed to update phone number',
                                  backgroundColor: Colors.red);
                            }
                          } finally {
                            setState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? SizedBox(
                          height: 16.h,
                          width: 16.w,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: TextConstants.smallText.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
