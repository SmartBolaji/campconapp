import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSellerCard extends StatelessWidget {
  final UserModel user;
  final bool isActionLoading;
  final VoidCallback? onApprove;
  final void Function(String? reason)? onReject;

  const AdminSellerCard({
    super.key,
    required this.user,
    required this.isActionLoading,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl ?? user.profileImage ?? '';
    final fullName = user.fullName.trim();
    final username = user.username.trim();
    final businessName = (user.businessName ?? '').trim();
    final businessDescription = (user.businessDescription ?? '').trim();
    final whatsapp = (user.contactInfo?['whatsapp'] ?? '').toString().trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (username.isNotEmpty ? username : 'User');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(imageUrl, displayName),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '@${user.username}',
                        style: TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _pendingBadge(),
              ],
            ),
          ),

          // Business category + school badges
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                if (user.businessCategory != null &&
                    user.businessCategory!.isNotEmpty)
                  _chip(
                    Ph.storefront,
                    user.businessCategory!,
                    AppTheme.primary,
                  ),
                if (user.campus != null && user.campus!.isNotEmpty)
                  _chip(Ph.map_pin, user.campus!, AppTheme.info),
                if (user.school != null && user.school!.isNotEmpty)
                  _chip(
                      Ph.graduation_cap, user.school!, AppTheme.textSecondary),
              ],
            ),
          ),

          // Contact info row
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (businessName.isNotEmpty)
                  _infoRow(Ph.storefront, businessName),
                if (businessDescription.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _infoRow(Ph.text_t, businessDescription),
                  ),
                if (whatsapp.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _whatsappRow(context, whatsapp),
                  ),
                if (user.email.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _infoRow(Ph.envelope_simple, user.email),
                  ),
                if (user.phoneNumber.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _infoRow(Ph.phone, user.phoneNumber),
                  ),
                // Padding(
                //   padding: EdgeInsets.only(top: 4.h),
                //   child: _infoRow(
                //     Ph.identification_card,
                //     user.uid.length > 20
                //         ? '${user.uid.substring(0, 20)}…'
                //         : user.uid,
                //   ),
                // ),
              ],
            ),
          ),

          // Social stats
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Row(
              children: [
                _statPill('${user.followersCount}', 'followers'),
                SizedBox(width: 8.w),
                _statPill('${user.followingCount}', 'following'),
                if (user.isStudent == true) ...[
                  SizedBox(width: 8.w),
                  _chip(Ph.student, 'Student', AppTheme.success),
                ],
              ],
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
            child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String name) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 46.w,
          height: 46.w,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _initialsAvatar(name),
        ),
      );
    }
    return _initialsAvatar(name);
  }

  Widget _initialsAvatar(String name) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _pendingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(Ph.clock, size: 11.r, color: AppTheme.warning),
          SizedBox(width: 4.w),
          Text(
            'Pending',
            style: TextConstants.smallText.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Iconify(icon, size: 11.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String icon, String text) {
    return Row(
      children: [
        Iconify(icon, size: 13.r, color: AppTheme.textLight),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _whatsappRow(BuildContext context, String whatsapp) {
    return Row(
      children: [
        Expanded(child: _infoRow(Ph.whatsapp_logo, whatsapp)),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _callWhatsapp(context, whatsapp),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Iconify(Ph.phone_call, size: 14.r, color: AppTheme.success),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _copyWhatsapp(context, whatsapp),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Iconify(Ph.copy, size: 14.r, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Future<void> _callWhatsapp(BuildContext context, String whatsapp) async {
    final normalized = whatsapp.replaceAll(RegExp(r'\\s+'), '');
    final uri = Uri(scheme: 'tel', path: normalized);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open dialer')),
      );
    }
  }

  Future<void> _copyWhatsapp(BuildContext context, String whatsapp) async {
    await Clipboard.setData(ClipboardData(text: whatsapp));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number copied')),
      );
    }
  }

  Widget _statPill(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextConstants.smallText.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextConstants.smallText.copyWith(
              fontSize: 11.sp,
              color: AppTheme.textSecondary,
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
              size: 15.r,
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

  void _confirmApprove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Approve Seller?',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Grant seller access to ${user.businessName ?? user.fullName}? They will be able to list products and services.',
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

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
              'Reject seller application from ${user.businessName ?? user.fullName}?',
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
