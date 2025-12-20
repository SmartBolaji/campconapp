import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart'; // Add this import
import '../models/user_model.dart';
import '../services/backblaze.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Backblaze service instance
  final BackblazeService _backblazeService = BackblazeService(
    keyId: '0050fae555030410000000003',
    applicationKey: 'K005wG+vROJBYZFRpo0HVDn+Q4V3+zw',
    bucketId: 'f0ef2ace6525c59093a00411',
    bucketName: 'Campcon-Media',
  );

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController aboutmeController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  File? _profileImage;
  String? _errorMessage;
  UserModel? _currentUser;

  // Email verification state
  Timer? _verificationTimer;
  bool _isEmailVerified = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  // Username availability state
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _lastCheckedUsername;

  // Initialization state
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  File? get profileImage => _profileImage;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.currentUser != null;
  bool get isEmailVerified => _isEmailVerified;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown == 0;

  // Getters for username state
  bool get isCheckingUsername => _isCheckingUsername;
  bool? get isUsernameAvailable => _isUsernameAvailable;

  bool get isInitialized => _isInitialized;

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Create account with email only (no password required from user)
  Future<bool> createAccount() async {
    if (emailController.text.trim().isEmpty) {
      setError('Please enter your email');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      setError('Please enter a valid email');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      UserCredential? result = await _authService.signUpWithEmail(
        emailController.text.trim(),
      );

      if (result != null && result.user != null) {
        _isEmailVerified = false;
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Failed to create account. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      print('Error creating account: $e');

      if (e is FirebaseAuthException) {
        setError(_getErrorMessage(e.code));
      } else {
        setError(
            'Failed to create account. Please check your internet connection.');
      }
      return false;
    }
  }

  // Start checking email verification status
  void startEmailVerificationCheck() {
    _verificationTimer?.cancel();
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      await checkEmailVerified();
    });
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      bool verified = await _authService.checkEmailVerified();
      if (verified) {
        _isEmailVerified = true;
        _verificationTimer?.cancel();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking verification: $e');
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    if (!canResend) {
      setError('Please wait before resending');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      await _authService.resendVerificationEmail();
      _startResendTimer();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      print('Error resending verification: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'too-many-requests') {
          setError('Too many requests. Please try again later.');
        } else {
          setError('Failed to send verification email. Please try again.');
        }
      } else {
        setError('Failed to send verification email. Please try again.');
      }
      return false;
    }
  }

  // Start resend countdown timer
  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Stop verification check
  void stopVerificationCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  // Initialize user from secure storage
  Future<void> initializeUser() async {
    try {
      // Check if user is authenticated in secure storage
      bool isAuth = await SecureStorageService.isAuthenticated();

      if (!isAuth) {
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Get current Firebase user
      User? firebaseUser = _authService.currentUser;

      if (firebaseUser == null) {
        // Firebase user is null but secure storage says authenticated
        // Clear storage and require re-login
        await SecureStorageService.clearAuthData();
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Get user data from Firestore
      _currentUser = await _authService.getUserData(firebaseUser.uid);

      if (_currentUser != null) {
        // Update secure storage with latest data
        await SecureStorageService.saveAuthStatus(
          userId: _currentUser!.uid,
          email: _currentUser!.email,
          userData: _currentUser!.toMap(),
        );
      } else {
        // User data not found in Firestore
        await SecureStorageService.clearAuthData();
        await _authService.signOut();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing user: $e');
      await SecureStorageService.clearAuthData();
      await _authService.signOut();
      _currentUser = null;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setError('Please fill in all fields');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result != null && result.user != null) {
        _currentUser = await _authService.getUserData(result.user!.uid);

        if (_currentUser != null) {
          // Save to secure storage
          await SecureStorageService.saveAuthStatus(
            userId: _currentUser!.uid,
            email: _currentUser!.email,
            userData: _currentUser!.toMap(),
          );
        }

        setLoading(false);
        return true;
      }

      setLoading(false);
      return false;
    } catch (e) {
      setLoading(false);
      String userFacingMessage = 'An unknown sign-in error occurred.';

      if (e is FirebaseAuthException) {
        userFacingMessage = _getErrorMessage(e.code);
      } else {
        userFacingMessage =
            'A network connection error occurred. Please try again.';
      }

      print('Sign in error: $e');
      setError(userFacingMessage);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      UserCredential? result = await _authService.signInWithGoogle();

      if (result != null && result.user != null) {
        _currentUser = await _authService.getUserData(result.user!.uid);

        if (_currentUser != null) {
          // Save to secure storage
          await SecureStorageService.saveAuthStatus(
            userId: _currentUser!.uid,
            email: _currentUser!.email,
            userData: _currentUser!.toMap(),
          );
        }

        setLoading(false);
        return true;
      }

      setLoading(false);
      return false;
    } catch (e) {
      setLoading(false);
      String userFacingMessage = 'Failed to sign in with Google.';

      if (e is FirebaseAuthException) {
        userFacingMessage = _getErrorMessage(e.code);
      }

      print('Google sign in error: $e');
      setError(userFacingMessage);
      return false;
    }
  }

  // Create account with Google
  Future<Map<String, dynamic>> createAccountWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      UserCredential? result =
          await _authService.signInWithGoogle(createProfile: false);

      if (result != null && result.user != null) {
        bool needsSetup =
            await _authService.needsProfileSetup(result.user!.uid);

        if (needsSetup) {
          _prefillGoogleData(result.user!);
        } else {
          _currentUser = await _authService.getUserData(result.user!.uid);

          if (_currentUser != null) {
            // Save to secure storage
            await SecureStorageService.saveAuthStatus(
              userId: _currentUser!.uid,
              email: _currentUser!.email,
              userData: _currentUser!.toMap(),
            );
          }
        }

        setLoading(false);
        return {
          'success': true,
          'needsProfileSetup': needsSetup,
          'user': result.user,
        };
      }

      setLoading(false);
      return {'success': false, 'needsProfileSetup': false};
    } catch (e) {
      setLoading(false);
      String userFacingMessage = 'Failed to sign up with Google.';

      if (e is FirebaseAuthException) {
        userFacingMessage = _getErrorMessage(e.code);
      }

      print('Google sign up error: $e');
      setError(userFacingMessage);
      return {'success': false, 'needsProfileSetup': false};
    }
  }

  // Pre-fill form fields with Google account data
  void _prefillGoogleData(User user) {
    if (user.email != null && emailController.text.isEmpty) {
      emailController.text = user.email!;
    }

    if (user.displayName != null && nameController.text.isEmpty) {
      nameController.text = user.displayName!;
    }

    if (usernameController.text.isEmpty) {
      String suggestion = user.email?.split('@')[0].toLowerCase() ??
          user.displayName?.toLowerCase().replaceAll(' ', '') ??
          'user';
      usernameController.text = suggestion;
    }

    notifyListeners();
  }

  // Complete user profile setup with Backblaze upload
  Future<bool> completeProfileSetup() async {
    if (nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      setError('Please fill in all fields');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      User? firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        setError('Authentication error. Please try again.');
        setLoading(false);
        return false;
      }

      // Check username availability
      bool usernameAvailable = await _authService
          .isUsernameAvailable(usernameController.text.trim());
      if (!usernameAvailable) {
        setError('Username is already taken');
        setLoading(false);
        return false;
      }

      String? profileImageUrl;

      // Upload profile image to Backblaze if exists
      if (_profileImage != null) {
        try {
          debugPrint('📸 Compressing and uploading profile image...');

          // Compress the image first
          File compressedImage =
              await _backblazeService.compressImage(_profileImage!);

          debugPrint('✅ Image compressed successfully');

          // Upload compressed image to Backblaze
          profileImageUrl = await _backblazeService.uploadFile(compressedImage);

          debugPrint('✅ Image uploaded to Backblaze: $profileImageUrl');

          // Clean up compressed file if it's different from original
          if (compressedImage.path != _profileImage!.path) {
            try {
              await compressedImage.delete();
            } catch (e) {
              debugPrint('Warning: Could not delete temp file: $e');
            }
          }
        } catch (e) {
          debugPrint('❌ Error uploading image: $e');
          // Don't fail the entire profile setup if image upload fails
          // User can update profile picture later
          setError(
              'Profile created but image upload failed. You can update it later.');
        }
      }

      // Create user model
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? emailController.text.trim(),
        phoneNumber: firebaseUser.phoneNumber ?? '',
        name: nameController.text.trim(),
        username: usernameController.text.trim().toLowerCase(),
        aboutMe: aboutmeController.text.trim(),
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _authService.saveUserData(newUser);
      _currentUser = newUser;

      // Save to secure storage
      await SecureStorageService.saveAuthStatus(
        userId: newUser.uid,
        email: newUser.email,
        userData: newUser.toMap(),
      );

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('❌ Error in completeProfileSetup: $e');
      setError(_getErrorMessage(e));
      return false;
    }
  }

  // Pick profile image from camera or gallery
  Future<void> pickProfileImage({bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      _profileImage = File(image.path);
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await SecureStorageService.clearAuthData();
      _currentUser = null;
      _clearControllers();
      _verificationTimer?.cancel();
      _resendTimer?.cancel();
      notifyListeners();
    } catch (e) {
      setError(_getErrorMessage(e));
    }
  }

  // Forgot password
  Future<bool> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      setError('Please enter your email');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e));
      return false;
    }
  }

  // Check username availability with debouncing
  Future<void> checkUsernameAvailability(String username) async {
    // Prevent checking the same username multiple times
    if (_lastCheckedUsername == username.toLowerCase()) {
      return;
    }

    _isCheckingUsername = true;
    _isUsernameAvailable = null;
    notifyListeners();

    try {
      // Wait a bit to avoid too many requests while typing
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if the username changed while waiting
      if (usernameController.text.trim().toLowerCase() !=
          username.toLowerCase()) {
        _isCheckingUsername = false;
        notifyListeners();
        return;
      }

      bool available = await _authService.isUsernameAvailable(username);

      _isUsernameAvailable = available;
      _lastCheckedUsername = username.toLowerCase();
      _isCheckingUsername = false;
      notifyListeners();
    } catch (e) {
      _isCheckingUsername = false;
      _isUsernameAvailable = null;
      notifyListeners();
      print('Error checking username: $e');
    }
  }

  // Reset username availability state
  void resetUsernameCheck() {
    _isUsernameAvailable = null;
    _lastCheckedUsername = null;
    _isCheckingUsername = false;
    notifyListeners();
  }

  // Update user type (student or not) with student details
  Future<bool> updateUserType(
    bool isStudent, {
    Map<String, String>? studentDetails,
    List<String>? interests, // Add this
  }) async {
    if (_currentUser == null) {
      setError('No user found');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      await _authService.updateUserType(
        _currentUser!.uid,
        isStudent,
        studentDetails: studentDetails,
        interests: interests, // Add this
      );

      // Update local user model
      _currentUser = _currentUser!.copyWith(
        isStudent: isStudent,
        school: studentDetails?['school'],
        level: studentDetails?['level'],
        department: studentDetails?['department'],
        interests: interests, // Add this
        updatedAt: DateTime.now(),
      );

      // Update secure storage
      await SecureStorageService.saveAuthStatus(
        userId: _currentUser!.uid,
        email: _currentUser!.email,
        userData: _currentUser!.toMap(),
      );

      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError('Failed to update user type');
      print('Error updating user type: $e');
      return false;
    }
  }

  // Update user password
  Future<bool> updatePassword(String newPassword) async {
    setLoading(true);
    clearError();

    try {
      User? user = _authService.currentUser;
      if (user == null) {
        setError('No user is currently signed in');
        setLoading(false);
        return false;
      }

      await user.updatePassword(newPassword);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      print('Error updating password: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'requires-recent-login') {
          setError(
              'For security reasons, please sign out and sign in again before changing your password.');
        } else {
          setError(_getErrorMessage(e));
        }
      } else {
        setError('Failed to update password. Please try again.');
      }
      return false;
    }
  }

  /// Update user profile with new data and optional profile image
  Future<bool> updateProfile({
    required String name,
    required String username,
    required String aboutMe,
    File? newProfileImage,
    String? originalUsername,
  }) async {
    if (_currentUser == null) {
      setError('User not found');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Check if username changed and is available
      if (username.trim().toLowerCase() != originalUsername?.toLowerCase()) {
        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username.trim().toLowerCase())
            .get();

        if (usernameQuery.docs.isNotEmpty) {
          setLoading(false);
          setError('Username already taken');
          return false;
        }
      }

      String? newImageUrl;

      // Upload new profile image if changed
      if (newProfileImage != null) {
        try {
          debugPrint('📸 Compressing and uploading new profile image...');

          File compressedImage =
              await _backblazeService.compressImage(newProfileImage);
          newImageUrl = await _backblazeService.uploadFile(compressedImage);

          debugPrint('✅ New profile image uploaded: $newImageUrl');

          // Clean up temp file
          if (compressedImage.path != newProfileImage.path) {
            try {
              await compressedImage.delete();
            } catch (e) {
              debugPrint('Warning: Could not delete temp file: $e');
            }
          }
        } catch (e) {
          debugPrint('❌ Error uploading image: $e');
          setLoading(false);
          setError('Failed to upload image');
          return false;
        }
      }

      // Update Firestore
      Map<String, dynamic> updates = {
        'name': name.trim(),
        'username': username.trim().toLowerCase(),
        'aboutMe': aboutMe.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (newImageUrl != null) {
        updates['profileImageUrl'] = newImageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updates);

      // Update local user model
      _currentUser = _currentUser!.copyWith(
        name: name.trim(),
        username: username.trim().toLowerCase(),
        aboutMe: aboutMe.trim(),
        profileImageUrl: newImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // Update secure storage
      await SecureStorageService.saveAuthStatus(
        userId: _currentUser!.uid,
        email: _currentUser!.email,
        userData: _currentUser!.toMap(),
      );

      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('❌ Error updating profile: $e');
      setError('Failed to update profile');
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount(String password) async {
    if (_currentUser == null) {
      setError('No user found');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Re-authenticate user
      bool authenticated = await _authService.reauthenticateUser(password);

      if (!authenticated) {
        setLoading(false);
        setError('Incorrect password');
        return false;
      }

      // Delete account
      await _authService.deleteUserAccount(_currentUser!.uid);

      // Clear secure storage
      await SecureStorageService.clearAuthData();

      // Clear local state
      _currentUser = null;
      _clearControllers();

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('❌ Error deleting account: $e');

      if (e is FirebaseAuthException) {
        if (e.code == 'requires-recent-login') {
          setError(
              'Please sign out and sign in again before deleting your account');
        } else {
          setError(_getErrorMessage(e));
        }
      } else {
        setError('Failed to delete account. Please try again.');
      }
      return false;
    }
  }

  // ✅ Update user campus
  Future<void> updateCampus(String campus) async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'campus': campus,
      });

      _currentUser = _currentUser!.copyWith(campus: campus);
      notifyListeners();

      debugPrint('✅ Campus updated: $campus');
    } catch (e) {
      debugPrint('❌ Error updating campus: $e');
      rethrow;
    }
  }

  // Helper methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    if (error is String) {
      return error;
    }
    return 'An unexpected error occurred.';
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    usernameController.clear();
    aboutmeController.clear();
    _profileImage = null;
    _isEmailVerified = false;
    _resendCountdown = 0;
    // Reset username check state
    _isCheckingUsername = false;
    _isUsernameAvailable = null;
    _lastCheckedUsername = null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    aboutmeController.dispose();
    _verificationTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }
}
