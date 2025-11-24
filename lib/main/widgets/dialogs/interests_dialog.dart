import 'dart:math';

import 'package:campcon/main/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/provider/animated_dialog_provider.dart';
import 'package:campcon/main/widgets/dialogs/completion_dialog.dart';

class InterestsDialog extends StatefulWidget {
  final Function(List<String> interests) onSubmit;

  const InterestsDialog({
    super.key,
    required this.onSubmit,
  });

  static Future<List<String>?> show(
    BuildContext context, {
    required Function(List<String> interests) onSubmit,
  }) {
    return showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AnimatedDialogProvider()..show(),
        child: InterestsDialog(onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<InterestsDialog> createState() => _InterestsDialogState();
}

class _InterestsDialogState extends State<InterestsDialog>
    with SingleTickerProviderStateMixin {
  final UsableData _data = UsableData();
  final Set<String> _selectedInterests = {};
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool get _isFormValid => _selectedInterests.isNotEmpty;

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

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppTheme.surface,
          child: Consumer<AnimatedDialogProvider>(
            builder: (context, provider, child) {
              return AnimatedOpacity(
                opacity: provider.isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
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
                              color: AppTheme.textPrimary,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      _buildAnimatedText(
                        'Help us curate your feed',
                        TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textSecondary,
                        ),
                        delay: 0,
                      ),

                      SizedBox(height: 12.h),

                      _buildAnimatedText(
                        'What topics are you\ninterested in?',
                        TextConstants.boldText.copyWith(
                          fontSize: 22.sp,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        delay: 100,
                      ),

                      SizedBox(height: 8.h),

                      _buildAnimatedText(
                        'Select at least one',
                        TextConstants.smallText.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                        delay: 150,
                      ),

                      SizedBox(height: 24.h),

                      // Scrollable interests
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 10.w,
                            runSpacing: 12.h,
                            alignment: WrapAlignment.center,
                            children:
                                _data.interest.asMap().entries.map((entry) {
                              final index = entry.key;
                              final interest = entry.value;
                              final isSelected =
                                  _selectedInterests.contains(interest);
                              return _buildAnimatedChip(
                                interest: interest,
                                isSelected: isSelected,
                                delay: 200 + (index * 30),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      _buildAnimatedButton(
                          delay: 500,
                          authProvider: Provider.of<AuthProvider>(context,
                              listen: false)),

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

  Widget _buildAnimatedChip({
    required String interest,
    required bool isSelected,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: min(600, 300 + delay)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.5 + (0.5 * value),
            child: _InterestChip(
              label: interest,
              isSelected: isSelected,
              onTap: () => _toggleInterest(interest),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton(
      {required int delay, required AuthProvider authProvider}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Consumer<AnimatedDialogProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTapDown:
                      _isFormValid ? (_) => provider.pressButton() : null,
                  onTapUp: _isFormValid
                      ? (_) async {
                          provider.releaseButton();

                          final interests = _selectedInterests.toList();
                          await _controller.reverse();
                          if (mounted) {
                            widget.onSubmit(interests);
                            Navigator.of(context).pop(interests);

                            // Show completion dialog
                            await CompletionDialog.show(
                              context,
                              userName: authProvider.currentUser?.name ??
                                  'User', // You can pass the actual user name from auth provider
                              onComplete: () {
                                // Dialog will be dismissed and user returns to main screen
                              },
                            );
                          }
                        }
                      : null,
                  onTapCancel: () => provider.releaseButton(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: _isFormValid
                          ? AppTheme.primary
                          : AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(40.r),
                      boxShadow: _isFormValid && !provider.isButtonPressed
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    transform: Matrix4.identity()
                      ..scale(
                        _isFormValid && provider.isButtonPressed ? 0.95 : 1.0,
                      ),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _isFormValid
                              ? AppTheme.textPrimary
                              : AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _InterestChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<_InterestChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppTheme.primary : AppTheme.buttonBorder,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: widget.isSelected ? AppTheme.primary : AppTheme.border,
            width: 1.5,
          ),
          boxShadow: widget.isSelected && !_isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.90 : 1.0),
        child: Text(
          widget.label,
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: widget.isSelected
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
