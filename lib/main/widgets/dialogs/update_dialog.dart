import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UpdateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, updateProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Icon(
                  Icons.system_update,
                  size: 48.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  'Check for Updates',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  updateProvider.updateMessage ??
                      'Tap check to see if there\'s a newer version available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // Progress indicator (if updating)
                if (updateProvider.isUpdating)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Installing update...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  )
                else if (updateProvider.isChecking)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Checking for updates...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Close button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),

                      // Check button
                      ElevatedButton(
                        onPressed: () async {
                          final hasUpdate =
                              await updateProvider.checkForUpdate();

                          if (hasUpdate && context.mounted) {
                            // Show install button
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Check',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Install button (shown after checking)
                if (!updateProvider.isChecking &&
                    !updateProvider.isUpdating &&
                    updateProvider.updateMessage != null &&
                    updateProvider.updateMessage!.contains('available'))
                  Column(
                    children: [
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success =
                                await updateProvider.installUpdate();

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Update installed!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (context.mounted) Navigator.pop(context);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Install Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
