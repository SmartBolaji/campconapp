import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class EmailOTPService {
  static DateTime? _otpSentAt;
  static String? _currentEmail;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Send OTP via Cloud Function (server-side generation + email)
  static Future<bool> sendOTP(String email) async {
    try {
      final callable = _functions.httpsCallable('sendOTP');
      await callable.call({'email': email.trim().toLowerCase()});

      _currentEmail = email.trim().toLowerCase();
      _otpSentAt = DateTime.now();

      debugPrint('OTP request sent for $email');
      return true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} — ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP via Cloud Function (server-side validation)
  static Future<bool> verifyOTP(String email, String otp) async {
    try {
      if (_currentEmail != email.trim().toLowerCase()) {
        debugPrint('OTP verification failed: Email mismatch');
        return false;
      }

      final callable = _functions.httpsCallable('verifyOTP');
      final result = await callable.call({
        'email': email.trim().toLowerCase(),
        'otp': otp,
      });

      final data = result.data as Map<String, dynamic>;
      final verified = data['verified'] == true;

      if (verified) {
        debugPrint('OTP verified successfully');
        _clearOTP();
      }

      return verified;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('OTP verification error: ${e.code} — ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  static void _clearOTP() {
    _otpSentAt = null;
    _currentEmail = null;
  }

  /// Client-side expiry estimate (10-minute window from send time)
  static bool isOTPExpired() {
    if (_otpSentAt == null) return true;
    return DateTime.now().difference(_otpSentAt!).inMinutes >= 10;
  }

  /// Remaining seconds until estimated client-side expiry
  static int getRemainingSeconds() {
    if (_otpSentAt == null) return 0;
    final elapsed = DateTime.now().difference(_otpSentAt!).inSeconds;
    final remaining = (10 * 60) - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  static void configure() {
    // No client-side configuration needed — all handled server-side
  }
}
