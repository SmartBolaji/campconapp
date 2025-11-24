import 'package:campcon/main/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Usertile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  
  const Usertile({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Constants.primarybackground),
            borderRadius: BorderRadius.circular(15.r)
          ),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              SizedBox(width: 10.w),
              Text(text)
            ],
          ),
        ),
      ),
    );
  }
}
