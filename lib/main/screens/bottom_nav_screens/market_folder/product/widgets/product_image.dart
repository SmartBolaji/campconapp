import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
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
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
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
