import 'package:campcon/services/task_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSuggestion extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String assetImage;
  final String user;
  final String userAt;
  final String userBio;
  final String userId;

  const UserSuggestion({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.assetImage,
    required this.user,
    required this.userAt,
    required this.userBio,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskData = Provider.of<TaskData>(context);
    final isConnected = taskData.isConnected(userId);

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundImage: AssetImage(
              assetImage,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user,
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                // const SizedBox(height: 2),
                Text(
                  userAt,
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    color: Colors.grey.shade600,
                    fontSize: screenWidth / 30,
                  ),
                  textAlign: TextAlign.left,
                ),
                if (userBio.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        userBio.length > 50
                            ? '${userBio.substring(0, 50)}...'
                            : userBio,
                        style: TextStyle(
                            fontFamily: 'Trebuchet',
                            fontSize: screenWidth / 30,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (isConnected) {
                taskData.disconnectFromUser(userId, taskData.uid);
              } else {
                taskData.connectToUser(userId, taskData.uid);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: isConnected
                  ? Icon(Icons.done,
                      color: Colors.white, size: screenWidth / 20)
                  : Text(
                      'Connect',
                      style: TextStyle(
                        fontFamily: 'Trebuchet',
                        color: Colors.white,
                        fontSize: screenWidth / 30,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
