import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/media_provider.dart';
import 'package:campcon/main/provider/new_post_provider.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/post_image_picker.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/local_image_widget.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/poll_creation_sheet.dart';
import 'package:campcon/main/widgets/dialogs/campus_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaSelectionProvider>().clearSelection();
      context.read<NewPostProvider>().reset();
    });
  }

  void _checkAndShowCampusDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await CampusDialog.show(
      context,
      onSelection: (campus) async {
        await authProvider.updateCampus(campus);
      },
    );
  }

  Future<void> _createPost() async {
    final authProvider = context.read<AuthProvider>();
    final mediaProvider = context.read<MediaSelectionProvider>();
    final postProvider = context.read<PostProvider>();
    final newPostProvider = context.read<NewPostProvider>();

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    final campus = currentUser.campus ?? '';
    final content = newPostProvider.contentController.text.trim();
    final images = mediaProvider.selectedFiles;
    final poll = newPostProvider.currentPoll;

    if (content.isEmpty && images.isEmpty && poll == null) {
      _showError('Please add some content, images, or create a poll');
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Clear form immediately
    newPostProvider.reset();
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
      poll: poll,
    );

    debugPrint(success ? ' Post created silently' : '❌ Silent upload failed');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextConstants.mediumText.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _removeImage(MediaSelectionProvider mediaProvider, int index) {
    final capturedCount = mediaProvider.capturedImages.length;

    if (index < capturedCount) {
      mediaProvider.removeCapturedAt(index);
    } else {
      mediaProvider.removeAt(index - capturedCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<NewPostProvider>(
      builder: (context, newPostProvider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: false, //  Prevent automatic resize
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(newPostProvider),

                Divider(height: 1, thickness: 1, color: AppTheme.border),

                // Content Area - Scrollable
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Dismiss keyboard when tapping outside
                      FocusScope.of(context).unfocus();
                      newPostProvider.hideImagePicker();
                    },
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text Input
                          TextField(
                            controller: newPostProvider.contentController,
                            focusNode: newPostProvider.contentFocusNode,
                            maxLines: null,
                            minLines: 3,
                            style: TextConstants.mediumText.copyWith(
                              fontSize: 16.sp,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Say something...',
                              hintStyle: TextConstants.mediumText.copyWith(
                                fontSize: 16.sp,
                                color: AppTheme.textLight,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap: () => newPostProvider.onTextFieldTap(),
                          ),

                          SizedBox(height: 16.h),

                          // Selected Images Preview
                          Consumer<MediaSelectionProvider>(
                            builder: (context, mediaProvider, child) {
                              final images = mediaProvider.selectedFiles;
                              if (images.isEmpty)
                                return const SizedBox.shrink();

                              return LocalImageWidget(
                                images: images,
                                showRemoveButton: true,
                                onRemove: (index) =>
                                    _removeImage(mediaProvider, index),
                              );
                            },
                          ),

                          // Extra space at bottom to ensure content is visible above keyboard/picker
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // Image Picker (expandable from bottom)
                if (newPostProvider.showImagePicker)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(
                        top: BorderSide(color: AppTheme.border, width: 1),
                      ),
                    ),
                    child: const PostImagePicker(),
                  ),

                // Bottom Action Bar
                _buildBottomBar(newPostProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(NewPostProvider newPostProvider) {
    return Container(
      color: AppTheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.x,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Text(
            'New Post',
            style: TextConstants.boldText.copyWith(
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
            ),
          ),
          // Post Button in header
          GestureDetector(
            onTap: _createPost,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Post',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(NewPostProvider newPostProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Gallery button
          _buildActionIcon(
            icon: IconlyLight.image,
            isActive: newPostProvider.showImagePicker,
            onTap: () => newPostProvider.toggleImagePicker(),
          ),
          SizedBox(width: 16.w),

          // Poll button
          _buildActionIcon(
            icon: IconlyLight.chart,
            isActive: newPostProvider.hasPoll,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => PollCreationSheet(
                  onPollCreated: (poll) {
                    context.read<NewPostProvider>().setPoll(poll);
                  },
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
          ),
          SizedBox(width: 16.w),

          // Location button
          _buildActionIcon(
            icon: IconlyLight.location,
            onTap: () {
              // enter campus location
              _checkAndShowCampusDialog();
            },
          ),
          SizedBox(width: 16.w),

          // Image count badge
          Consumer<MediaSelectionProvider>(
            builder: (context, mediaProvider, child) {
              final count = mediaProvider.selectedFiles.length;
              if (count == 0) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count selected',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Character count
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: newPostProvider.contentController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return Text(
                '${value.text.length}',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textLight,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 24.sp,
          color: isActive ? AppTheme.primary : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
