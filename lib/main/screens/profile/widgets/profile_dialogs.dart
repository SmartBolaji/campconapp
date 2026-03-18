import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class ProfileDialogs {
  static Future<void> showReportDialog(
    BuildContext context,
    String currentUserId,
    String reportedUserId,
    String reportedName,
    VoidCallback onReportSubmitted,
  ) async {
    final reasons = [
      'Harassment or bullying',
      'Spam',
      'Inappropriate content',
      'Impersonation',
      'Other',
    ];

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Report $reportedName',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Select a reason for reporting',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reasons.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppTheme.border),
                  itemBuilder: (_, i) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        reasons[i],
                        style: TextConstants.smallText.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      trailing: Iconify(
                        Ph.caret_right,
                        size: 16.sp,
                        color: AppTheme.textLight,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _submitReport(
                          context,
                          currentUserId,
                          reportedUserId,
                          reasons[i],
                          onReportSubmitted,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _submitReport(
    BuildContext context,
    String currentUserId,
    String reportedUserId,
    String reason,
    VoidCallback onReportSubmitted,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterId': currentUserId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'user',
        'status': 'pending',
      });
      if (context.mounted) {
        showFloatingSnackBar(context, 'Report submitted. Thank you.');
        onReportSubmitted();
      }
    } catch (e) {
      debugPrint('Error submitting report: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to submit report',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  static Future<void> blockUser(
    BuildContext context,
    String currentUserId,
    String blockedUserId,
    String blockedName,
    VoidCallback onBlockSuccess,
  ) async {
    if (currentUserId.isEmpty || blockedUserId.isEmpty) return;
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set({
        'userId': blockedUserId,
        'blockedAt': FieldValue.serverTimestamp(),
      });
      await firestore.collection('users').doc(currentUserId).update({
        'hasBlockedUsers': true,
      });
      if (context.mounted) {
        showFloatingSnackBar(context, '$blockedName has been blocked');
        onBlockSuccess();
      }
    } catch (e) {
      debugPrint('Error blocking user: $e');
      if (context.mounted) {
        showFloatingSnackBar(
          context,
          'Failed to block user',
          backgroundColor: Colors.red,
        );
      }
    }
  }
}
