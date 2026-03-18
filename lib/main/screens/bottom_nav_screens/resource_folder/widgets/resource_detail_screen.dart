import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/resource_model.dart';
import 'package:campcon/main/provider/resource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatelessWidget {
  final ResourceModel resource;
  final String? currentUserId;

  const ResourceDetailScreen({
    Key? key,
    required this.resource,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwner =
        currentUserId != null && resource.uploaderId == currentUserId;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isOwner),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // Resource type icon and title
                    _buildResourceHeader(),
                    SizedBox(height: 20.h),

                    // Info metadata row
                    _buildInfoCards(),

                    // Description
                    if (resource.description.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      Text(
                        resource.description,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],

                    // File info
                    if (resource.fileName != null ||
                        resource.isExternalLink) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Divider(
                            color: AppTheme.border, height: 1, thickness: 1),
                      ),
                      _buildFileInfo(),
                    ],

                    // Stats
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Divider(
                          color: AppTheme.border, height: 1, thickness: 1),
                    ),
                    _buildStats(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOwner) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Iconify(
              Ph.arrow_left,
              color: AppTheme.textPrimary,
              size: 24.sp,
            ),
          ),
          const Spacer(),
          if (isOwner)
            GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Iconify(
                Ph.trash,
                color: AppTheme.error,
                size: 22.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResourceHeader() {
    final typeColor = _getTypeColor(resource.resourceType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Iconify(
            _getTypeIcon(resource.resourceType),
            size: 32.sp,
            color: typeColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          resource.title,
          style: TextConstants.boldText.copyWith(
            fontSize: 22.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          resource.resourceType,
          style: TextConstants.mediumText.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: typeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    final items = <Widget>[];
    // if (resource.faculty != null)
    //   items.add(_buildInfoRow(Ph.buildings, resource.faculty!));
    if (resource.department != null)
      items.add(_buildInfoRow(Ph.buildings, resource.department!));
    if (resource.level != null)
      items.add(_buildInfoRow(Ph.graduation_cap, resource.level!));
    if (resource.course != null && resource.course!.isNotEmpty)
      items.add(_buildInfoRow(Ph.book_open, resource.course!));

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: items,
    );
  }

  Widget _buildInfoRow(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Iconify(icon, size: 15.sp, color: AppTheme.textLight),
        SizedBox(width: 5.w),
        Text(
          value,
          style: TextConstants.mediumText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return Row(
      children: [
        Iconify(
          resource.isExternalLink
              ? Ph.link
              : _getFileIcon(resource.fileName ?? ''),
          size: 28.sp,
          color: AppTheme.primary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.isExternalLink
                    ? 'External Link'
                    : (resource.fileName ?? 'Unknown file'),
                style: TextConstants.mediumText.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                resource.isExternalLink
                    ? 'Shared link to external resource'
                    : 'Uploaded ${DateFormat('MMM d, yyyy').format(resource.createdAt)}',
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
        if (resource.isExternalLink)
          Iconify(
            Ph.arrow_square_out,
            size: 16.sp,
            color: AppTheme.primary,
          ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(Ph.eye_bold, '${resource.downloadCount}', 'Views'),
        // SizedBox(width: 32.w),
        // _buildStatItem(Ph.heart, '${resource.likes}', 'Likes'),
      ],
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Row(
      children: [
        Iconify(icon, size: 18.sp, color: AppTheme.textLight),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextConstants.boldText.copyWith(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Implement share
            },
            child: Iconify(
              Ph.share_network,
              size: 22.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _downloadResource(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Iconify(
                      resource.isExternalLink
                          ? Ph.arrow_square_out
                          : Ph.download_simple,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      resource.isExternalLink ? 'Open Link' : 'Download',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadResource(BuildContext context) async {
    if (resource.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file available for download'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<ResourceProvider>(context, listen: false);
      await provider.incrementDownloadCount(resource.id);

      final uri = Uri.parse(resource.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open download link'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Resource',
          style: TextConstants.boldText.copyWith(
            fontSize: 18.sp,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this resource? This action cannot be undone.',
          style: TextConstants.mediumText.copyWith(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider =
                  Provider.of<ResourceProvider>(context, listen: false);
              final success = await provider.deleteResource(resource.id);
              if (success) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Delete',
              style: TextConstants.mediumText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
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

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Ph.file_pdf;
      case 'doc':
      case 'docx':
        return Ph.file_doc;
      case 'ppt':
      case 'pptx':
        return Ph.file_ppt;
      case 'xls':
      case 'xlsx':
        return Ph.file_xls;
      default:
        return Ph.file;
    }
  }
}
