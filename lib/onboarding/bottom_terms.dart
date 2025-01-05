import 'package:flutter/material.dart';

class TermsAndConditionsBottomSheet extends StatelessWidget {
  final Function onTapTerms;

  const TermsAndConditionsBottomSheet({Key? key, required this.onTapTerms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      height: 80, // Adjust the height of the bottom sheet as needed
      color: Colors.grey.shade300,
      child: GestureDetector(
        onTap: () => onTapTerms(),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lato',
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
            children: const [
              TextSpan(
                text: 'By continuing, you agree to our ',
              ),
              TextSpan(
                text: 'Terms and Conditions',
                style: TextStyle(
                  color: Color(0xFFBA9E02),
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: ' and our ',
              ),
              TextSpan(
                text: 'Privacy Policy.',
                style: TextStyle(
                  color: Color(0xFFBA9E02),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
