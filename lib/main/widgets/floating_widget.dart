import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';

void showFloatingSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  Color textColor = Colors.white,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextConstants.small(context).copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor ?? colorScheme.primary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
