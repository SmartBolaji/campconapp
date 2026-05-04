import 'package:cached_network_image/cached_network_image.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class AdminUserCard extends StatelessWidget {
  final UserModel user;
  final bool isActionLoading;
  final VoidCallback? onMakeAdmin;
  final VoidCallback? onVerify;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.isActionLoading,
    this.onMakeAdmin,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl ?? user.profileImage ?? '';
    final displayName = user.fullName.trim().isNotEmpty
        ? user.fullName.trim()
        : (user.username.trim().isNotEmpty ? user.username.trim() : 'User');
    final isAdmin = user.role.toLowerCase() == 'admin';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _roleBadge(user.role),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.email.isNotEmpty)
                  _infoRow(Ph.envelope_simple, user.email),
                if (user.phoneNumber.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: _infoRow(Ph.phone, user.phoneNumber),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: _infoRow(
                    Ph.identification_card,
                    user.uid.length > 20
                        ? '${user.uid.substring(0, 20)}...'
                        : user.uid,
                  ),
                ),
              ],
            ),
          ),
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
                  child: GestureDetector(
                    onTap: isActionLoading || isAdmin ? null : onMakeAdmin,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppTheme.success.withValues(alpha: 0.12)
                            : (isActionLoading
                                ? AppTheme.border
                                : AppTheme.primary.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isAdmin
                              ? AppTheme.success.withValues(alpha: 0.35)
                              : (isActionLoading
                                  ? AppTheme.border
                                  : AppTheme.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(
                            isAdmin ? Ph.shield_check : Ph.shield_plus,
                            size: 15.r,
                            color: isAdmin
                                ? AppTheme.success
                                : (isActionLoading
                                    ? AppTheme.textLight
                                    : AppTheme.primary),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isAdmin ? 'Admin' : 'Make Admin',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isAdmin
                                  ? AppTheme.success
                                  : (isActionLoading
                                      ? AppTheme.textLight
                                      : AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: isActionLoading ? null : onVerify,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isActionLoading
                            ? AppTheme.border
                            : AppTheme.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isActionLoading
                              ? AppTheme.border
                              : AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Iconify(
                            Ph.check,
                            size: 15.r,
                            color: isActionLoading
                                ? AppTheme.textLight
                                : AppTheme.info,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Verify',
                            style: TextConstants.smallText.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isActionLoading
                                  ? AppTheme.textLight
                                  : AppTheme.info,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _roleBadge(String role) {
    final r = role.toLowerCase();
    final isAdmin = r == 'admin';
    final color = isAdmin ? AppTheme.success : AppTheme.textSecondary;
    final label = r.isEmpty ? 'user' : r;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: TextConstants.smallText.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
}
