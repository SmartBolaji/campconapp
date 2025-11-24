import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class CustomBottomSheet {
  /// Show a custom animated bottom sheet
  ///
  /// [context] - BuildContext for showing the sheet
  /// [child] - Widget to display in the sheet
  /// [height] - Height ratio of the sheet (0.0 to 1.0), default is 0.85
  /// [isDismissible] - Can user dismiss by tapping outside, default is true
  /// [backgroundColor] - Background color of the sheet, default uses theme surface
  /// [barrerColor] - Color of the barrier, default is Colors.black54
  /// [showDragHandle] - Show drag handle at top, default is true
  /// [enableDrag] - Enable drag to dismiss, default is true
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double height = 0.85,
    bool isDismissible = true,
    Color? backgroundColor,
    Color? barrierColor,
    bool showDragHandle = true,
    bool enableDrag = true,
    BorderRadius? borderRadius,
  }) async {
    return await showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * height,
              decoration: BoxDecoration(
                color: backgroundColor ?? AppTheme.surface,
                borderRadius: borderRadius ??
                    const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius ??
                    const BorderRadius.vertical(top: Radius.circular(25)),
                child: Column(
                  children: [
                    // Drag handle
                    if (showDragHandle) _buildDragHandle(),
                    // Content
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeOutCubic.transform(animation.value);
        return Transform.translate(
          offset: Offset(0, (1 - curvedValue) * 400),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Show a bottom sheet with a title and close button
  static Future<T?> showWithTitle<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double height = 0.85,
    bool isDismissible = true,
    Color? backgroundColor,
    bool showDragHandle = true,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) async {
    return await show<T>(
      context: context,
      height: height,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      showDragHandle: showDragHandle,
      child: Column(
        children: [
          // Header with title and close button
          _buildHeader(
            context: context,
            title: title,
            showCloseButton: showCloseButton,
            onClose: onClose,
          ),
          // Divider
          Divider(height: 1, color: AppTheme.border),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Show a scrollable bottom sheet
  static Future<T?> showScrollable<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double height = 0.85,
    bool isDismissible = true,
    Color? backgroundColor,
    bool showDragHandle = true,
    bool showCloseButton = true,
    EdgeInsets? padding,
    VoidCallback? onClose,
  }) async {
    return await show<T>(
      context: context,
      height: height,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      showDragHandle: showDragHandle,
      child: Column(
        children: [
          // Header with title if provided
          if (title != null) ...[
            _buildHeader(
              context: context,
              title: title,
              showCloseButton: showCloseButton,
              onClose: onClose,
            ),
            Divider(height: 1, color: AppTheme.border),
          ],
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: padding ?? EdgeInsets.all(20.sp),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// Show a modal bottom sheet (can't be dismissed by tapping outside)
  static Future<T?> showModal<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double height = 0.85,
    Color? backgroundColor,
    bool showDragHandle = false,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) async {
    return await showWithTitle<T>(
      context: context,
      title: title ?? '',
      child: child,
      height: height,
      isDismissible: false,
      backgroundColor: backgroundColor,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      onClose: onClose,
    );
  }

  /// Show a full screen bottom sheet
  static Future<T?> showFullScreen<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    Color? backgroundColor,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) async {
    return await show<T>(
      context: context,
      child: Column(
        children: [
          if (title != null) ...[
            _buildHeader(
              context: context,
              title: title,
              showCloseButton: showCloseButton,
              onClose: onClose,
            ),
            Divider(height: 1, color: AppTheme.border),
          ],
          Expanded(child: child),
        ],
      ),
      height: 1.0,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor,
      showDragHandle: false,
      borderRadius: BorderRadius.zero,
    );
  }

  // Private helper methods
  static Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  static Widget _buildHeader({
    required BuildContext context,
    required String title,
    bool showCloseButton = true,
    VoidCallback? onClose,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder for symmetry
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, color: AppTheme.textPrimary, size: 24.sp),
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}


// // 1. Basic bottom sheet
// CustomBottomSheet.show(
//   context: context,
//   child: YourWidget(),
// );

// // 2. Bottom sheet with title
// CustomBottomSheet.showWithTitle(
//   context: context,
//   title: "Settings",
//   child: SettingsContent(),
// );

// // 3. Scrollable bottom sheet
// CustomBottomSheet.showScrollable(
//   context: context,
//   title: "Terms & Conditions",
//   child: TermsContent(),
// );

// // 4. Modal (can't dismiss by tapping outside)
// CustomBottomSheet.showModal(
//   context: context,
//   title: "Confirm Action",
//   child: ConfirmationWidget(),
// );

// // 5. Full screen bottom sheet
// CustomBottomSheet.showFullScreen(
//   context: context,
//   title: "Edit Profile",
//   child: EditProfileForm(),
// );

// // 6. Custom height
// CustomBottomSheet.show(
//   context: context,
//   child: YourWidget(),
//   height: 0.5, // 50% of screen height
// );

// // 7. Custom background color
// CustomBottomSheet.show(
//   context: context,
//   child: YourWidget(),
//   backgroundColor: Colors.blue,
// );

// // 8. Without drag handle
// CustomBottomSheet.show(
//   context: context,
//   child: YourWidget(),
//   showDragHandle: false,
// );

// // 9. Get return value
// final result = await CustomBottomSheet.show<String>(
//   context: context,
//   child: SelectionWidget(),
// );
// if (result != null) {
//   print('User selected: $result');
// }