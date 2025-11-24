import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigationHelper {
  // Static method for navigation
  static void navigateTo(BuildContext context, Widget screen,
      [Function? onPop]) {
    Navigator.push(
      context,
      PageTransition(
        child: screen,
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 400),
      ),
    );

    if (onPop != null) {
      onPop();
    }
  }
}
