import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/services/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final bool isItem;

  const ProductImage({
    Key? key,
    this.imageUrl,
    this.imageFile,
    required this.isItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      width: double.infinity,
      color: AppTheme.buttonBorder,
      child: imageFile != null
          ? Image.file(
              imageFile!,
              fit: BoxFit.cover,
            )
          : imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager(),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(
            isItem ? Ph.shopping_bag : Ph.briefcase,
            size: 80.sp,
            color: AppTheme.primary.withOpacity(0.3),
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
