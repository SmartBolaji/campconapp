import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _aboutMeController;

  bool _hasChanges = false;
  File? _newProfileImage;
  String? _originalUsername;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? user = authProvider.currentUser;

    if (user != null) {
      _nameController = TextEditingController(text: user.name ?? '');
      // Add @ prefix to username
      _usernameController =
          TextEditingController(text: '@${user.username ?? ''}');
      _aboutMeController = TextEditingController(text: user.aboutMe ?? '');
      _originalUsername = user.username;
    } else {
      _nameController = TextEditingController();
      _usernameController = TextEditingController(text: '@');
      _aboutMeController = TextEditingController();
    }

    // Listen for changes
    _nameController.addListener(_checkForChanges);
    _usernameController.addListener(_checkForChanges);
    _aboutMeController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      // Remove @ prefix when comparing
      final currentUsername = _usernameController.text.replaceFirst('@', '');

      setState(() {
        _hasChanges = _nameController.text.trim() != (user.name ?? '') ||
            currentUsername.trim() != (user.username ?? '') ||
            _aboutMeController.text.trim() != (user.aboutMe ?? '') ||
            _newProfileImage != null;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  // Debounced username check
  void _onUsernameChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Remove @ prefix for checking
    final username = value.replaceFirst('@', '').trim();

    // Start new timer (500ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (username.length >= 3 && username != _originalUsername) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.checkUsernameAvailability(username);
      } else {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.resetUsernameCheck();
      }
    });
  }

  Future<void> _pickImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Choose Profile Picture',
              style: TextConstants.mediumText.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            _buildImageOption(
              icon: Ph.camera,
              title: 'Take Photo',
              onTap: () async {
                Navigator.pop(context);
                await authProvider.pickProfileImage(fromCamera: true);
                if (authProvider.profileImage != null) {
                  setState(() {
                    _newProfileImage = authProvider.profileImage;
                    _hasChanges = true;
                  });
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildImageOption(
              icon: Ph.image,
              title: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(context);
                await authProvider.pickProfileImage(fromCamera: false);
                if (authProvider.profileImage != null) {
                  setState(() {
                    _newProfileImage = authProvider.profileImage;
                    _hasChanges = true;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Iconify(
                icon,
                color: AppTheme.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextConstants.smallText.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Remove @ prefix for saving
    final username = _usernameController.text.replaceFirst('@', '').trim();

    // Check if username is available (if changed)
    if (username.toLowerCase() != _originalUsername) {
      if (authProvider.isUsernameAvailable != true) {
        showFloatingSnackBar(context, 'Please choose an available username');
        return;
      }
    }

    bool success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      username: username,
      aboutMe: _aboutMeController.text.trim(),
      newProfileImage: _newProfileImage,
      originalUsername: _originalUsername,
    );

    if (mounted) {
      if (success) {
        showFloatingSnackBar(context, 'Profile updated successfully!');
        Navigator.pop(context, true);
      } else {
        showFloatingSnackBar(
          context,
          authProvider.errorMessage ?? 'Failed to update profile',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldDiscard = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Text(
                'Discard Changes?',
                style: TextConstants.mediumText.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: Text(
                'You have unsaved changes. Are you sure you want to discard them?',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                  ),
                  child: Text(
                    'Discard',
                    style: TextConstants.smallText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
          return shouldDiscard ?? false;
        }
        return true;
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final UserModel? user = authProvider.currentUser;
              final bool isLoading = authProvider.isLoading;

              Widget profileImageWidget;
              if (_newProfileImage != null) {
                profileImageWidget = ClipOval(
                  child: Image.file(
                    _newProfileImage!,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
                );
              } else if (user?.profileImageUrl != null &&
                  user!.profileImageUrl!.isNotEmpty) {
                profileImageWidget = ClipOval(
                  child: Image.network(
                    user.profileImageUrl!,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Iconify(
                        Ph.user,
                        size: 40.sp,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                );
              } else {
                profileImageWidget = Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Iconify(
                    Ph.user,
                    size: 40.sp,
                    color: AppTheme.primary,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: 10.sp, bottom: 20.sp),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 40.w),
                              Text(
                                "Edit profile",
                                style: TextConstants.smallText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: 30.h),

                          // Avatar with camera overlay
                          GestureDetector(
                            onTap: isLoading ? null : _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40.r,
                                    backgroundColor: Colors.transparent,
                                    child: profileImageWidget,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Iconify(
                                      Ph.camera,
                                      size: 16.sp,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 8.h),
                          Text(
                            "Edit profile picture",
                            style: TextConstants.smallText.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Form Fields Container
                          Container(
                            padding: EdgeInsets.all(15.sp),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppTheme.textLight
                                      .withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Column(
                              children: [
                                // Name Field
                                EditTextField(
                                  controller: _nameController,
                                  label: "Name",
                                  text: 'Name: ',
                                  enabled: !isLoading,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Name is required';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),

                                // Username Field with availability check
                                EditTextField(
                                  controller: _usernameController,
                                  label: "Username",
                                  text: 'Username: ',
                                  enabled: !isLoading,
                                  isUsername: true,
                                  onChanged: _onUsernameChanged,
                                  validator: (value) {
                                    final username =
                                        value?.replaceFirst('@', '').trim() ??
                                            '';

                                    if (username.isEmpty) {
                                      return 'Username is required';
                                    }
                                    if (username.length < 3) {
                                      return 'Username must be at least 3 characters';
                                    }
                                    if (!RegExp(r'^[a-zA-Z0-9_]+$')
                                        .hasMatch(username)) {
                                      return 'Username can only contain letters, numbers and underscore';
                                    }
                                    return null;
                                  },
                                ),

                                // Username availability indicator
                                if (() {
                                  final username = _usernameController.text
                                      .replaceFirst('@', '')
                                      .trim();
                                  return username.length >= 3 &&
                                      username != _originalUsername;
                                }())
                                  _buildUsernameStatus(authProvider),

                                // Bio Field
                                EditTextField(
                                  controller: _aboutMeController,
                                  label: "Bio",
                                  maxLines: 4,
                                  maxLength: 150,
                                  text: 'Bio: ',
                                  enabled: !isLoading,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Save Button
                          CustomButton(
                            text: isLoading ? "Saving..." : "Save",
                            onPressed: isLoading || !_hasChanges
                                ? () {}
                                : _saveProfile,
                            backgroundColor: _hasChanges && !isLoading
                                ? AppTheme.primary
                                : AppTheme.textLight,
                            textColor: AppTheme.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStatus(AuthProvider authProvider) {
    if (authProvider.isUsernameAvailable == true) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h, left: 4.w, bottom: 12.h),
        child: Row(
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
        ),
      );
    }

    if (authProvider.isUsernameAvailable == false) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h, left: 4.w, bottom: 12.h),
        child: Row(
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
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isReadOnly;
  final int? maxLines;
  final int? maxLength;
  final String text;
  final bool enabled;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool isUsername;

  const EditTextField({
    required this.controller,
    required this.label,
    this.isReadOnly = false,
    required this.text,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.isUsername = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: label == "Bio"
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextConstants.smallText.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textLight,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextFormField(
                    controller: controller,
                    enabled: enabled,
                    readOnly: isReadOnly,
                    maxLines: maxLines ?? 1,
                    maxLength: maxLength,
                    onChanged: onChanged,
                    inputFormatters: isUsername
                        ? [
                            // Prevent @ from being deleted
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              // Always ensure @ is at the start
                              if (!newValue.text.startsWith('@')) {
                                return TextEditingValue(
                                  text: '@${newValue.text.replaceAll('@', '')}',
                                  selection: TextSelection.collapsed(
                                    offset: newValue.selection.end + 1,
                                  ),
                                );
                              }
                              return newValue;
                            }),
                          ]
                        : null,
                    style: TextConstants.smallText.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                      ),
                      border: InputBorder.none,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppTheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: AppTheme.error, width: 2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            BorderSide(color: AppTheme.border.withOpacity(0.5)),
                      ),
                      suffixIcon: suffixIcon != null
                          ? Icon(
                              suffixIcon,
                              size: 20.sp,
                              color: suffixIcon == Icons.check_circle
                                  ? AppTheme.success
                                  : suffixIcon == Icons.cancel
                                      ? AppTheme.error
                                      : AppTheme.info,
                            )
                          : null,
                      counterStyle: TextConstants.smallText.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 11.sp,
                      ),
                    ),
                    validator: validator,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider line under each field
        if (label != 'Bio')
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
            child: Divider(
              color: AppTheme.textLight.withValues(alpha: 0.3),
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }
}
