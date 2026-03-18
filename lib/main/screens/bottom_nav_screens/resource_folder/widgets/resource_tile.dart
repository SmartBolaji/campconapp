import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ResourceTile extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const ResourceTile({
    Key? key,
    required this.resource,
    required this.onTap,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File type icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    _getTypeColor(resource.resourceType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Iconify(
                _getTypeIcon(resource.resourceType),
                size: 28.sp,
                color: _getTypeColor(resource.resourceType),
              ),
            ),
            SizedBox(width: 14.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    resource.title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Resource type badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource.resourceType)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      resource.resourceType,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(resource.resourceType),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  if (resource.description.isNotEmpty)
                    Text(
                      resource.description,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 10.h),

                  // Stats row
                  Row(
                    children: [
                      // Downloads
                      Row(
                        children: [
                          Iconify(
                            Ph.download_simple,
                            size: 14.sp,
                            color: AppTheme.textLight,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${resource.downloadCount}',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),

                      // Course code if available
                      if (resource.course != null &&
                          resource.course!.isNotEmpty)
                        Row(
                          children: [
                            Iconify(
                              Ph.book_open,
                              size: 14.sp,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              resource.course!,
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),

                      // External link indicator
                      if (resource.isExternalLink)
                        Row(
                          children: [
                            SizedBox(width: resource.course != null ? 12.w : 0),
                            Iconify(
                              Ph.link,
                              size: 14.sp,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Link',
                              style: TextConstants.smallText.copyWith(
                                fontSize: 12.sp,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Download/Open button
                      if (onDownload != null && resource.fileUrl != null)
                        GestureDetector(
                          onTap: onDownload,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Iconify(
                              resource.isExternalLink
                                  ? Ph.arrow_square_out
                                  : Ph.download_simple,
                              size: 18.sp,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'Lecture Notes':
        return Ph.notebook;
      case 'Past Questions':
        return Ph.exam;
      case 'Textbook':
        return Ph.book;
      case 'Assignment':
        return Ph.clipboard_text;
      case 'Lab Report':
        return Ph.flask;
      case 'Project':
        return Ph.folder_open;
      case 'Slides':
        return Ph.presentation_chart;
      case 'Tutorial':
        return Ph.play_circle;
      default:
        return Ph.file;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Lecture Notes':
        return const Color(0xFF6B4CE6);
      case 'Past Questions':
        return const Color(0xFFEF4444);
      case 'Textbook':
        return const Color(0xFF0EA5E9);
      case 'Assignment':
        return const Color(0xFFF59E0B);
      case 'Lab Report':
        return const Color(0xFF10B981);
      case 'Project':
        return const Color(0xFF8B5CF6);
      case 'Slides':
        return const Color(0xFFEC4899);
      case 'Tutorial':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF64748B);
    }
  }
}
