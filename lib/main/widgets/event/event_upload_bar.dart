import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EventUploadProgressBar extends StatelessWidget {
  const EventUploadProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
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
                color: Colors.black.withOpacity(0.1),
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
                        if (provider.uploadStatus ==
                            EventUploadStatus.uploading)
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
                  if (provider.uploadStatus == EventUploadStatus.uploading)
                    IconButton(
                      icon: Icon(Icons.close, size: 20.sp),
                      onPressed: provider.cancelUpload,
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
              if (provider.uploadStatus == EventUploadStatus.uploading) ...[
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

  Widget _buildStatusIcon(EventUploadStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case EventUploadStatus.uploading:
        return SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        );
      case EventUploadStatus.processing:
        icon = Icons.sync;
        color = AppTheme.primary;
        break;
      case EventUploadStatus.success:
        icon = Icons.check_circle;
        color = AppTheme.success;
        break;
      case EventUploadStatus.failed:
        icon = Icons.error;
        color = AppTheme.error;
        break;
      case EventUploadStatus.cancelled:
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
