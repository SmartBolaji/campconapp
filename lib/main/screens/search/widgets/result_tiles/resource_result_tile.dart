import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ResourceResultTile extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onTap;
  
  const ResourceResultTile({
    super.key,
    required this.resource,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        // Navigate to resource detail
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBackground,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Iconify(
                _getResourceIcon(),
                size: 24.sp,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 14.w),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    resource.description,
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Tags
                  Row(
                    children: [
                      _buildTag(resource.resourceType),
                      if (resource.course != null) ...[
                        SizedBox(width: 8.w),
                        _buildTag(resource.course!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Link indicator
            if (resource.isExternalLink)
              Iconify(
                Ph.link,
                size: 18.sp,
                color: AppTheme.textLight,
              ),
          ],
        ),
      ),
    );
  }
  
  String _getResourceIcon() {
    switch (resource.resourceType.toLowerCase()) {
      case 'lecture notes':
        return Ph.notebook;
      case 'past questions':
        return Ph.exam;
      case 'textbooks':
        return Ph.book_open;
      case 'tutorials':
        return Ph.video_camera;
      default:
        return Ph.file;
    }
  }
  
  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextConstants.smallText.copyWith(
          fontSize: 11.sp,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}