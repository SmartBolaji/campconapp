import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/screens/bottonnavbarscreens/post_folder/post_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  double _pickerHeight = 0.35; // 35% of screen height
  final double _minPickerHeight = 0.25;
  final double _maxPickerHeight = 0.50;
  bool _isPickerExpanded = true;

  @override
  void initState() {
    super.initState();
    // Clear previous selections when opening new post
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaSelectionProvider>(context, listen: false)
          .clearSelection();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mediaProvider =
        Provider.of<MediaSelectionProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    final content = _contentController.text.trim();
    final images = mediaProvider.selectedFiles;

    if (content.isEmpty && images.isEmpty) {
      _showError('Please add some content or images');
      return;
    }

    // Show loading dialog
    _showLoadingDialog();

    final success = await postProvider.createPost(
      userId: currentUser.uid,
      username: currentUser.username,
      userProfileImage: currentUser.profileImageUrl ?? '',
      content: content,
      images: images.isNotEmpty ? images : null,
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        // Clear form
        _contentController.clear();
        mediaProvider.clearSelection();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Go back to home
        Navigator.of(context).pop(true);
      } else {
        _showError(postProvider.errorMessage ?? 'Failed to create post');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<PostProvider>(
        builder: (context, provider, child) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primary,
                      value: provider.isUploadingImages
                          ? provider.uploadProgress
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      provider.isUploadingImages
                          ? 'Uploading images...\n${(provider.uploadProgress * 100).toInt()}%'
                          : 'Creating post...',
                      textAlign: TextAlign.center,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _togglePicker() {
    setState(() {
      if (_isPickerExpanded) {
        _pickerHeight = _minPickerHeight;
      } else {
        _pickerHeight = _maxPickerHeight;
      }
      _isPickerExpanded = !_isPickerExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaSelectionProvider>(context);
    final hasImages = mediaProvider.selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppTheme.surface,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Post',
                    style: TextConstants.boldText.copyWith(
                      fontSize: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      FeatherIcons.x,
                      color: AppTheme.textPrimary,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.border,
            ),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: AppTheme.surface,
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 5,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Say something...',
                      hintStyle: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textLight,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // Image Picker Section
            GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  final delta =
                      -details.delta.dy / MediaQuery.of(context).size.height;
                  _pickerHeight = (_pickerHeight + delta)
                      .clamp(_minPickerHeight, _maxPickerHeight);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: MediaQuery.of(context).size.height * _pickerHeight,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Container(
                          //   width: 40.w,
                          //   height: 4.h,
                          //   decoration: BoxDecoration(
                          //     color: AppTheme.border,
                          //     borderRadius: BorderRadius.circular(2.r),
                          //   ),
                          // ),
                          // SizedBox(width: 8.w),
                          // GestureDetector(
                          //   onTap: _togglePicker,
                          //   child: Icon(
                          //     _isPickerExpanded
                          //         ? FeatherIcons.chevronDown
                          //         : FeatherIcons.chevronUp,
                          //     size: 20.sp,
                          //     color: AppTheme.textSecondary,
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Image picker
                    const Expanded(
                      child: PostImagePicker(),
                    ),
                  ],
                ),
              ),
            ),

            // Post Button
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.border,
                    width: 1,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: _createPost,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(40.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Post',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
