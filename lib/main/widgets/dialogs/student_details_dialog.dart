import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:campcon/main/widgets/dialogs/interests_dialog.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/provider/animated_provider.dart';

class StudentDetailsDialog extends StatefulWidget {
  final Function(Map<String, String> details, {List<String>? interests})
      onSubmit;

  const StudentDetailsDialog({
    super.key,
    required this.onSubmit,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Function(Map<String, String> details, {List<String>? interests})
        onSubmit,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AnimatedProvider()..show(),
        child: StudentDetailsDialog(onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<StudentDetailsDialog>
    with SingleTickerProviderStateMixin {
  final UsableData _data = UsableData();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedSchool;
  String? _selectedLevel;
  String? _selectedDepartment;

  List<String> get _departments {
    return _data.departments.map((e) => e['department']!).toList()..sort();
  }

  bool get _isFormValid =>
      _selectedSchool != null &&
      _selectedLevel != null &&
      _selectedDepartment != null;

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
                  child: SingleChildScrollView(
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

                        _buildAnimatedText(
                          'Help us curate your feed',
                          TextConstants.small(context).copyWith(
                            fontSize: 13.sp,
                            color: appColors.textSecondary,
                          ),
                          delay: 0,
                        ),

                        SizedBox(height: 12.h),

                        _buildAnimatedText(
                          'Just a few details...',
                          TextConstants.bold(context).copyWith(
                            fontSize: 22.sp,
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          delay: 100,
                        ),

                        SizedBox(height: 30.h),

                        _buildAnimatedDropdown(
                          label: 'What school do you attend?',
                          value: _selectedSchool,
                          items: _data.schoolList,
                          onChanged: (value) =>
                              setState(() => _selectedSchool = value),
                          delay: 200,
                        ),

                        SizedBox(height: 20.h),

                        _buildAnimatedDropdown(
                          label: 'What level are you in currently?',
                          value: _selectedLevel,
                          items: _data.levelList,
                          onChanged: (value) =>
                              setState(() => _selectedLevel = value),
                          delay: 300,
                        ),

                        SizedBox(height: 20.h),

                        _buildAnimatedDropdown(
                          label: 'What department are you in?',
                          value: _selectedDepartment,
                          items: _departments,
                          onChanged: (value) =>
                              setState(() => _selectedDepartment = value),
                          delay: 400,
                        ),

                        SizedBox(height: 30.h),

                        _buildAnimatedButton(delay: 500),

                        SizedBox(height: 10.h),
                      ],
                    ),
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

  Widget _buildAnimatedDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, animValue, child) {
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(30 * (1 - animValue), 0),
            child: _buildDropdown(
              label: label,
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({required int delay}) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Consumer<AnimatedProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onTapDown:
                      _isFormValid ? (_) => provider.pressButton() : null,
                  onTapUp: _isFormValid
                      ? (_) async {
                          provider.releaseButton();

                          final details = {
                            'school': _selectedSchool!,
                            'level': _selectedLevel!,
                            'department': _selectedDepartment!,
                          };

                          await _controller.reverse();
                          if (mounted) {
                            Navigator.of(context).pop(details);

                            // Show interests dialog
                            final interests = await InterestsDialog.show(
                              context,
                              onSubmit: (selectedInterests) {
                                widget.onSubmit(
                                  details,
                                  interests: selectedInterests,
                                );
                              },
                            );

                            if (interests == null && mounted) {
                              widget.onSubmit(details);
                            }
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
                          ? colorScheme.primary
                          : appColors.buttonBorder,
                      borderRadius: BorderRadius.circular(40.r),
                      // boxShadow: _isFormValid && !provider.isButtonPressed
                      //     ? [
                      //         BoxShadow(
                      //           color: AppTheme.primary.withValues(alpha: 0.4),
                      //           blurRadius: 16,
                      //           offset: const Offset(0, 8),
                      //         ),
                      //       ]
                      //     : [],
                    ),
                    transform: Matrix4.identity()
                      ..scale(
                        _isFormValid && provider.isButtonPressed ? 0.95 : 1.0,
                      ),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: TextConstants.medium(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _isFormValid
                              ? colorScheme.onPrimary
                              : appColors.textLight,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.small(context).copyWith(
            fontSize: 14.sp,
            color: appColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: appColors.buttonBorder,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: appColors.border,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(12.r),
              value: value,
              hint: Text(
                'Select',
                style: TextConstants.small(context).copyWith(
                  color: appColors.textLight,
                  fontSize: 14.sp,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: appColors.textPrimary,
                size: 24.sp,
              ),
              dropdownColor: appColors.surface,
              style: TextConstants.medium(context).copyWith(
                fontSize: 14.sp,
                color: appColors.textPrimary,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextConstants.medium(context).copyWith(
                      fontSize: 14.sp,
                      color: appColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
