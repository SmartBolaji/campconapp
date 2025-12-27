import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/message_manager.dart';
import 'package:campcon/main/screens/bottom_nav_screens/messaging_folder/send_notify.dart';
import 'package:campcon/main/services/backblaze.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MessageUploadService {
  static final ImagePicker _picker = ImagePicker();
  static final backblazeService = BackblazeService(
    keyId: '0050fae555030410000000003',
    applicationKey: 'K005wG+vROJBYZFRpo0HVDn+Q4V3+zw',
    bucketId: 'f0ef2ace6525c59093a00411',
    bucketName: 'Campcon-Media',
  );

  // Main function to handle image selection, cropping and uploading
  static Future<void> pickAndUploadImage({
    required BuildContext context,
    required String currentUserId,
    required String receiverId,
    required String chatId,
    required Function scrollToBottom,
    required Function onClearMessage,
    String? messageText,
    required String fcmToken,
    required String senderName,
    String? senderProfileImg,
  }) async {
    try {
      final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        final croppedImage = await _cropImage(pickedImage.path);

        if (croppedImage != null && context.mounted) {
          // Create file from cropped image
          File imageFile = File(croppedImage.path);

          // Upload in background
          String? imageUrl = await _uploadImage(imageFile);

          if (imageUrl != null) {
            // Clear the text field
            onClearMessage();

            await sendImageMessage(
              currentUserId: currentUserId,
              receiverId: receiverId,
              chatId: chatId,
              imageUrl: imageUrl,
              messageText: messageText,
              scrollToBottom: scrollToBottom,
              fcmToken: fcmToken,
              senderName: senderName,
              senderProfileImg: senderProfileImg,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      // Dismiss loading indicator if an error occurs
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      }
    }
  }

  static Future<CroppedFile?> _cropImage(String imagePath) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.grey.shade800,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppTheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
  }

  static Future<String?> _uploadImage(File imageFile) async {
    try {
      String downloadUrl = await backblazeService.uploadFile(imageFile);
      return downloadUrl;
    } catch (e) {
      debugPrint("Image upload failed: $e");
      return null;
    }
  }

  // Helper to send a message with an image
  static Future<void> sendImageMessage({
    required String currentUserId,
    required String receiverId,
    required String chatId,
    required String imageUrl,
    required String? messageText,
    required Function scrollToBottom,
    required String fcmToken,
    required String senderName,
    required String? senderProfileImg,
  }) async {
    try {
      final chatManager =
          ChatManager(chatId: chatId, currentUserId: currentUserId);

      // Scroll to bottom to show loading state
      scrollToBottom();

      // Send the message through ChatManager
      await chatManager.sendImageMessage(
        text: messageText ?? '',
        receiverId: receiverId,
        imageUrl: imageUrl,
      );

      // Send notification if FCM token exists
      if (fcmToken.isNotEmpty) {
        await sendPushNotification(
          token: fcmToken,
          name: senderName,
          message: messageText?.isNotEmpty == true ? messageText! : '📷 Image',
          profileImg: senderProfileImg ?? '',
          uid: currentUserId,
          type: 'message',
        );
      }
    } catch (e) {
      debugPrint('Error sending image message: $e');
    }
  }
}
