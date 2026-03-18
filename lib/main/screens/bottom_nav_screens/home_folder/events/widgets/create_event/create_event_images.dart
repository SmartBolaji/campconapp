import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/full_local_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class CreateEventImages extends StatelessWidget {
  const CreateEventImages({Key? key}) : super(key: key);

  Future<void> _pickImages(BuildContext context,
      {bool multiple = false}) async {
    final provider = Provider.of<EventCreateProvider>(context, listen: false);
    final picker = ImagePicker();

    if (multiple) {
      final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        provider.addImages(pickedFiles.map((xf) => File(xf.path)).toList());
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        provider.addImage(File(pickedFile.path));
      }
    }
  }

  void _viewImage(BuildContext context, List<File> images, int index) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: FullScreenLocalImageView(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Image
            _buildPrimaryImage(context, provider),

            // Additional Images
            if (provider.hasImages) ...[
              SizedBox(height: 12.h),
              _buildAdditionalImages(context, provider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPrimaryImage(
      BuildContext context, EventCreateProvider provider) {
    return GestureDetector(
      onTap: () {
        if (provider.primaryImage != null) {
          _viewImage(context, provider.selectedImages, 0);
        } else {
          _pickImages(context);
        }
      },
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.background,
          // borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: provider.primaryImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    // borderRadius: BorderRadius.circular(6.r),
                    child: Image.file(
                      provider.primaryImage!,
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
                      onTap: () => provider.removeImage(0),
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
                  if (provider.imageCount > 1)
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
                            Iconify(Ph.image, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              '${provider.imageCount}',
                              style: TextConstants.smallText.copyWith(
                                color: Colors.white,
                                fontSize: 12.sp,
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
                  Iconify(Ph.image, size: 48.sp, color: AppTheme.textLight),
                  SizedBox(height: 12.h),
                  Text(
                    'Add Event Cover Image',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap to upload',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAdditionalImages(
      BuildContext context, EventCreateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Images',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () => _pickImages(context, multiple: true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBackground,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(Ph.plus, size: 14.sp, color: AppTheme.primary),
                    SizedBox(width: 4.w),
                    Text(
                      'Add More',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.primary,
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
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.additionalImages.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.additionalImages.length) {
                // Add more button at end
                return GestureDetector(
                  onTap: () => _pickImages(context, multiple: true),
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      // borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: AppTheme.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(Ph.plus,
                            size: 24.sp, color: AppTheme.textLight),
                        SizedBox(height: 4.h),
                        Text(
                          'Add',
                          style: TextConstants.smallText.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final image = provider.additionalImages[index];
              final actualIndex = index + 1; // +1 because primary is at index 0

              return GestureDetector(
                onTap: () =>
                    _viewImage(context, provider.selectedImages, actualIndex),
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  margin: EdgeInsets.only(right: 8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          image,
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => provider.removeImage(actualIndex),
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
