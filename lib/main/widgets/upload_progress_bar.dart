import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UploadProgressBar extends StatelessWidget {
  const UploadProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        if (!provider.showUploadBar) return const SizedBox.shrink();

        Color backgroundColor;
        Color progressColor;
        IconData icon;

        switch (provider.uploadStatus) {
          case UploadStatus.uploading:
          case UploadStatus.processing:
            backgroundColor = AppTheme.primary.withOpacity(0.1);
            progressColor = AppTheme.primary;
            icon = Icons.cloud_upload;
            break;
          case UploadStatus.success:
            backgroundColor = AppTheme.success.withOpacity(0.1);
            progressColor = AppTheme.success;
            icon = Icons.check_circle;
            break;
          case UploadStatus.failed:
            backgroundColor = AppTheme.error.withOpacity(0.1);
            progressColor = AppTheme.error;
            icon = Icons.error;
            break;
          case UploadStatus.cancelled:
            backgroundColor = AppTheme.textLight.withOpacity(0.1);
            progressColor = AppTheme.textLight;
            icon = Icons.cancel;
            break;
          default:
            return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: progressColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: progressColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.uploadMessage,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 13.sp,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // if (provider.uploadStatus == UploadStatus.uploading ||
                        //     provider.uploadStatus == UploadStatus.processing)
                        //   Text(
                        //     '${(provider.uploadProgress * 100).toInt()}%',
                        //     style: TextConstants.smallText.copyWith(
                        //       fontSize: 11.sp,
                        //       color: AppTheme.textSecondary,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  if (provider.uploadStatus == UploadStatus.uploading)
                    IconButton(
                      onPressed: () => provider.cancelUpload(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              if (provider.uploadStatus == UploadStatus.uploading ||
                  provider.uploadStatus == UploadStatus.processing)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: provider.uploadProgress,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 4.h,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
