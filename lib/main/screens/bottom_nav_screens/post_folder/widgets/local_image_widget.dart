import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/widgets/navigation_helper.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/full_local_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocalImageWidget extends StatefulWidget {
  final List<File> images;
  final bool showRemoveButton;
  final Function(int index)? onRemove;
  final double? width;

  const LocalImageWidget({
    super.key,
    required this.images,
    this.showRemoveButton = true,
    this.onRemove,
    this.width,
  });

  @override
  State<LocalImageWidget> createState() => _LocalImageWidgetState();
}

class _LocalImageWidgetState extends State<LocalImageWidget> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Fixed dimensions for images
  final double imageHeight = 250.0;
  final double imageSpacing = 8.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LocalImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.images.length != widget.images.length) {
      if (_currentIndex >= widget.images.length) {
        _currentIndex = widget.images.isEmpty ? 0 : widget.images.length - 1;
      }
    }
  }

  // Calculate image width based on number of images
  double _getImageWidth(BuildContext context) {
    if (widget.width != null) return widget.width!;

    final screenWidth = MediaQuery.of(context).size.width - 32.w;
    if (widget.images.length == 1) {
      // Single image - use full available width
      return screenWidth;
    } else {
      // Multiple images - 70% of screen width so next image is visible
      return screenWidth * 0.7;
    }
  }

  void _openFullScreen(int index) {
    NavigationHelper.navigateTo(
      context,
      FullScreenLocalImageView(
        images: widget.images,
        initialIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageWidth = _getImageWidth(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image scroll view
        SizedBox(
          height: imageHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                // Calculate which image is most centered
                final offset = _scrollController.offset;
                final imageFullWidth = imageWidth + imageSpacing;
                final newIndex = ((offset + imageWidth / 2) / imageFullWidth)
                    .round()
                    .clamp(0, widget.images.length - 1);

                if (newIndex != _currentIndex) {
                  setState(() {
                    _currentIndex = newIndex;
                  });
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.images.length - 1 ? 0 : imageSpacing,
                  ),
                  child: GestureDetector(
                    onTap: () => _openFullScreen(index),
                    child: Stack(
                      children: [
                        Image.file(
                          widget.images[index],
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: imageWidth,
                              height: imageHeight,
                              color: AppTheme.border.withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40.sp,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            );
                          },
                        ),
                        // Remove button
                        if (widget.showRemoveButton && widget.onRemove != null)
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: () => widget.onRemove!(index),
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        // Full screen button
                        // Positioned(
                        //   bottom: 8.h,
                        //   right: 8.w,
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       color: Colors.black.withValues(alpha: 0.6),
                        //     ),
                        //     padding: EdgeInsets.all(6.w),
                        //     child: Icon(
                        //       Icons.fullscreen,
                        //       color: Colors.white,
                        //       size: 18.sp,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Indicators - Always visible below images (matching ImagePageViewWidget style)
        if (widget.images.length > 1) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => _buildIndicator(index),
            ),
          ),
        ],

        SizedBox(height: 8.h),

        // Image count indicator
        Text(
          '${widget.images.length}/10 images',
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = _currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: isActive ? 20.w : 6.w,
      height: 4.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.r),
        color: isActive
            ? AppTheme.primary
            : AppTheme.textLight.withValues(alpha: 0.4),
      ),
    );
  }
}
