import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/pickup_center_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class AdminPickupCard extends StatelessWidget {
  final PickupCenterModel center;
  final bool isActionLoading;
  final VoidCallback? onApprove;
  final void Function(String? reason)? onReject;
  final VoidCallback? onSuspend;

  const AdminPickupCard({
    super.key,
    required this.center,
    required this.isActionLoading,
    this.onApprove,
    this.onReject,
    this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _statusBorderColor(),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: owner info + center name + badges
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOwnerAvatar(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'by ${center.ownerName}',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _statusBadge(),
                    SizedBox(height: 4.h),
                    _typeBadge(),
                  ],
                ),
              ],
            ),
          ),

          // Description
          if (center.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Text(
                center.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),

          // Info grid
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            child: Column(
              children: [
                _infoRow(Ph.map_pin, center.fullAddress),
                SizedBox(height: 6.h),
                _infoRow(Ph.phone, center.alternatePhone != null
                    ? '${center.phoneNumber}  •  ${center.alternatePhone}'
                    : center.phoneNumber),
                SizedBox(height: 6.h),
                _infoRow(
                  Ph.calendar,
                  '${center.operatingDaysDisplay}  ·  ${center.operatingHours}',
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Row(
              children: [
                if (center.rating > 0) ...[
                  Iconify(Ph.star, size: 13.r, color: AppTheme.warning),
                  SizedBox(width: 4.w),
                  Text(
                    center.rating.toStringAsFixed(1),
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                _statPill(Ph.package, '${center.totalPickups}', 'pickups'),
                SizedBox(width: 8.w),
                _statPill(Ph.arrow_down, '${center.totalDropoffs}', 'dropoffs'),
                const Spacer(),
                Text(
                  _timeAgo(center.createdAt),
                  style: TextConstants.smallText.copyWith(
                    fontSize: 10.sp,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Rejection reason (if rejected and reason exists)
          if (center.isRejected &&
              center.rejectionReason != null &&
              center.rejectionReason!.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Iconify(Ph.warning_circle, size: 13.r, color: AppTheme.error),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        center.rejectionReason!,
                        style: TextConstants.smallText.copyWith(
                          fontSize: 11.sp,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
            child: _buildActions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (center.isPending) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Approve',
              color: AppTheme.success,
              icon: Ph.check_circle,
              loading: isActionLoading,
              onTap: () => _confirmApprove(context),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _actionButton(
              label: 'Reject',
              color: AppTheme.error,
              icon: Ph.x_circle,
              loading: isActionLoading,
              onTap: () => _showRejectDialog(context),
            ),
          ),
        ],
      );
    }

    if (center.isApproved) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Suspend Center',
              color: AppTheme.warning,
              icon: Ph.warning,
              loading: isActionLoading,
              onTap: () => _confirmSuspend(context),
            ),
          ),
        ],
      );
    }

    // Rejected or suspended — show status info only
    return Row(
      children: [
        Iconify(
          center.isRejected ? Ph.x_circle : Ph.warning,
          size: 14.r,
          color: center.isRejected ? AppTheme.error : AppTheme.warning,
        ),
        SizedBox(width: 6.w),
        Text(
          center.isRejected ? 'Application rejected' : 'Center suspended',
          style: TextConstants.smallText.copyWith(
            fontSize: 12.sp,
            color: center.isRejected ? AppTheme.error : AppTheme.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerAvatar() {
    final imageUrl = center.ownerImage ?? '';
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 42.w,
          height: 42.w,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: _statusColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22.r),
      ),
      alignment: Alignment.center,
      child: Iconify(
        _typeIcon(),
        size: 20.r,
        color: _statusColor(),
      ),
    );
  }

  Widget _statusBadge() {
    final color = _statusColor();
    final icon = center.isPending
        ? Ph.clock
        : center.isApproved
            ? Ph.check_circle
            : center.isSuspended
                ? Ph.warning
                : Ph.x_circle;
    final label = center.isPending
        ? 'Pending'
        : center.isApproved
            ? 'Approved'
            : center.isSuspended
                ? 'Suspended'
                : 'Rejected';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, size: 10.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.textLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(_typeIcon(), size: 10.r, color: AppTheme.textSecondary),
          SizedBox(width: 4.w),
          Text(
            center.typeDisplay,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Iconify(icon, size: 13.r, color: AppTheme.textLight),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statPill(String icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, size: 11.r, color: AppTheme.textLight),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required String icon,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: loading ? AppTheme.border : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: loading ? AppTheme.border : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              size: 14.r,
              color: loading ? AppTheme.textLight : color,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextConstants.smallText.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: loading ? AppTheme.textLight : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    if (center.isPending) return AppTheme.warning;
    if (center.isApproved) return AppTheme.success;
    if (center.isSuspended) return AppTheme.warning;
    return AppTheme.error;
  }

  Color _statusBorderColor() {
    if (center.isPending) return AppTheme.warning.withValues(alpha: 0.3);
    if (center.isApproved) return AppTheme.success.withValues(alpha: 0.25);
    if (center.isSuspended) return AppTheme.warning.withValues(alpha: 0.35);
    return AppTheme.error.withValues(alpha: 0.25);
  }

  String _typeIcon() {
    switch (center.type) {
      case PickupCenterType.shop:
        return Ph.storefront;
      case PickupCenterType.warehouse:
        return Ph.house;
      case PickupCenterType.individual:
        return Ph.user_circle;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _confirmApprove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Approve Pickup Center?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          '"${center.name}" operated by ${center.ownerName} will be approved and made available on the platform.',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onApprove?.call();
            },
            child: Text(
              'Approve',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSuspend(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Suspend Center?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          '"${center.name}" will be suspended and temporarily unavailable for pickups.',
          style: TextConstants.smallText.copyWith(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSuspend?.call();
            },
            child: Text(
              'Suspend',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Reject Application?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject "${center.name}" by ${center.ownerName}?',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              maxLines: 3,
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Rejection reason (optional)',
                hintStyle: TextConstants.smallText.copyWith(
                  fontSize: 12.sp,
                  color: AppTheme.textLight,
                ),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppTheme.primary),
                ),
                contentPadding: EdgeInsets.all(10.w),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final reason = controller.text.trim();
              Navigator.pop(ctx);
              onReject?.call(reason.isEmpty ? null : reason);
            },
            child: Text(
              'Reject',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}
