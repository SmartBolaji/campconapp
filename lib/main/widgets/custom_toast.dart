import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

enum ToastType { success, error, info, warning }

void showCustomToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.h,
      left: MediaQuery.of(context).size.width * 0.05,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: _getBackgroundColor(type),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _getBorderColor(type),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(type),
                color: _getTextColor(type),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _getTextColor(type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

Color _getBackgroundColor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AppTheme.success;
    case ToastType.error:
      return AppTheme.error;
    case ToastType.warning:
      return AppTheme.warning;
    case ToastType.info:
      return AppTheme.info;
  }
}

Color _getBorderColor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AppTheme.success;
    case ToastType.error:
      return AppTheme.error;
    case ToastType.warning:
      return AppTheme.warning;
    case ToastType.info:
      return AppTheme.info;
  }
}

Color _getTextColor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AppTheme.white;
    case ToastType.error:
      return AppTheme.white;
    case ToastType.warning:
      return AppTheme.white;
    case ToastType.info:
      return AppTheme.white;
  }
}

IconData _getIcon(ToastType type) {
  switch (type) {
    case ToastType.success:
      return Icons.check_circle;
    case ToastType.error:
      return Icons.error;
    case ToastType.warning:
      return Icons.warning;
    case ToastType.info:
      return Icons.info;
  }
}
