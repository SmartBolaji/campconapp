import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  bool _isLinkingGoogle = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#\$&*~%^()_+={}\[\]|:;<>,.?/\\-]').hasMatch(password))
      strength += 0.25;
    return strength.clamp(0.0, 1.0);
  }

  Color _strengthColor(double strength) {
    if (strength < 0.4) return AppTheme.error;
    if (strength < 0.7) return AppTheme.warning;
    return AppTheme.success;
  }

  String _strengthLabel(double strength) {
    if (strength < 0.4) return 'Weak';
    if (strength < 0.7) return 'Moderate';
    return 'Strong';
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception('No user');

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        showFloatingSnackBar(context, 'Password changed successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg;
        switch (e.code) {
          case 'wrong-password':
            msg = 'Current password is incorrect.';
            break;
          case 'weak-password':
            msg = 'New password is too weak.';
            break;
          case 'requires-recent-login':
            msg = 'Please log out and log back in, then try again.';
            break;
          default:
            msg = e.message ?? 'Failed to change password.';
        }
        showFloatingSnackBar(context, msg, backgroundColor: AppTheme.error);
      }
    } catch (e) {
      if (mounted) {
        showFloatingSnackBar(context, 'An error occurred.',
            backgroundColor: AppTheme.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _linkGoogleAccount() async {
    setState(() => _isLinkingGoogle = true);
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLinkingGoogle = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
      if (mounted) {
        showFloatingSnackBar(context, 'Google account linked successfully');
        setState(() {});
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg = e.code == 'credential-already-in-use'
            ? 'This Google account is already linked to another account.'
            : (e.message ?? 'Failed to link Google account.');
        showFloatingSnackBar(context, msg, backgroundColor: AppTheme.error);
      }
    } catch (e) {
      debugPrint('Link Google error: $e');
    } finally {
      if (mounted) setState(() => _isLinkingGoogle = false);
    }
  }

  Future<void> _unlinkProvider(String providerId) async {
    setState(() => _isLinkingGoogle = true);
    try {
      await FirebaseAuth.instance.currentUser!.unlink(providerId);
      if (mounted) {
        showFloatingSnackBar(context,
            '${providerId == 'google.com' ? 'Google' : 'Email'} account unlinked');
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        showFloatingSnackBar(context, 'Failed to unlink account.',
            backgroundColor: AppTheme.error);
      }
    } finally {
      if (mounted) setState(() => _isLinkingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final providers = firebaseUser?.providerData ?? [];
    final hasEmail = providers.any((p) => p.providerId == 'password');
    final hasGoogle = providers.any((p) => p.providerId == 'google.com');
    final canUnlinkEmail = hasEmail && providers.length > 1;
    final canUnlinkGoogle = hasGoogle && providers.length > 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                    child: Iconify(Ph.arrow_left,
                        color: AppTheme.textPrimary, size: 24.sp),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Password & Security',
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
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  SizedBox(height: 8.h),

                  // Change Password Section
                  _buildSectionHeader('Change Password'),
                  SizedBox(height: 8.h),

                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current password
                          _buildPasswordField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                            obscure: _obscureCurrent,
                            onToggle: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Enter current password'
                                : null,
                          ),
                          SizedBox(height: 12.h),

                          // New password
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _newPasswordController,
                            builder: (_, value, __) {
                              final strength = _getPasswordStrength(value.text);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPasswordField(
                                    controller: _newPasswordController,
                                    label: 'New Password',
                                    obscure: _obscureNew,
                                    onToggle: () => setState(
                                        () => _obscureNew = !_obscureNew),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Enter new password'
                                        : v.length < 8
                                            ? 'Minimum 8 characters'
                                            : null,
                                  ),
                                  if (value.text.isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            child: LinearProgressIndicator(
                                              value: strength,
                                              backgroundColor: AppTheme.border,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                _strengthColor(strength),
                                              ),
                                              minHeight: 4.h,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _strengthLabel(strength),
                                          style:
                                              TextConstants.smallText.copyWith(
                                            fontSize: 11.sp,
                                            color: _strengthColor(strength),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 12.h),

                          // Confirm password
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirm your new password';
                              }
                              if (v != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: _isSaving
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Change Password',
                                      style: TextConstants.mediumText.copyWith(
                                        color: AppTheme.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Sign-In Methods Section
                  _buildSectionHeader('Sign-In Methods'),
                  SizedBox(height: 8.h),

                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        // Email / Password
                        _buildProviderRow(
                          icon: Ph.envelope,
                          label: 'Email / Password',
                          isLinked: hasEmail,
                          canUnlink: canUnlinkEmail,
                          isLoading: _isLinkingGoogle,
                          onLink: null, // Email linking not supported here
                          onUnlink: hasEmail && canUnlinkEmail
                              ? () => _unlinkProvider('password')
                              : null,
                        ),
                        Divider(height: 20.h, color: AppTheme.border),

                        // Google
                        _buildProviderRow(
                          icon: Ph.google_logo,
                          label: 'Google',
                          isLinked: hasGoogle,
                          canUnlink: canUnlinkGoogle,
                          isLoading: _isLinkingGoogle,
                          onLink: !hasGoogle ? _linkGoogleAccount : null,
                          onUnlink: hasGoogle && canUnlinkGoogle
                              ? () => _unlinkProvider('google.com')
                              : null,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextConstants.mediumText.copyWith(
        color: AppTheme.textPrimary,
        fontSize: 14.sp,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextConstants.smallText.copyWith(
          color: AppTheme.textLight,
          fontSize: 12.sp,
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        suffixIcon: IconButton(
          icon: Iconify(
            obscure ? Ph.eye : Ph.eye_slash,
            color: AppTheme.textLight,
            size: 18.sp,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildProviderRow({
    required String icon,
    required String label,
    required bool isLinked,
    required bool canUnlink,
    required bool isLoading,
    VoidCallback? onLink,
    VoidCallback? onUnlink,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: isLinked
                ? AppTheme.primary.withValues(alpha: 0.1)
                : AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Iconify(
              icon,
              color: isLinked ? AppTheme.primary : AppTheme.textLight,
              size: 18.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isLinked ? 'Connected' : 'Not connected',
                style: TextConstants.smallText.copyWith(
                  fontSize: 11.sp,
                  color: isLinked ? AppTheme.success : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          SizedBox(
            height: 18.h,
            width: 18.w,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          )
        else if (isLinked && canUnlink)
          TextButton(
            onPressed: onUnlink,
            child: Text(
              'Unlink',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          )
        else if (!isLinked && onLink != null)
          TextButton(
            onPressed: onLink,
            child: Text(
              'Connect',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}
