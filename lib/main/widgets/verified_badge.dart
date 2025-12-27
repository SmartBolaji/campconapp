import 'package:flutter/material.dart';

class VerifyBadge extends StatelessWidget {
  final String role;
  final bool getVerified;
  final double size;

  const VerifyBadge({
    super.key,
    required this.role,
    this.getVerified = false, // Set default to false
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    // Return empty container if role is user and not verified
    if (role.toLowerCase() == 'user' && !getVerified) {
      return const SizedBox.shrink();
    }

    // Default color for unverified users
    Color badgeColor = Colors.transparent;

    switch (role.toLowerCase()) {
      case 'pro':
        badgeColor = const Color(0xFFa62c71);
        break;
      case 'seller pro':
        badgeColor = Colors.black;
        break;
      case 'org':
        badgeColor = const Color(0xFF4a90e2); // Nice blue color
        break;
      case 'user':
        badgeColor = const Color(0xFFa62c71);
        break;
      case 'mod':
        badgeColor = const Color(0xFF2ecc71); // Emerald green
        break;
      case 'admin':
        badgeColor = const Color(0xFFe74c3c); // Bright red
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2, left: 5),
      child: Icon(
        Icons.verified_rounded,
        color: badgeColor,
        size: size,
      ),
    );
  }
}
