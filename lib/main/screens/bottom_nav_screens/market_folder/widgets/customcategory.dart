
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final Function(String?) onChanged;

  const CustomCategoryDropdown({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Select category', style: TextStyle(color: Colors.grey.shade500)),
            items: categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}