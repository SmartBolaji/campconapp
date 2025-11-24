// import 'package:campcon/main/constants/app_colors.dart';
// import 'package:campcon/main/constants/text_constants.dart';
// import 'package:campcon/main/screens/onboarding/account_setUp.dart';
// import 'package:campcon/main/provider/auth_provider.dart';
// import 'package:campcon/main/widgets/custom_btn.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// class VerificationScreen extends StatefulWidget {
//   const VerificationScreen({super.key});

//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   List<TextEditingController> controllers =
//       List.generate(6, (_) => TextEditingController());
//   List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   String getOTPCode() {
//     return controllers.map((controller) => controller.text).join();
//   }

//   void clearOTPFields() {
//     for (var controller in controllers) {
//       controller.clear();
//     }
//     if (focusNodes.isNotEmpty) {
//       FocusScope.of(context).requestFocus(focusNodes[0]);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Consumer<AuthProvider>(
//         builder: (context, authProvider, child) {
//           return Container(
//             margin: EdgeInsets.only(top: 70.sp),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: const Icon(Icons.arrow_back),
//                       ),
//                       SizedBox(width: 50.w),
//                       Text(
//                         "Enter Verification Code",
//                         style: TextConstants.mediumText,
//                       )
//                     ],
//                   ),
//                   SizedBox(height: 20.h),
//                   Center(
//                     child: RichText(
//                       text: TextSpan(
//                         text: "We sent a code to ",
//                         style: TextConstants.smallText.copyWith(
//                           color: Constants.textLight,
//                           fontSize: 16.sp,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: authProvider.userEmail ?? 'your email',
//                             style: TextConstants.smallText.copyWith(
//                               color: Constants.primaryColors,
//                               fontSize: 16.sp,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20.h),

//                   // OTP Input Fields
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: List.generate(6, (index) {
//                       return Container(
//                         width: 45.w,
//                         height: 45.h,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8.r),
//                         ),
//                         child: TextFormField(
//                           controller: controllers[index],
//                           focusNode: focusNodes[index],
//                           textAlign: TextAlign.center,
//                           style: TextConstants.smallText,
//                           maxLength: 1,
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             counterText: '',
//                             border: InputBorder.none,
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && index < 5) {
//                               FocusScope.of(context)
//                                   .requestFocus(focusNodes[index + 1]);
//                             } else if (value.isEmpty && index > 0) {
//                               FocusScope.of(context)
//                                   .requestFocus(focusNodes[index - 1]);
//                             }
//                           },
//                         ),
//                       );
//                     }),
//                   ),
//                   SizedBox(height: 10.h),

//                   // Error message
//                   if (authProvider.errorMessage != null)
//                     Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10.h),
//                       child: Text(
//                         authProvider.errorMessage!,
//                         style: TextConstants.smallText.copyWith(
//                           color: Constants.error,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),

//                   SizedBox(height: 20.h),

//                   // Resend Code
//                   Center(
//                     child: InkWell(
//                       onTap: authProvider.canResend
//                           ? () => _handleResendOTP(authProvider)
//                           : null,
//                       child: RichText(
//                         text: TextSpan(
//                           text: "Resend Code",
//                           style: TextConstants.smallText.copyWith(
//                             color: authProvider.canResend
//                                 ? Constants.primaryColors
//                                 : Constants.textLight,
//                           ),
//                           children: [
//                             if (!authProvider.canResend)
//                               TextSpan(
//                                 text: ' in ${authProvider.resendCountdown}s',
//                                 style: TextConstants.smallText.copyWith(
//                                   color: Constants.textLight,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 40.h),

//                   // Continue Button
//                   CustomButton(
//                     text: authProvider.isLoading ? "Verifying..." : "Continue",
//                     onPressed: () {
//                       authProvider.isLoading
//                           ? const CircularProgressIndicator()
//                           : () => _handleVerifyOTP(context, authProvider);
//                     },
//                     backgroundColor: Constants.primaryDark,
//                     textColor: Constants.black,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _handleVerifyOTP(
//       BuildContext context, AuthProvider authProvider) async {
//     // Get the OTP code from the fields
//     String otpCode = getOTPCode();

//     if (otpCode.length != 6) {
//       authProvider.setError('Please enter the complete 6-digit code');
//       return;
//     }

//     authProvider.clearError();

//     // Verify OTP
//     bool success = await authProvider.verifyOTP(otpCode);

//     if (success) {
//       // Navigate to account setup screen
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const AccountSetup()),
//         );
//       }
//     } else {
//       // Error message is already set in provider
//       clearOTPFields();
//     }
//   }

//   Future<void> _handleResendOTP(AuthProvider authProvider) async {
//     authProvider.clearError();
//     clearOTPFields();

//     bool success = await authProvider.resendOTP();

//     if (success) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Verification code sent successfully!'),
//             backgroundColor: Constants.primaryColors,
//           ),
//         );
//       }
//     } else {
//       // Error message is already set in provider
//       if (mounted && authProvider.errorMessage != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.errorMessage!),
//             backgroundColor: Constants.error,
//           ),
//         );
//     }
//     }
//   }
// }
