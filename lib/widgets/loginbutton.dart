// import 'package:flutter/material.dart';

// class TaskListPage extends StatefulWidget {
//   @override
//   _TaskListPageState createState() => _TaskListPageState();
// }

// class _TaskListPageState extends State<TaskListPage> {
//   final List<Map<String, dynamic>> tasks = [
//     {
//       "title": "Complete Course Registration",
//       "description":
//           "Ensure all documents are submitted and fees are paid to avoid delays in the registration process.",
//       "subtasks": [
//         {"title": "Submit required documents", "completed": false},
//         {"title": "Pay registration fees", "completed": false},
//         {"title": "Collect registration confirmation", "completed": false},
//       ],
//       "expanded": false,
//     },
//     {
//       "title": "Prepare for Semester Exams",
//       "description":
//           "Start early preparation to achieve the best results in your semester exams.",
//       "subtasks": [
//         {"title": "Review lecture notes", "completed": true},
//         {"title": "Practice past questions", "completed": false},
//         {"title": "Form a study group", "completed": false},
//       ],
//       "expanded": false,
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.grey.shade100,
//         title: const Text(
//           "Task List",
//           style: TextStyle(
//             color: Colors.black,
//             fontFamily: 'Lato',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Icon(
//             Icons.arrow_back,
//             color: Colors.grey.shade800,
//           ),
//         ),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16.0),
//         itemCount: tasks.length,
//         itemBuilder: (context, index) {
//           final task = tasks[index];
//           return Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade300,
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 ListTile(
//                   title: Text(
//                     task['title'],
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontFamily: 'Lato',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   trailing: Icon(
//                     task['expanded']
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                   ),
//                   onTap: () {
//                     setState(() {
//                       task['expanded'] = !task['expanded'];
//                     });
//                   },
//                 ),
//                 if (task['expanded']) ...[
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text(
//                       task['description'],
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         fontFamily: 'Lato',
//                       ),
//                     ),
//                   ),
//                   ...task['subtasks'].map<Widget>((subtask) {
//                     return CheckboxListTile(
//                       title: Text(subtask['title']),
//                       value: subtask['completed'],
//                       onChanged: (value) {
//                         setState(() {
//                           subtask['completed'] = value!;
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
