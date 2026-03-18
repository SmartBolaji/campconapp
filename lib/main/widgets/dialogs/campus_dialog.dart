import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/constants/vars_constants.dart';
import 'package:provider/provider.dart';
import 'package:campcon/main/provider/animated_provider.dart';

class CampusDialog extends StatefulWidget {
  final Function(String campus) onSelection;

  const CampusDialog({
    super.key,
    required this.onSelection,
  });

  static Future<String?> show(
    BuildContext context, {
    required Function(String campus) onSelection,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => AnimatedProvider()..show(),
        child: CampusDialog(onSelection: onSelection),
      ),
    );
  }

  @override
  State<CampusDialog> createState() => _CampusDialogState();
}

class _CampusDialogState extends State<CampusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<String> _campusList =
      UsableData().campusList; //  Changed from schoolList to campusList
  String? _selectedCampus;

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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: AppTheme.surface,
          child: Consumer<AnimatedProvider>(
            builder: (context, provider, child) {
              return AnimatedOpacity(
                opacity: provider.isContentVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width: 24), // Placeholder for centering
                          Text(
                            'Select Your Hall',
                            style: TextConstants.boldText.copyWith(
                              fontSize: 20.sp,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

                      SizedBox(height: 12.h),

                      // Description
                      _buildAnimatedText(
                        'Choose your hall to connect with your hall mates', //  Changed description
                        TextConstants.smallText.copyWith(
                          fontSize: 13.sp,
                          color: AppTheme.textSecondary,
                        ),
                        delay: 0,
                      ),

                      SizedBox(height: 24.h),

                      // Campus list
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _campusList.length,
                          itemBuilder: (context, index) {
                            final campus = _campusList[index];
                            final isSelected = _selectedCampus == campus;

                            return _buildAnimatedCampusOption(
                              campus: campus,
                              isSelected: isSelected,
                              delay: index * 50,
                              onTap: () {
                                setState(() {
                                  _selectedCampus = campus;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Continue button
                      _buildAnimatedButton(
                        delay: _campusList.length * 50,
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

  Widget _buildAnimatedCampusOption({
    required String campus,
    required bool isSelected,
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
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.buttonBorder,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .home_outlined, //  Changed icon from school to home
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          campus,
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primary,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({required int delay}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: _AnimatedContinueButton(
              isEnabled: _selectedCampus != null,
              onTap: () async {
                if (_selectedCampus != null) {
                  await _controller.reverse();
                  if (mounted) {
                    widget.onSelection(_selectedCampus!);
                    Navigator.of(context).pop(_selectedCampus);
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedContinueButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const _AnimatedContinueButton({
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimatedProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTapDown: isEnabled ? (_) => provider.pressButton() : null,
          onTapUp: isEnabled
              ? (_) {
                  provider.releaseButton();
                  onTap();
                }
              : null,
          onTapCancel: isEnabled ? () => provider.releaseButton() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: isEnabled ? AppTheme.primary : AppTheme.border,
              borderRadius: BorderRadius.circular(40.r),
              boxShadow: isEnabled && !provider.isButtonPressed
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            transform: Matrix4.identity()
              ..scale(provider.isButtonPressed && isEnabled ? 0.95 : 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? AppTheme.white : AppTheme.textLight,
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
