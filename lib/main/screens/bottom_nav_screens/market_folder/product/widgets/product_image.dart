import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/product_model.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProductImage extends StatefulWidget {
  final Product product;

  const ProductImage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  int _currentImageIndex = 0;

  List<String> get allImages => widget.product.allImageUrls;
  bool get hasMultipleImages => allImages.length > 1;

  void _openImageViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenProductImages(
          images: allImages,
          initialIndex: index,
          productName: widget.product.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Image
        GestureDetector(
          onTap: () => _openImageViewer(_currentImageIndex),
          child: Container(
            height: 320.h,
            width: double.infinity,
            color: AppTheme.buttonBorder,
            child: Stack(
              children: [
                // Image
                Positioned.fill(child: _buildMainImage()),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Image count badge
                if (hasMultipleImages)
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: _buildImageCountBadge(),
                  ),

                // Discount badge
                if (widget.product.discount != null &&
                    widget.product.discount! > 0)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: _buildDiscountBadge(),
                  ),
              ],
            ),
          ),
        ),

        // Thumbnail strip
        if (hasMultipleImages) _buildThumbnailStrip(),
      ],
    );
  }

  Widget _buildMainImage() {
    if (widget.product.imageFile != null) {
      return Image.file(
        widget.product.imageFile!,
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
              setState(() => _currentImageIndex = index);
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
                    color: AppTheme.buttonBorder,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.buttonBorder,
                    child: Icon(Icons.error, size: 16.sp),
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

  Widget _buildDiscountBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '-${widget.product.discount!.toStringAsFixed(0)}%',
        style: TextConstants.smallText.copyWith(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            widget.product.isItem ? Ph.shopping_bag : Ph.briefcase,
            size: 80.sp,
            color: AppTheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 12.h),
          Text(
            'No image available',
            style: TextConstants.smallText.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// Full screen image viewer for products
class _FullScreenProductImages extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String productName;

  const _FullScreenProductImages({
    required this.images,
    required this.initialIndex,
    required this.productName,
  });

  @override
  State<_FullScreenProductImages> createState() =>
      _FullScreenProductImagesState();
}

class _FullScreenProductImagesState extends State<_FullScreenProductImages> {
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
          ),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(widget.images[index]),
            initialScale: PhotoViewComputedScale.contained,
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
