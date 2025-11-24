import 'package:flutter/material.dart';

void showFloatingSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = const Color(0xFFa62c71),
  Color textColor = Colors.white,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'Nexa Light',
        fontWeight: FontWeight.bold,
      ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 2),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
