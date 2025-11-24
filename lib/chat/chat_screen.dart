// import 'package:campcon/chat/chat_page.dart';
// import 'package:campcon/chat/chat_provider.dart';
// import 'package:campcon/chat/usertile.dart';
// import 'package:campcon/main/constants/app_colors.dart';
// import 'package:campcon/main/services/auth_service.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatServiceProvier _chatService = ChatServiceProvier();
//   final AuthService _authService = AuthService();
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold();
//   }

//   Widget _buildUserList() {
//     return StreamBuilder(
//       stream: _chatService.getUserStream(),
//       builder: (context, snapshot) {
//         // has erroer
//         if (snapshot.hasError) {
//           return const Center(
//             child: Text("Error Try again later"),
//           );
//         }
//         // is loadind
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Constants.primaryDark,
//             ),
//           );
//         }

//         return ListView(
//           children:
//               snapshot.hasData!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList()
//         );
//       },
//     );
//   }

//   Widget _buildUserListItem(
//       Map<String, dynamic> userData, BuildContext context) {
//     return Usertile(
//       text: userData["name"],
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => ChatPage(
//             recieveName = userData["name"]
//             ),),);
//       },
//     );
//   }
// }
