import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const ProfileButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Constants.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: TextConstants.smallText.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
