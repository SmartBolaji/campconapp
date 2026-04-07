import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final double size;

  const RoleBadge({
    super.key,
    required this.role,
    this.size = 16,
  });

  Color _getBadgeColor() {
    switch (role.toLowerCase()) {
      case 'verified':
        return AppTheme.primaryDark;
      case 'gov':
        return const Color(0xFF666666); // Grey/Dark Grey
      case 'org':
        return const Color(0xFF8B2E4F); // Burgundy
      default:
        return Colors.transparent;
    }
  }

  String _getBadgeLabel() {
    switch (role.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'gov':
        return 'Government';
      case 'org':
        return 'Organization';
      default:
        return '';
    }
  }

  bool _shouldShowBadge() {
    return role.toLowerCase() != 'user' && role.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowBadge()) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Iconify(
          Ph.check,
          size: size * 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}
