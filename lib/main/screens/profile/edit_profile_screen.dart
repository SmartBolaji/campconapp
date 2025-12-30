import 'dart:async';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _aboutMeController;

  String? _originalUsername;
  Timer? _debounceTimer;

  // Notifies parts of the UI when controller values change (avoids setState)
  final ValueNotifier<int> _formNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? user = authProvider.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController =
        TextEditingController(text: '@${user?.username ?? ''}');
    _aboutMeController = TextEditingController(text: user?.aboutMe ?? '');
    _originalUsername = user?.username;

    // Listeners increment the notifier so UI rebuilds where needed (no setState)
    _nameController.addListener(() {
      _formNotifier.value++;
    });

    _aboutMeController.addListener(() {
      _formNotifier.value++;
    });

    // Username listener enforces leading @, caret rules and triggers debounce check
    _usernameController.addListener(_onUsernameEditedAndCheck);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _usernameController.removeListener(_onUsernameEditedAndCheck);
    _usernameController.dispose();
    _aboutMeController.dispose();
    _formNotifier.dispose();
    super.dispose();
  }

  // Enforce leading '@' and caret placement. Then run debounced availability check.
  void _onUsernameEditedAndCheck() {
    final raw = _usernameController.text;
    final sel = _usernameController.selection;

    String cleaned = raw;
    if (cleaned.isEmpty) {
      cleaned = '@';
    } else if (!cleaned.startsWith('@')) {
      final withoutAt = cleaned.replaceAll('@', '');
      cleaned = '@' + withoutAt;
    }

    int offset = sel.baseOffset;
    if (offset <= 0) offset = 1;
    if (offset > cleaned.length) offset = cleaned.length;

    if (cleaned != raw) {
      _usernameController.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: offset),
      );
    } else {
      if (_usernameController.selection.start < 1) {
        _usernameController.selection =
            const TextSelection.collapsed(offset: 1);
      }
    }

    // Trigger UI rebuild via notifier (no setState)
    _formNotifier.value++;

    // Debounce (300ms) then call provider directly (provider no longer delays)
    final usernameForCheck =
        _usernameController.text.replaceFirst('@', '').trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (usernameForCheck.length >= 3 &&
          usernameForCheck != _originalUsername) {
        await authProvider.checkUsernameAvailability(usernameForCheck);
      } else {
        authProvider.resetUsernameCheck();
      }
      // notify UI after provider updates (Consumer will rebuild)
      _formNotifier.value++;
    });
  }

  // Open image picker sheet (provider manages picked file)
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
                _formNotifier.value++; // notify UI of image change
              },
            ),
            SizedBox(height: 12.h),
            _buildImageOption(
              icon: Ph.image,
              title: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(context);
                await authProvider.pickProfileImage(fromCamera: false);
                _formNotifier.value++; // notify UI of image change
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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final username = _usernameController.text.replaceFirst('@', '').trim();

    // If username changed, but a check is running, wait briefly (max ~3s)
    if (authProvider.isCheckingUsername) {
      int waited = 0;
      while (authProvider.isCheckingUsername && waited < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited++;
      }
    }

    // If username changed and availability is not confirmed true, block save
    final currentUser = authProvider.currentUser;
    final currentUsername = currentUser?.username ?? '';
    if (currentUser != null &&
        username.toLowerCase() != currentUsername.toLowerCase()) {
      if (authProvider.isUsernameAvailable != true) {
        showFloatingSnackBar(context, 'Please choose an available username');
        return;
      }
    }

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      username: username,
      aboutMe: _aboutMeController.text.trim(),
      newProfileImage: authProvider.profileImage,
      originalUsername: _originalUsername,
    );

    if (!mounted) return;

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

  Future<bool> _onWillPop() async {
    // compute hasChanges without setState
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    final nameChanged =
        _nameController.text.trim() != (currentUser?.name ?? '');
    final usernameChanged =
        _usernameController.text.replaceFirst('@', '').trim() !=
            (currentUser?.username ?? '');
    final aboutChanged =
        _aboutMeController.text.trim() != (currentUser?.aboutMe ?? '');
    final imageChanged = authProvider.profileImage != null;

    final hasChanges =
        nameChanged || usernameChanged || aboutChanged || imageChanged;

    if (!hasChanges) return true;

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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextConstants.smallText.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Top-level scaffold doesn't need to rebuild on controller changes.
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Edit Profile',
            style: TextConstants.boldText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          leading: IconButton(
            icon: Iconify(Ph.arrow_left,
                color: AppTheme.textPrimary, size: 24.sp),
            onPressed: () async {
              final pop = await _onWillPop();
              if (pop) Navigator.of(context).pop();
            },
          ),
          actions: [
            // Rebuild the Save action when controllers or provider change
            ValueListenableBuilder<int>(
              valueListenable: _formNotifier,
              builder: (context, _, __) {
                return Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final currentUser = authProvider.currentUser;
                    final isLoading = authProvider.isLoading;

                    final nameChanged = _nameController.text.trim() !=
                        (currentUser?.name ?? '');
                    final usernameChanged =
                        _usernameController.text.replaceFirst('@', '').trim() !=
                            (currentUser?.username ?? '');
                    final aboutChanged = _aboutMeController.text.trim() !=
                        (currentUser?.aboutMe ?? '');
                    final imageChanged = authProvider.profileImage != null;

                    final hasChanges = nameChanged ||
                        usernameChanged ||
                        aboutChanged ||
                        imageChanged;

                    return TextButton(
                      onPressed:
                          (!hasChanges || isLoading) ? null : _saveProfile,
                      child: Text(
                        isLoading ? 'Saving...' : 'Save',
                        style: TextConstants.smallText.copyWith(
                          color: (!hasChanges || isLoading)
                              ? AppTheme.textLight
                              : AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(height: 1.h, color: AppTheme.border),
            Expanded(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      child: Form(
                        key: _formKey,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final UserModel? user = authProvider.currentUser;
                            final bool isLoading = authProvider.isLoading;

                            Widget profileImageWidget;
                            final picked = authProvider.profileImage;
                            if (picked != null) {
                              profileImageWidget = ClipOval(
                                child: Image.file(
                                  picked,
                                  width: 76.w,
                                  height: 76.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else if (user?.profileImageUrl != null &&
                                user!.profileImageUrl!.isNotEmpty) {
                              profileImageWidget = ClipOval(
                                child: Image.network(
                                  user.profileImageUrl!,
                                  width: 76.w,
                                  height: 76.w,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              profileImageWidget = Container(
                                width: 76.w,
                                height: 76.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.buttonBorder,
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                child: Center(
                                  child: Text(
                                    (user?.name != null &&
                                            user!.name!.isNotEmpty)
                                        ? user.name!
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '',
                                    style: TextConstants.mediumText.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontSize: 28.sp,
                                    ),
                                  ),
                                ),
                              );
                            }

                            // The form area rebuilds when notifier changes
                            return ValueListenableBuilder<int>(
                              valueListenable: _formNotifier,
                              builder: (context, _, __) {
                                final nameChanged =
                                    _nameController.text.trim() !=
                                        (user?.name ?? '');
                                final usernameChanged = _usernameController.text
                                        .replaceFirst('@', '')
                                        .trim() !=
                                    (user?.username ?? '');
                                final aboutChanged =
                                    _aboutMeController.text.trim() !=
                                        (user?.aboutMe ?? '');
                                final imageChanged =
                                    authProvider.profileImage != null;

                                final hasChanges = nameChanged ||
                                    usernameChanged ||
                                    aboutChanged ||
                                    imageChanged;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 12.h),

                                    // Avatar + change button
                                    Row(
                                      children: [
                                        profileImageWidget,
                                        SizedBox(width: 16.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user?.name ?? '',
                                              style: TextConstants.mediumText
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            InkWell(
                                              onTap: _pickImage,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 8.h),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Text(
                                                  'Change photo',
                                                  style: TextConstants.smallText
                                                      .copyWith(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 24.h),

                                    // Name field
                                    EditTextField(
                                      controller: _nameController,
                                      label: 'Name',
                                      hint: 'Your name',
                                      textInputAction: TextInputAction.next,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),

                                    SizedBox(height: 16.h),

                                    // Username field
                                    EditTextField(
                                      controller: _usernameController,
                                      label: 'Username',
                                      hint: '@username',
                                      textInputAction: TextInputAction.next,
                                      onChanged: (_) {
                                        // no-op here; listener already handles enforcement & debounce
                                      },
                                      validator: (v) {
                                        final value =
                                            v?.replaceFirst('@', '') ?? '';
                                        if (value.trim().length < 3) {
                                          return 'Username must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    _buildUsernameStatus(authProvider),

                                    SizedBox(height: 8.h),

                                    // Bio
                                    EditTextField(
                                      controller: _aboutMeController,
                                      label: 'Bio',
                                      hint: 'Tell people about yourself',
                                      maxLines: 5,
                                    ),

                                    SizedBox(height: 24.h),

                                    // Save button bottom (rebuilds when notifier changes)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: (!hasChanges || isLoading)
                                            ? null
                                            : _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                        ),
                                        child: Text(
                                          isLoading
                                              ? 'Saving...'
                                              : 'Save changes',
                                          style:
                                              TextConstants.smallText.copyWith(
                                            color: AppTheme.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 24.h),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameStatus(AuthProvider authProvider) {
    // Get current username from field (without @)
    final currentInput = _usernameController.text.replaceFirst('@', '').trim();

    // Don't show status if username is too short or same as original
    if (currentInput.length < 3 || currentInput == _originalUsername) {
      return const SizedBox.shrink();
    }

    // Show loading spinner while checking
    if (authProvider.isCheckingUsername) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h, left: 4.w, bottom: 12.h),
        child: Row(
          children: [
            SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Checking availability...',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (authProvider.isUsernameAvailable == true) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h, left: 4.w, bottom: 12.h),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success, size: 16.sp),
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
            Icon(Icons.cancel, color: AppTheme.error, size: 16.sp),
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

/// Reusable styled text field used in EditProfileScreen
class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EditTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines,
    this.textInputAction,
    this.validator,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          textInputAction: textInputAction ?? TextInputAction.done,
          maxLines: maxLines ?? 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextConstants.smallText.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: maxLines != null && maxLines! > 1 ? 12.h : 0),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
