import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';

void showFloatingSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Color textColor = Colors.white,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextConstants.smallText.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor ?? AppTheme.primary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
