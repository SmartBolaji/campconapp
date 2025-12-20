// import 'package:campcon/main/constants/app_colors.dart';
// import 'package:campcon/main/constants/text_constants.dart';
// import 'package:campcon/main/models/story_model.dart';
// import 'package:campcon/main/provider/chat_provider.dart';

// import 'package:campcon/main/provider/friends_provider.dart';
// import 'package:campcon/main/screens/chat_screen.dart';
// import 'package:campcon/main/widgets/custom_btn.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// class FriendsScreen extends StatelessWidget {
//   const FriendsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FriendsTabProvider>(
//       builder: (context, provider, child) {
//         return Column(
//           children: [
//             // Container(
//             //   margin: EdgeInsets.only(top: 20.h),
//             //   height: 120.h,
//             //   padding: const EdgeInsets.symmetric(vertical: 16),
//             //   child: ListView(
//             //     scrollDirection: Axis.horizontal,
//             //     padding: const EdgeInsets.symmetric(horizontal: 16),
//             //     children: [
//             //       _buildRandomShotStory(context),
//             //       SizedBox(width: 13.w),
//             //       _buildAddStory(),
//             //       SizedBox(width: 16.w),
//             //       ...provider.stories.map((story) => Padding(
//             //             padding: const EdgeInsets.only(right: 16),
//             //             child: _buildStoryItem(story),
//             //           )),
//             //     ],
//             //   ),
//             // ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildRandomShotStory(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showRandomChatDialog(context),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 width: 62.w,
//                 height: 60.h,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Constants.primaryDark, Constants.primaryColors],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Center(
//                   child: Text('?',
//                       style: TextConstants.boldText
//                           .copyWith(color: Constants.white)),
//                 ),
//               ),
//               Positioned(
//                 bottom: -4,
//                 right: -4,
//                 child: Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: const Icon(Icons.add, size: 16, color: Colors.orange),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Random\nShot',
//             textAlign: TextAlign.center,
//             style: TextConstants.smallText.copyWith(
//               fontSize: 9.sp,
//               color: Constants.textSecondary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showRandomChatDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Padding(
//             padding: const EdgeInsets.all(18),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Constants.primaryDark,
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '?',
//                               style: TextConstants.mediumText.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10.w),
//                         Text(
//                           'Random chat',
//                           style: TextConstants.mediumText.copyWith(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Connect instantly with another person nearby. You\'ll both be anonymous — just a fun way to chat, share vibes, or meet new people. If it clicks, you can reveal your profile later.',
//                   textAlign: TextAlign.center,
//                   style: TextConstants.smallText.copyWith(
//                     fontSize: 13.sp,
//                     height: 1.5,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Be respectful.Inappropriate behaviour leads to a ban',
//                       style: TextConstants.smallText.copyWith(
//                           fontSize: 10.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Constants.error),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(Icons.warning_amber_rounded,
//                         size: 16, color: Colors.grey.shade600),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 CustomButton(
//                   text: 'Random chat',
//                   onPressed: () {
//                     Navigator.pop(context);
//                     final chatProvider =
//                         Provider.of<ChatProvider>(context, listen: false);
//                     chatProvider.initializeChat(
//                       currentUserId:
//                           'current_user_id', // Replace with Firebase Auth user ID
//                       chatPartnerId:
//                           'partner_user_id', // Replace with matched partner ID
//                       anonymousPartnerName:
//                           'Hmm ??', // Or any custom anonymous name
//                     );
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const RandomChatScreen()),
//                     );
//                   },
//                   backgroundColor: Constants.primaryDark,
//                   textColor: Colors.black,
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAddStory() {
//     return Column(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//                 color: Colors.grey.shade300,
//                 width: 2,
//                 style: BorderStyle.solid),
//           ),
//           child: Center(
//             child: Icon(Icons.add, color: Colors.grey.shade400, size: 28),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Add Story',
//           style: TextConstants.smallText.copyWith(
//               fontSize: 10.sp,
//               color: Constants.textSecondary,
//               fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }

//   Widget _buildStoryItem(Story story) {
//     return Column(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [Color(0xFFFFA726), Color(0xFFFF6F00), Color(0xFFFFA726)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(2),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Constants.white,
//                 shape: BoxShape.circle,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(2),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Constants.backgroundColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Center(
//                     child: Icon(Icons.person, color: Colors.grey, size: 28),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: 60.w,
//           child: Text(
//             story.name,
//             textAlign: TextAlign.center,
//             style: TextConstants.smallText.copyWith(
//                 fontSize: 10.sp,
//                 color: Constants.textSecondary,
//                 fontWeight: FontWeight.bold),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }
