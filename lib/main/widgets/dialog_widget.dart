  // void _showSuccessDialog(BuildContext context, AuthProvider authProvider) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.r),
  //         ),
  //         content: Container(
  //           padding: EdgeInsets.all(20.w),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 80.w,
  //                 height: 80.h,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: AppTheme.success.withOpacity(0.1),
  //                 ),
  //                 child: Icon(
  //                   Icons.check_circle,
  //                   size: 50.sp,
  //                   color: AppTheme.success,
  //                 ),
  //               ),
  //               SizedBox(height: 20.h),
  //               Text(
  //                 'Account Created Successfully!',
  //                 textAlign: TextAlign.center,
  //                 style: TextConstants.mediumText,
  //               ),
  //               SizedBox(height: 12.h),
  //               Text(
  //                 'Welcome to CAMPCON! Your account has been set up and you can now start connecting with your campus community.',
  //                 textAlign: TextAlign.center,
  //                 style: TextConstants.smallText.copyWith(
  //                   color: AppTheme.textSecondary,
  //                 ),
  //               ),
  //               SizedBox(height: 30.h),
  //               CustomButton(
  //                 text: 'Get Started',
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   _navigateToMain(context);
  //                 },
  //                 backgroundColor: Constants.primaryDark,
  //                 textColor: Constants.black,
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }