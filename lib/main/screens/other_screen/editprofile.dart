import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  late final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _aboutMeController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? user = authProvider.currentUser;

    if (user != null) {
      _nameController = TextEditingController(text: user.name ?? '');
      _usernameController = TextEditingController(text: user.username ?? '');
      _aboutMeController = TextEditingController(text: user.aboutMe ?? '');
    } else {
      // Fallback if currentUser is somehow null (shouldn't happen if navigation is correct)
      _nameController = TextEditingController();
      _usernameController = TextEditingController();
      _aboutMeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _aboutMeController.dispose();
    // Do NOT dispose the controllers in AuthProvider, as they are managed there
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final UserModel? user = authProvider.currentUser;
          Widget profileImageWidget;
          if (authProvider.profileImage != null) {
            // New image picked but not yet saved
            profileImageWidget = ClipOval(
              child: Image.file(
                authProvider.profileImage!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            );
          } else if (user?.profileImageUrl != null) {
            // Existing image URL
            profileImageWidget = ClipOval(
              child: Image.network(
                user?.profileImageUrl ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 50,
                    color: Constants.textLight),
              ),
            );
          } else {
            // Default icon
            profileImageWidget =
                Icon(Icons.person, size: 50, color: Constants.textLight);
          }
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 10.sp, bottom: 20.sp),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Empty widget for spacing (to center title)
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
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 30.h),
                      GestureDetector(
                        onTap: authProvider.pickProfileImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Constants.backgroundColor,
                          child: profileImageWidget,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Edit profile picture",
                        style: TextConstants.smallText.copyWith(
                          color: Constants.textLight,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade500),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          children: [
                            EditTextField(
                              controller: _nameController,
                              label: "Name",
                              text: 'Name: ',
                            ),

                            // Username Field (Assuming Username is editable, but unique)
                            EditTextField(
                              controller: _usernameController,
                              label: "Username",
                              text: 'Username: ',
                            ),

                            // Bio Field
                            EditTextField(
                              controller: _aboutMeController,
                              label: "Bio",
                              maxLines: 4,
                              text: 'Bio: ',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        text: "Save",
                        onPressed: () {},
                        backgroundColor: Constants.primaryDark,
                        textColor: Constants.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Future<void> _saveProfile() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   // 1. Update AuthProvider's shared controllers with local changes
  //   authProvider.nameController.text = _nameController.text;
  //   authProvider.usernameController.text = _usernameController.text;
  //   authProvider.aboutmeController.text = _aboutMeController.text;

  //   // 2. Call the update logic
  //   final success = await authProvider.updateUserProfile();

  //   if (success) {
  //     // Show success message and dismiss the bottom sheet
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Profile updated successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     // Close the modal bottom sheet
  //     Navigator.pop(context);
  //   } else {
  //     // Show error message from AuthProvider
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content:
  //             Text(authProvider.errorMessage ?? 'Failed to update profile.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
}

class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isReadOnly;
  final int? maxLines;
  final String text;

  const EditTextField({
    required this.controller,
    required this.label,
    this.isReadOnly = false,
    required this.text,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Text(text, style: TextConstants.smallText),
          Expanded(
            child: TextField(),
          ),
        ],
      ),
    );
  }
}
