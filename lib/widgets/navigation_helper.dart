import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigationHelper {
  // Static method for navigation
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageTransition(
        child: screen,
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
