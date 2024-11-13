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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              assetImage,
              width: 30,
              height: 30,
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
                    fontSize: screenWidth / 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  userAt,
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 40,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  userBio.length > 50
                      ? '${userBio.substring(0, 50)}...'
                      : userBio,
                  style: TextStyle(
                    fontFamily: 'Trebuchet',
                    fontSize: screenWidth / 40,
                  ),
                  textAlign: TextAlign.left,
                ),
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
                color: isConnected ? Colors.green : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                isConnected ? 'Connected' : 'Connect',
                style: TextStyle(
                  fontFamily: 'Trebuchet',
                  color: Colors.white,
                  fontSize: screenWidth / 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
