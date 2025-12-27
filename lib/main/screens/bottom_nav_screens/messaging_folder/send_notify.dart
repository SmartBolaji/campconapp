import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

Future<void> sendPushNotification({
  required String token,
  required String name,
  required String message,
  required String profileImg,
  required String uid,
  String type = 'message',
}) async {
  try {
    if (token.isEmpty) {
      debugPrint('FCM token is empty, cannot send notification');
      return;
    }

    debugPrint('Attempting to send notification to: $token');

    // Create the data map and log it before sending
    final Map<String, dynamic> data = {
      'token': token,
      'name': name,
      'message': message,
      'profileImg': profileImg,
      'uid': uid,
      'type': type,
    };

    debugPrint('Sending data to Cloud Function: $data');

    // Update the function name to match your deployed function
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendMessageNotification',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 60),
            ));

    final result = await callable.call(data);

    debugPrint('FCM notification result: ${result.data}');
  } catch (e) {
    debugPrint('Error sending FCM notification: $e');
  }
}
