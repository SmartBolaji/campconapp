import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/widgets/dialogs/student_details_dialog.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/provider/animated_provider.dart';

class UserTypeDialog extends StatefulWidget {
  final Function(
    bool isStudent, {
    Map<String, String>? studentDetails,
    List<String>? interests,
  }) onSelection;

  const UserTypeDialog({
    super.key,
    required this.onSelection,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Function(
      bool isStudent, {
      Map<String, String>? studentDetails,
      List<String>? interests,
    }) onSelection,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AnimatedProvider()..show(),
        child: UserTypeDialog(onSelection: onSelection),
      ),
    );
  }

  @override
  State<UserTypeDialog> createState() => _UserTypeDialogState();
}

class _UserTypeDialogState extends State<UserTypeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: appColors.surface,
          child: Consumer<AnimatedProvider>(
            builder: (context, provider, child) {
              return AnimatedOpacity(
                opacity: provider.isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              _controller.reverse().then((_) {
                                Navigator.of(context).pop();
                              });
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Icon(
                              Icons.close,
                              color: appColors.textPrimary,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Small center text
                      _buildAnimatedText(
                        'Help us curate your feed',
                        TextConstants.small(context).copyWith(
                          fontSize: 13.sp,
                          color: appColors.textSecondary,
                        ),
                        delay: 0,
                      ),

                      SizedBox(height: 12.h),

                      // Main question (bolder text)
                      _buildAnimatedText(
                        'Are you a student?',
                        TextConstants.bold(context).copyWith(
                          fontSize: 22.sp,
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        delay: 100,
                      ),

                      SizedBox(height: 30.h),

                      // Options
                      Column(
                        children: [
                          // Yes option
                          _buildAnimatedOption(
                            label: 'Yes',
                            delay: 200,
                            onTap: () async {
                              await _controller.reverse();
                              if (mounted) {
                                Navigator.of(context).pop(true);

                                // Show student details dialog
                                final result = await StudentDetailsDialog.show(
                                  context,
                                  onSubmit: (studentDetails, {interests}) {
                                    // Call the parent callback with all data
                                    widget.onSelection(
                                      true,
                                      studentDetails: studentDetails,
                                      interests: interests,
                                    );
                                  },
                                );

                                // If user dismissed the dialog without completing
                                if (result == null && mounted) {
                                  // Still mark as student but without details
                                  widget.onSelection(true);
                                }
                              }
                            },
                          ),

                          SizedBox(height: 12.h),

                          // No option
                          _buildAnimatedOption(
                            label: 'No',
                            delay: 300,
                            onTap: () async {
                              await _controller.reverse();
                              if (mounted) {
                                widget.onSelection(false);
                                Navigator.of(context).pop(false);
                              }
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(String text, TextStyle style,
      {required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedOption({
    required String label,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: _AnimatedOptionButton(
              label: label,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedOptionButton extends StatelessWidget {
  final String label;

  final VoidCallback onTap;

  const _AnimatedOptionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Consumer<AnimatedProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTapDown: (_) => provider.pressButton(),
          onTapUp: (_) {
            provider.releaseButton();
            onTap();
          },
          onTapCancel: () => provider.releaseButton(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: appColors.buttonBorder,
              borderRadius: BorderRadius.circular(40.r),
              // boxShadow: provider.isButtonPressed
              //     ? []
              //     : [
              //         BoxShadow(
              //           color: AppTheme.primary.withValues(alpha: 0.15),
              //           blurRadius: 12,
              //           offset: const Offset(0, 6),
              //         ),
              //       ],
            ),
            transform: Matrix4.identity()
              ..scale(provider.isButtonPressed ? 0.95 : 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextConstants.medium(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
