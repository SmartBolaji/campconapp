import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:campcon/main/provider/upload_status_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EventUploadProgressBar extends StatelessWidget {
  const EventUploadProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        if (!provider.showUploadBar) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.surface,
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
                  _buildStatusIcon(provider.uploadStatus),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.uploadMessage,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (provider.uploadStatus == UploadStatus.uploading)
                          Text(
                            '${(provider.uploadProgress * 100).toInt()}%',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (provider.uploadStatus == UploadStatus.uploading)
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      onPressed: provider.cancelUpload,
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
              if (provider.uploadStatus == UploadStatus.uploading) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: provider.uploadProgress,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
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

  Widget _buildStatusIcon(UploadStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case UploadStatus.uploading:
        return SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        );
      case UploadStatus.processing:
        icon = Icons.sync;
        color = AppTheme.primary;
        break;
      case UploadStatus.success:
        icon = Icons.check_circle;
        color = AppTheme.success;
        break;
      case UploadStatus.failed:
        icon = Icons.error;
        color = AppTheme.error;
        break;
      case UploadStatus.cancelled:
        icon = Icons.cancel;
        color = AppTheme.textSecondary;
        break;
      default:
        icon = Icons.upload;
        color = AppTheme.primary;
    }

    return Icon(icon, size: 24.sp, color: color);
  }
}
