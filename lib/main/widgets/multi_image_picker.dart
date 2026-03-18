import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:image_picker/image_picker.dart';

class MultiImagePicker extends StatelessWidget {
  final List<File> images;
  final ValueChanged<List<File>> onImagesChanged;
  final int maxImages;
  final double primaryHeight;
  final double thumbnailHeight;
  final String placeholderTitle;
  final String placeholderSubtitle;

  const MultiImagePicker({
    Key? key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 10,
    this.primaryHeight = 200,
    this.thumbnailHeight = 80,
    this.placeholderTitle = 'Add Cover Image',
    this.placeholderSubtitle = 'Tap to upload',
  }) : super(key: key);

  Future<void> _pickImages(BuildContext context,
      {bool multiple = false}) async {
    final picker = ImagePicker();

    if (multiple) {
      final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        final newImages = pickedFiles.map((xf) => File(xf.path)).toList();
        final combined = [...images, ...newImages];
        // Limit to maxImages
        onImagesChanged(combined.take(maxImages).toList());
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        // Always add to list if under max, don't replace
        if (images.length < maxImages) {
          onImagesChanged([...images, File(pickedFile.path)]);
        }
      }
    }
  }

  void _removeImage(int index) {
    final newList = List<File>.from(images);
    newList.removeAt(index);
    onImagesChanged(newList);
  }

  void _viewImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenLocalImages(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Image
        _buildPrimaryImage(context),

        // Additional Images - show when we have at least one image
        if (images.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildAdditionalImages(context),
        ],
      ],
    );
  }

  Widget _buildPrimaryImage(BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: () {
        if (images.isNotEmpty) {
          _viewImage(context, 0);
        } else {
          _pickImages(context);
        }
      },
      child: Container(
        height: primaryHeight.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: appColors.background,
          border: Border.all(color: appColors.border, width: 1.5),
        ),
        child: images.isNotEmpty
            ? Stack(
                children: [
                  ClipRRect(
                    child: Image.file(
                      images.first,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(0),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  // Image count badge
                  if (images.length > 1)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Iconify(
                              Ph.image,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${images.length}',
                              style: TextConstants.small(context).copyWith(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(Ph.image, size: 48.sp, color: appColors.textLight),
                  SizedBox(height: 12.h),
                  Text(
                    placeholderTitle,
                    style: TextConstants.medium(context).copyWith(
                      fontSize: 16.sp,
                      color: appColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    placeholderSubtitle,
                    style: TextConstants.small(context).copyWith(
                      fontSize: 13.sp,
                      color: appColors.textLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAdditionalImages(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    // Only show if we have images and can add more OR have additional images to show
    final hasAdditionalImages = images.length > 1;
    final canAddMore = images.length < maxImages;

    if (!hasAdditionalImages && !canAddMore) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Images',
              style: TextConstants.small(context).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: appColors.textSecondary,
              ),
            ),
            if (canAddMore)
              GestureDetector(
                onTap: () => _pickImages(context, multiple: true),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: appColors.primaryBackground,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Iconify(Ph.plus, size: 14.sp, color: colorScheme.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'Add More',
                        style: TextConstants.small(context).copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: thumbnailHeight.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Show additional images (skip first) + add button if can add more
            itemCount: (images.length - 1) + (canAddMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Add button at the end
              if (canAddMore && index == images.length - 1) {
                return GestureDetector(
                  onTap: () => _pickImages(context, multiple: true),
                  child: Container(
                    width: thumbnailHeight.w,
                    height: thumbnailHeight.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: appColors.background,
                      border: Border.all(
                        color: appColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(
                          Ph.plus,
                          size: 24.sp,
                          color: appColors.textLight,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add',
                          style: TextConstants.small(context).copyWith(
                            fontSize: 11.sp,
                            color: appColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Additional images (index + 1 because we skip the primary image)
              final imageIndex = index + 1;
              if (imageIndex >= images.length) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () => _viewImage(context, imageIndex),
                child: Container(
                  width: thumbnailHeight.w,
                  height: thumbnailHeight.h,
                  margin: EdgeInsets.only(right: 8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          images[imageIndex],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Remove button
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(imageIndex),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Full screen viewer for local images
class _FullScreenLocalImages extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const _FullScreenLocalImages({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenLocalImages> createState() => _FullScreenLocalImagesState();
}

class _FullScreenLocalImagesState extends State<_FullScreenLocalImages> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: TextConstants.medium(context).copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.file(
                widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
