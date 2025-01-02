import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeIconColor;
  final Color inactiveIconColor;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.size = 50.0, // Default size of the circle container
    this.activeColor = Colors.amber, // Default active color
    this.inactiveColor = Colors.grey, // Default inactive color
    this.activeIconColor = Colors.white, // Default active icon color
    this.inactiveIconColor = Colors.black, // Default inactive icon color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : inactiveColor,
        ),
        child: Icon(
          icon,
          color: isActive ? activeIconColor : inactiveIconColor,
        ),
      ),
    );
  }
}
