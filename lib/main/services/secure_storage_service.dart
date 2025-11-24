import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Keys
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyUserData = 'user_data';

  // Save authentication status
  static Future<void> saveAuthStatus({
    required String userId,
    required String email,
    Map<String, dynamic>? userData,
  }) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
      await _storage.write(key: _keyUserEmail, value: email);
      await _storage.write(key: _keyIsAuthenticated, value: 'true');

      if (userData != null) {
        await _storage.write(
          key: _keyUserData,
          value: jsonEncode(userData),
        );
      }
    } catch (e) {
      print('Error saving auth status: $e');
      rethrow;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final value = await _storage.read(key: _keyIsAuthenticated);
      return value == 'true';
    } catch (e) {
      print('Error checking auth status: $e');
      return false;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(key: _keyUserData);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserEmail);
      await _storage.delete(key: _keyIsAuthenticated);
      await _storage.delete(key: _keyUserData);
    } catch (e) {
      print('Error clearing auth data: $e');
      rethrow;
    }
  }

  // Clear all storage
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing all storage: $e');
      rethrow;
    }
  }
}
