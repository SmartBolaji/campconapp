// // lib/main/widgets/notification/notification_sort_filter_bar.dart
// import 'package:campcon/main/constants/app_colors.dart';
// import 'package:campcon/main/constants/text_constants.dart';
// import 'package:campcon/main/provider/notify_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:iconify_flutter/iconify_flutter.dart';
// import 'package:iconify_flutter/icons/ph.dart';

// class NotificationSortFilterBar extends StatelessWidget {
//   const NotificationSortFilterBar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NotifyProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 12.h),
//           child: Row(
//             children: [
//               // Sort Button
//               Expanded(
//                 child: _FilterButton(
//                   icon: Ph.sort_ascending_bold,
//                   label: 'Sort',
//                   value: provider.sortBy,
//                   onTap: () => _showSortOptions(context, provider),
//                 ),
//               ),
//               SizedBox(width: 12.w),

//               // Filter Button
//               Expanded(
//                 child: _FilterButton(
//                   icon: Ph.funnel_bold,
//                   label: 'Filter',
//                   value: provider.selectedFilter,
//                   onTap: () => _showFilterOptions(context, provider),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showSortOptions(BuildContext context, NotifyProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppTheme.surface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Drag indicator
//               Center(
//                 child: Container(
//                   width: 40.w,
//                   height: 4.h,
//                   margin: EdgeInsets.only(bottom: 20.h),
//                   decoration: BoxDecoration(
//                     color: AppTheme.border,
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//               ),

//               Text(
//                 'Sort by',
//                 style: TextConstants.mediumText.copyWith(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               ...provider.sortOptions.map((option) {
//                 final isSelected = provider.sortBy == option;
//                 return _OptionTile(
//                   title: option,
//                   isSelected: isSelected,
//                   onTap: () {
//                     provider.changeSortBy(option);
//                     Navigator.pop(context);
//                   },
//                 );
//               }).toList(),

//               SizedBox(height: 20.h),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showFilterOptions(BuildContext context, NotifyProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppTheme.surface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Drag indicator
//               Center(
//                 child: Container(
//                   width: 40.w,
//                   height: 4.h,
//                   margin: EdgeInsets.only(bottom: 20.h),
//                   decoration: BoxDecoration(
//                     color: AppTheme.border,
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//               ),

//               Text(
//                 'Filter by Type',
//                 style: TextConstants.mediumText.copyWith(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               ...provider.filterOptions.map((filter) {
//                 final isSelected = provider.selectedFilter == filter;
//                 return _OptionTile(
//                   title: filter,
//                   isSelected: isSelected,
//                   onTap: () {
//                     provider.changeFilter(filter);
//                     Navigator.pop(context);
//                   },
//                 );
//               }).toList(),

//               SizedBox(height: 20.h),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _FilterButton extends StatelessWidget {
//   final String icon;
//   final String label;
//   final String value;
//   final VoidCallback onTap;

//   const _FilterButton({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         decoration: BoxDecoration(
//           color: AppTheme.background,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: AppTheme.border,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Iconify(
//               icon,
//               size: 18.sp,
//               color: AppTheme.textPrimary,
//             ),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     label,
//                     style: TextConstants.smallText.copyWith(
//                       fontSize: 11.sp,
//                       color: AppTheme.textLight,
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: TextConstants.smallText.copyWith(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.textPrimary,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.keyboard_arrow_down,
//               size: 18.sp,
//               color: AppTheme.textLight,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OptionTile extends StatelessWidget {
//   final String title;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _OptionTile({
//     required this.title,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//         margin: EdgeInsets.only(bottom: 8.h),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppTheme.primary.withValues(alpha: 0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected ? AppTheme.primary : Colors.transparent,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextConstants.mediumText.copyWith(
//                 fontSize: 15.sp,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 Icons.check_circle,
//                 color: AppTheme.primary,
//                 size: 20.sp,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
