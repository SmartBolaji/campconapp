import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_image_picker.dart';
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
  final FocusNode _contentFocusNode = FocusNode();
  double _pickerHeight = 0.35;
  final double _minPickerHeight = 0.25;
  final double _maxPickerHeight = 0.50;
  bool _isPickerExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaSelectionProvider>(context, listen: false)
          .clearSelection();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
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

    // ✅ Get user's campus
    final campus = currentUser.campus ?? '';
    if (campus.isEmpty) {
      _showError('Please select your campus first');
      return;
    }

    final content = _contentController.text.trim();
    final images = mediaProvider.selectedFiles;

    if (content.isEmpty && images.isEmpty) {
      _showError('Please add some content or images');
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Clear form immediately
    _contentController.clear();
    mediaProvider.clearSelection();

    // Close the screen
    Navigator.of(context).pop();

    // Start silent upload
    final success = await postProvider.createPostSilently(
      userId: currentUser.uid,
      username: currentUser.username,
      userProfileImage: currentUser.profileImageUrl ?? '',
      content: content,
      campus: campus, 
      images: images.isNotEmpty ? images : null,
    );

    debugPrint(success ? '✅ Post created silently' : '❌ Silent upload failed');
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

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaSelectionProvider>(context);
    final hasImages = mediaProvider.selectedImages.isNotEmpty ||
        mediaProvider.capturedImages.isNotEmpty;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      resizeToAvoidBottomInset: false,
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
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      FeatherIcons.x,
                      color: AppTheme.textPrimary,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.border,
            ),

            Expanded(
              child: Column(
                children: [
                  // Content area
                  Expanded(
                    flex: isKeyboardVisible ? 3 : 2,
                    child: SingleChildScrollView(
                      child: Container(
                        color: AppTheme.surface,
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasImages && isKeyboardVisible)
                              Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      FeatherIcons.image,
                                      size: 16.sp,
                                      color: AppTheme.primary,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${mediaProvider.selectedImages.length + mediaProvider.capturedImages.length} ${(mediaProvider.selectedImages.length + mediaProvider.capturedImages.length) == 1 ? "image" : "images"} selected',
                                      style: TextConstants.smallText.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: _contentController,
                              focusNode: _contentFocusNode,
                              maxLines: null,
                              minLines: isKeyboardVisible ? 10 : 5,
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
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Image Picker Section
                  if (!isKeyboardVisible)
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          final delta = -details.delta.dy /
                              MediaQuery.of(context).size.height;
                          _pickerHeight = (_pickerHeight + delta)
                              .clamp(_minPickerHeight, _maxPickerHeight);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height:
                            MediaQuery.of(context).size.height * _pickerHeight,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Column(
                          children: [
                            // Drag handle
                            // Container(
                            //   padding: EdgeInsets.symmetric(vertical: 8.h),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Container(
                            //         width: 40.w,
                            //         height: 4.h,
                            //         decoration: BoxDecoration(
                            //           color: AppTheme.border,
                            //           borderRadius: BorderRadius.circular(2.r),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            // Image picker
                            Expanded(
                              child: PostImagePicker(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Post Button
            Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: isKeyboardVisible ? keyboardHeight + 16.h : 16.h,
              ),
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
