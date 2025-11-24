import 'package:campcon/main/widgets/post_optionbtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onItemTap;
  final VoidCallback onServiceTap;

  const PostOptionsBottomSheet({
    Key? key,
    required this.onItemTap,
    required this.onServiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PostOptionButton(
                icon: Icons.shopping_bag_outlined,
                label: 'List an Item',
                onTap: onItemTap,
              ),
              PostOptionButton(
                icon: Icons.home_repair_service_outlined,
                label: 'List a service',
                onTap: onServiceTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}