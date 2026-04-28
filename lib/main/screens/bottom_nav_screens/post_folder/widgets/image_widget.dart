import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/widgets/navigation_helper.dart';
import 'package:campcon/main/screens/bottom_nav_screens/post_folder/widgets/full_image_widget.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePageViewWidget extends StatefulWidget {
  final List<String> imageUrls;
  final bool showFullScreenButton;
  final bool isLiked;
  final Function onLike;
  final double width;
  final EdgeInsets horizontalPadding;

  const ImagePageViewWidget({
    Key? key,
    required this.imageUrls,
    required this.showFullScreenButton,
    required this.isLiked,
    required this.onLike,
    required this.width,
    this.horizontalPadding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  ImagePageViewWidgetState createState() => ImagePageViewWidgetState();
}

class ImagePageViewWidgetState extends State<ImagePageViewWidget> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late List<bool> _failedToLoad;
  bool _isPreloading = false;

  // Fixed dimensions for images
  final double imageHeight = 250.0;
  final double imageSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _failedToLoad = List.generate(widget.imageUrls.length, (index) => false);
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    if (_isPreloading || widget.imageUrls.isEmpty) return;

    _isPreloading = true;
    try {
      await CustomCacheManager().preloadImages(widget.imageUrls);
    } finally {
      if (mounted) {
        setState(() {
          _isPreloading = false;
        });
      }
    }
  }

  void _openFullScreen(int index) {
    NavigationHelper.navigateTo(
      context,
      FullScreenImageView(
        imageUrls: widget.imageUrls,
        isLiked: widget.isLiked,
        onLike: widget.onLike,
        initialIndex: index,
      ),
    );
  }

  @override
  void didUpdateWidget(ImagePageViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      if (_currentIndex >= widget.imageUrls.length) {
        _currentIndex =
            widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1;
      }

      _failedToLoad = List.generate(widget.imageUrls.length, (index) => false);
      _preloadImages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isPreloading = false;
    super.dispose();
  }

  // Calculate image width from the layout width provided by the parent.
  double _getImageWidth() {
    final availableWidth = widget.width - widget.horizontalPadding.horizontal;
    if (widget.imageUrls.length == 1) {
      // Single image - use full available width to align with parent padding.
      return availableWidth;
    } else {
      // Multiple images - leave a preview of the next image.
      return availableWidth * 0.75;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: imageHeight,
        decoration: BoxDecoration(
          color: AppTheme.border.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            "No images available",
            style: TextStyle(
              fontFamily: 'Nexa Light',
              color: AppTheme.textLight,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    final imageWidth = _getImageWidth();

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                    .clamp(0, widget.imageUrls.length - 1);

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
              itemCount: widget.imageUrls.length,
              physics: const BouncingScrollPhysics(),
              padding: widget.horizontalPadding,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right:
                        index == widget.imageUrls.length - 1 ? 0 : imageSpacing,
                  ),
                  child: GestureDetector(
                    onTap: () => _openFullScreen(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: SizedBox(
                            width: imageWidth,
                            height: imageHeight,
                            child: _buildImageWidget(index),
                          ),
                        ),
                        // Full screen button only on first image or single image
                        if (widget.showFullScreenButton &&
                            (widget.imageUrls.length == 1 || index == 0))
                          Positioned(
                            bottom: 8.h,
                            right: 8.w,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              padding: EdgeInsets.all(8.w),
                              child: Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20.sp,
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
        ),

        // Indicators - Always visible below images
        if (widget.imageUrls.length > 1) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildLimitedIndicators(),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildLimitedIndicators() {
    final total = widget.imageUrls.length;
    if (total <= 1) return [];

    const maxVisibleIndicators = 6;
    int visibleIndicators =
        total < maxVisibleIndicators ? total : maxVisibleIndicators;
    int startIndex = (_currentIndex - visibleIndicators ~/ 2)
        .clamp(0, total - visibleIndicators);
    int endIndex = (startIndex + visibleIndicators).clamp(0, total);

    List<Widget> indicators = [];
    if (startIndex > 0) {
      indicators.add(_buildMiniDot());
    }
    for (int i = startIndex; i < endIndex; i++) {
      indicators.add(_buildIndicatorItem(i));
    }
    if (endIndex < total) {
      indicators.add(_buildMiniDot());
    }
    return indicators;
  }

  Widget _buildMiniDot() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: 3.w,
      height: 3.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.textLight.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildIndicatorItem(int index) {
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

  Widget _buildImageWidget(int index) {
    if (index >= widget.imageUrls.length) {
      return Container(
        color: AppTheme.border.withValues(alpha: 0.1),
      );
    }

    return _failedToLoad[index]
        ? _buildErrorWidget(index)
        : CachedNetworkImage(
            imageUrl: widget.imageUrls[index],
            cacheManager: CustomCacheManager(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppTheme.border.withValues(alpha: 0.1),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              debugPrint('Error loading image: $error');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _failedToLoad[index] = true;
                  });
                }
              });
              return _buildErrorWidget(index);
            },
            cacheKey: widget.imageUrls[index],
          );
  }

  Widget _buildErrorWidget(int index) {
    return Container(
      color: AppTheme.border.withValues(alpha: 0.1),
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _failedToLoad[index] = false;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.replay_outlined,
                size: 35.sp,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
              SizedBox(height: 10.h),
              Text(
                "Tap to retry",
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14.sp,
                  fontFamily: 'Nexa Light',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
