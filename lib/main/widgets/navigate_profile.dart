import 'package:campcon/main/models/user_model.dart';
import 'package:campcon/main/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

/// Navigate to user profile screen
///
/// [context] - BuildContext for navigation
/// [currentUserId] - The ID of the currently logged in user
/// [targetUserData] - Map containing target user's data (uid, name, userId, etc.)
void navigateToProfile(
  BuildContext context,
  String currentUserId,
  Map<String, dynamic> targetUserData,
) {
  final targetUserId = targetUserData['uid'] as String?;

  if (targetUserId == null || targetUserId.isEmpty) {
    debugPrint('Cannot navigate to profile: target user ID is null or empty');
    return;
  }

  // Create UserModel from the data if available
  UserModel? initialUserData;
  try {
    initialUserData = UserModel(
      uid: targetUserId,
      email: targetUserData['email'] ?? '',
      name: targetUserData['name'] ?? 'Unknown',
      username: targetUserData['userId'] ?? targetUserData['username'] ?? '',
      profileImage:
          targetUserData['profileImg'] ?? targetUserData['profileImage'] ?? '',
      bio: targetUserData['bio'] ?? targetUserData['aboutMe'] ?? '',
      isStudent: targetUserData['isStudent'] ?? false,
      // role: targetUserData['role'] ?? 'user',
      createdAt: targetUserData['createdAt'],
      updatedAt: targetUserData['updatedAt'],
      phoneNumber: targetUserData['phoneNumber'] ?? '',
      // fcmToken: targetUserData['fcmToken'] ?? '',
    );
  } catch (e) {
    debugPrint('Error creating UserModel: $e');
  }

  // Navigate to profile screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        userId: targetUserId,
        initialUserData: initialUserData,
      ),
    ),
  );
}
