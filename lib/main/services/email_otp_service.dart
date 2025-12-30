import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailOTPService {
  // ⚠️ WARNING: Storing API keys in client code is not secure!
  // Consider using Cloud Functions instead
  static const String _resendApiKey = 're_RfhfpD3o_KZBANSSfVW7pBpqKyfwcMyjR';

  static String? _currentOTP;
  static String? _currentEmail;
  static DateTime? _otpExpiry;

  /// Generate a 6-digit OTP code
  static String _generateOTP() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Send OTP to the user's email via Resend API
  static Future<bool> sendOTP(String email) async {
    try {
      // Generate OTP
      _currentOTP = _generateOTP();
      _currentEmail = email.trim().toLowerCase();
      _otpExpiry = DateTime.now().add(const Duration(minutes: 10));

      final htmlContent = '''
        <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; padding: 20px 0;">
            <h1 style="color: #EFA101; margin: 0;">Campcon</h1>
            <p style="color: #666; margin-top: 5px;">Connect with students</p>
          </div>
          
          <div style="background: #f9f9f9; border-radius: 12px; padding: 30px; text-align: center;">
            <h2 style="color: #333; margin-bottom: 10px;">Verify Your Email</h2>
            <p style="color: #666; margin-bottom: 25px;">
              Use the code below to verify your email address and complete your registration.
            </p>
            
            <div style="background: #fff; border: 2px dashed #EFA101; border-radius: 8px; padding: 20px; margin: 20px 0;">
              <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #EFA101;">
                $_currentOTP
              </span>
            </div>
            
            <p style="color: #999; font-size: 13px; margin-top: 20px;">
              This code expires in <strong>10 minutes</strong>.
            </p>
          </div>
          
          <div style="text-align: center; padding: 20px 0; color: #999; font-size: 12px;">
            <p>If you didn't request this code, you can safely ignore this email.</p>
            <p>© ${DateTime.now().year} Campcon. All rights reserved.</p>
          </div>
        </div>
      ''';

      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $_resendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'Campcon <no-reply@dressfli.com>',
          'to': email,
          'subject': 'Your Campcon Verification Code',
          'html': htmlContent,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('OTP sent to $email: $_currentOTP');
        return true;
      } else {
        debugPrint(
            'Resend API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify the OTP entered by the user
  static bool verifyOTP(String email, String otp) {
    try {
      if (_currentOTP == null || _currentEmail == null || _otpExpiry == null) {
        debugPrint('OTP verification failed: No OTP generated');
        return false;
      }

      if (_currentEmail != email.trim().toLowerCase()) {
        debugPrint('OTP verification failed: Email mismatch');
        return false;
      }

      if (DateTime.now().isAfter(_otpExpiry!)) {
        debugPrint('OTP verification failed: OTP expired');
        _clearOTP();
        return false;
      }

      bool isValid = _currentOTP == otp;

      if (isValid) {
        debugPrint('OTP verified successfully');
        _clearOTP();
      } else {
        debugPrint('OTP verification failed: Invalid OTP');
      }

      return isValid;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  static void _clearOTP() {
    _currentOTP = null;
    _currentEmail = null;
    _otpExpiry = null;
  }

  static bool isOTPExpired() {
    if (_otpExpiry == null) return true;
    return DateTime.now().isAfter(_otpExpiry!);
  }

  static int getRemainingSeconds() {
    if (_otpExpiry == null) return 0;
    final remaining = _otpExpiry!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  static void configure() {
    // No configuration needed
  }
}
