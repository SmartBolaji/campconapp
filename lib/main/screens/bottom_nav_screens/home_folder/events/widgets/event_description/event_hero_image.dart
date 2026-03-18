import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/event_model.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class EventHeroImage extends StatefulWidget {
  final EventModel event;

  const EventHeroImage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventHeroImage> createState() => _EventHeroImageState();
}

class _EventHeroImageState extends State<EventHeroImage> {
  int _currentImageIndex = 0;

  List<String> get allImages => widget.event.allImageUrls;
  bool get hasMultipleImages => allImages.length > 1;

  void _openImageViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenEventImages(
          images: allImages,
          initialIndex: index,
          eventTitle: widget.event.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Hero Image
        GestureDetector(
          onTap: () => _openImageViewer(_currentImageIndex),
          child: Stack(
            children: [
              // Main Image
              Container(
                height: 280.h,
                width: double.infinity,
                color: AppTheme.buttonBorder,
                child: _buildMainImage(),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // Date Badge (Top Left)
              Positioned(
                top: 16.h,
                left: 16.w,
                child: _buildDateBadge(),
              ),

              // Status Badges (Top Right)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: _buildStatusBadges(),
              ),

              // Price Badge (Bottom Right)
              Positioned(
                bottom: 16.h,
                right: 16.w,
                child: _buildPriceBadge(),
              ),

              // Image count indicator (Bottom Left)
              if (hasMultipleImages)
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  child: _buildImageCountBadge(),
                ),
            ],
          ),
        ),

        // Additional Images Thumbnail Strip
        if (hasMultipleImages) _buildThumbnailStrip(),
      ],
    );
  }

  Widget _buildMainImage() {
    if (widget.event.imageFile != null) {
      return Image.file(
        widget.event.imageFile!,
        fit: BoxFit.cover,
      );
    } else if (allImages.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: allImages[_currentImageIndex],
        fit: BoxFit.cover,
        cacheManager: CustomCacheManager(),
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildThumbnailStrip() {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: allImages.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentImageIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIndex = index;
              });
            },
            child: Container(
              width: 50.w,
              height: 50.h,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: CachedNetworkImage(
                  imageUrl: allImages[index],
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager(),
                  placeholder: (context, url) => Container(
                    color: AppTheme.background,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.background,
                    child: Icon(
                      Icons.broken_image,
                      size: 16.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCountBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
            '${_currentImageIndex + 1}/${allImages.length}',
            style: TextConstants.smallText.copyWith(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            Ph.calendar_blank,
            size: 48.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 8.h),
          Text(
            'No Image',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.event.eventDate.day.toString(),
            style: TextConstants.boldText.copyWith(
              fontSize: 20.sp,
              color: AppTheme.primary,
              height: 1,
            ),
          ),
          Text(
            _getMonthAbbr(widget.event.eventDate.month),
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.event.sellOnCampcon)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(Ph.ticket, size: 12.sp, color: Colors.white),
                SizedBox(width: 4.w),
                Text(
                  'Buy on CampCon',
                  style: TextConstants.smallText.copyWith(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (widget.event.isSoldOut) ...[
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'SOLD OUT',
              style: TextConstants.smallText.copyWith(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.event.isFree ? AppTheme.success : AppTheme.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        widget.event.formattedPrice,
        style: TextConstants.smallText.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

// Full screen image viewer for events
class _FullScreenEventImages extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String eventTitle;

  const _FullScreenEventImages({
    required this.images,
    required this.initialIndex,
    required this.eventTitle,
  });

  @override
  State<_FullScreenEventImages> createState() => _FullScreenEventImagesState();
}

class _FullScreenEventImagesState extends State<_FullScreenEventImages> {
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
          style: TextConstants.mediumText.copyWith(
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(widget.images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
