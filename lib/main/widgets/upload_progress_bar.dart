import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UploadProgressBar extends StatelessWidget {
  const UploadProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        if (!provider.showUploadBar) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(
                    provider.uploadStatus,
                    appColors: appColors,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.uploadMessage,
                          style: TextConstants.medium(context).copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: appColors.textPrimary,
                          ),
                        ),
                        if (provider.uploadStatus == UploadStatus.uploading)
                          Text(
                            '${(provider.uploadProgress * 100).toInt()}%',
                            style: TextConstants.small(context).copyWith(
                              fontSize: 12.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (provider.uploadStatus == UploadStatus.uploading)
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      onPressed: provider.cancelUpload,
                      color: appColors.textSecondary,
                    ),
                ],
              ),
              if (provider.uploadStatus == UploadStatus.uploading) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: provider.uploadProgress,
                    backgroundColor: appColors.border,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 6.h,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(
    UploadStatus status, {
    required AppColorsExtension appColors,
    required ColorScheme colorScheme,
  }) {
    IconData icon;
    Color color;

    switch (status) {
      case UploadStatus.uploading:
        return SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      case UploadStatus.processing:
        icon = Icons.sync;
        color = colorScheme.primary;
        break;
      case UploadStatus.success:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case UploadStatus.failed:
        icon = Icons.error;
        color = colorScheme.error;
        break;
      case UploadStatus.cancelled:
        icon = Icons.cancel;
        color = appColors.textSecondary;
        break;
      default:
        icon = Icons.upload;
        color = colorScheme.primary;
    }

    return Icon(icon, size: 24.sp, color: color);
  }
}
