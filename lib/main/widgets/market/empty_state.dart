import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isItem;
  final VoidCallback onAddPressed;

  const EmptyStateWidget({
    Key? key,
    required this.isItem,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.sp),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isItem
                  ? Icons.shopping_bag_outlined
                  : Icons.home_repair_service_outlined,
              size: 80.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 20.h),
            Text(
              isItem ? 'No items yet' : 'No services yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              isItem
                  ? 'Start listing your items'
                  : 'Start listing your services',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
