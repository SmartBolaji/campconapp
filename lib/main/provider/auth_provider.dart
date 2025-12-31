import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/email_otp_service.dart';
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
  bool _isEmailVerified = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;
  String? _pendingEmail; // Store email until account is created

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
  String? get pendingEmail => _pendingEmail;

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

  // =====================================================
  // NEW OTP-BASED EMAIL VERIFICATION FLOW
  // =====================================================

  /// Send OTP to email (Step 1 - from create_account screen)
  Future<bool> sendEmailOTP() async {
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
      final email = emailController.text.trim();

      // Check if email already exists in Firebase
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (methods.isNotEmpty) {
        setLoading(false);
        setError('An account with this email already exists. Please sign in.');
        return false;
      }

      // Send OTP
      bool sent = await EmailOTPService.sendOTP(email);

      if (sent) {
        _pendingEmail = email;
        _startResendTimer();
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Failed to send verification code. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error sending OTP: $e');
      setError(
          'Failed to send verification code. Please check your internet connection.');
      return false;
    }
  }

  /// Verify OTP code (Step 2 - from verification screen)
  Future<bool> verifyEmailOTP(String otp) async {
    if (_pendingEmail == null) {
      setError('Session expired. Please start over.');
      return false;
    }

    if (otp.length != 6) {
      setError('Please enter the complete 6-digit code');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      bool isValid = EmailOTPService.verifyOTP(_pendingEmail!, otp);

      if (isValid) {
        _isEmailVerified = true;
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        if (EmailOTPService.isOTPExpired()) {
          setError('Code expired. Please request a new one.');
        } else {
          setError('Invalid verification code. Please try again.');
        }
        return false;
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error verifying OTP: $e');
      setError('Verification failed. Please try again.');
      return false;
    }
  }

  /// Resend OTP code
  Future<bool> resendOTP() async {
    if (!canResend) {
      setError('Please wait before resending');
      return false;
    }

    if (_pendingEmail == null) {
      setError('Session expired. Please start over.');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      bool sent = await EmailOTPService.sendOTP(_pendingEmail!);

      if (sent) {
        _startResendTimer();
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Failed to resend code. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error resending OTP: $e');
      setError('Failed to resend code. Please try again.');
      return false;
    }
  }

  /// Create Firebase account with password (Step 3 - from account setup)
  Future<bool> createAccountWithPassword() async {
    if (_pendingEmail == null || !_isEmailVerified) {
      setError('Please verify your email first');
      return false;
    }

    if (passwordController.text.isEmpty) {
      setError('Please enter a password');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      // Create account in Firebase
      UserCredential result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _pendingEmail!,
        password: passwordController.text,
      );

      if (result.user != null) {
        // Mark email as verified in Firebase (since we verified via OTP)
        // Note: This requires admin SDK, so we'll skip for now
        // The user profile will be created in completeProfileSetup

        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Failed to create account. Please try again.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      setLoading(false);
      setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      setLoading(false);
      debugPrint('Error creating account: $e');
      setError('Failed to create account. Please try again.');
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

  // =====================================================
  // EXISTING METHODS (Updated)
  // =====================================================

  // Initialize user from secure storage
  Future<void> initializeUser() async {
    try {
      // Initialize OTP service
      EmailOTPService.configure();

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
        await SecureStorageService.clearAuthData();
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Get user data from Firestore
      _currentUser = await _authService.getUserData(firebaseUser.uid);

      if (_currentUser != null) {
        await SecureStorageService.saveAuthStatus(
          userId: _currentUser!.uid,
          email: _currentUser!.email,
          userData: _currentUser!.toMap(),
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing user: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      setError('Please enter email/username and password');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      String input = emailController.text.trim();
      String emailToUse = input;

      // Check if input is username (no @ symbol) and get email
      if (!input.contains('@')) {
        debugPrint('🔍 Input appears to be username, looking up email...');
        String? email = await _authService.getEmailFromUsername(input);

        if (email == null) {
          setLoading(false);
          setError('Username not found. Please check and try again.');
          return false;
        }

        emailToUse = email;
        debugPrint('✅ Found email for username: $email');
      }

      UserCredential? result = await _authService.signInWithEmailAndPassword(
        email: emailToUse,
        password: passwordController.text,
      );

      if (result != null && result.user != null) {
        _currentUser = await _authService.getUserData(result.user!.uid);

        if (_currentUser != null) {
          await SecureStorageService.saveAuthStatus(
            userId: _currentUser!.uid,
            email: _currentUser!.email,
            userData: _currentUser!.toMap(),
          );
        }

        setLoading(false);
        return true;
      } else {
        setLoading(false);
        setError('Failed to sign in. Please try again.');
        return false;
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error signing in: $e');

      if (e is FirebaseAuthException) {
        setError(_getErrorMessage(e.code));
      } else {
        setError('An error occurred. Please try again.');
      }
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.signInWithGoogle(createProfile: true);

      if (result != null && result.user != null) {
        _currentUser = await _authService.getUserData(result.user!.uid);

        if (_currentUser != null) {
          await SecureStorageService.saveAuthStatus(
            userId: _currentUser!.uid,
            email: _currentUser!.email,
            userData: _currentUser!.toMap(),
          );
        }

        setLoading(false);
        return true;
      } else {
        setLoading(false);
        return false;
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error signing in with Google: $e');
      setError('Failed to sign in with Google. Please try again.');
      return false;
    }
  }

  // Create account with Google
  Future<Map<String, dynamic>> createAccountWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.signInWithGoogle(createProfile: false);

      if (result != null && result.user != null) {
        bool needsSetup =
            await _authService.needsProfileSetup(result.user!.uid);

        if (!needsSetup) {
          _currentUser = await _authService.getUserData(result.user!.uid);

          if (_currentUser != null) {
            await SecureStorageService.saveAuthStatus(
              userId: _currentUser!.uid,
              email: _currentUser!.email,
              userData: _currentUser!.toMap(),
            );
          }
        } else {
          _prefillGoogleData(result.user!);
        }

        setLoading(false);
        return {'success': true, 'needsProfileSetup': needsSetup};
      } else {
        setLoading(false);
        return {'success': false, 'needsProfileSetup': false};
      }
    } catch (e) {
      setLoading(false);
      debugPrint('Error with Google sign up: $e');
      setError('Failed to continue with Google. Please try again.');
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
      String suggestedUsername = user.email?.split('@')[0].toLowerCase() ?? '';
      suggestedUsername =
          suggestedUsername.replaceAll(RegExp(r'[^a-z0-9_]'), '');
      usernameController.text = suggestedUsername;
    }

    notifyListeners();
  }

  // Complete user profile setup
  Future<bool> completeProfileSetup() async {
    User? firebaseUser = _authService.currentUser;

    if (firebaseUser == null) {
      setError('Session expired. Please sign in again.');
      return false;
    }

    if (nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      setError('Please fill in all required fields');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      String? profileImageUrl;

      // Upload profile image if selected
      if (_profileImage != null) {
        try {
          profileImageUrl = await _backblazeService.uploadFile(
            _profileImage!,
          );
        } catch (e) {
          debugPrint('Error uploading profile image: $e');
        }
      }

      // Create user model
      UserModel newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? _pendingEmail ?? '',
        name: nameController.text.trim(),
        username: usernameController.text.trim().toLowerCase(),
        phoneNumber: '',
        profileImageUrl: profileImageUrl ?? firebaseUser.photoURL,
        aboutMe: aboutmeController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _authService.saveUserData(newUser);

      // Update local state
      _currentUser = newUser;

      // Save to secure storage
      await SecureStorageService.saveAuthStatus(
        userId: newUser.uid,
        email: newUser.email,
        userData: newUser.toMap(),
      );

      // Clear pending email and controllers
      _pendingEmail = null;
      _isEmailVerified = false;
      _clearControllers();

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('Error completing profile setup: $e');
      setError('Failed to complete setup. Please try again.');
      return false;
    }
  }

  // Check username availability
  Future<void> checkUsernameAvailability(String username) async {
    if (_lastCheckedUsername == username.toLowerCase()) {
      return;
    }

    _isCheckingUsername = true;
    _isUsernameAvailable = null;
    notifyListeners();

    try {
      _lastCheckedUsername = username.toLowerCase();

      // Check current user's username
      if (_currentUser != null &&
          _currentUser!.username.toLowerCase() == username.toLowerCase()) {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
        notifyListeners();
        return;
      }

      bool available = await _authService.isUsernameAvailable(username);

      _isUsernameAvailable = available;
      _isCheckingUsername = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking username: $e');
      _isCheckingUsername = false;
      _isUsernameAvailable = null;
      notifyListeners();
    }
  }

  // Reset username availability state
  void resetUsernameCheck() {
    _isUsernameAvailable = null;
    _lastCheckedUsername = null;
    _isCheckingUsername = false;
    notifyListeners();
  }

  // Pick profile image
  Future<void> pickProfileImage({bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
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
      setError('Failed to send reset email. Please try again.');
      return false;
    }
  }

  // Update user profile
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
      String? newProfileImageUrl;

      if (newProfileImage != null) {
        newProfileImageUrl = await _backblazeService.uploadFile(
          newProfileImage,
        );
      }

      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'username': username.trim().toLowerCase(),
        'aboutMe': aboutMe.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (newProfileImageUrl != null) {
        updateData['profileImageUrl'] = newProfileImageUrl;
      }

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      // Update local user
      _currentUser = _currentUser!.copyWith(
        name: name.trim(),
        username: username.trim().toLowerCase(),
        aboutMe: aboutMe.trim(),
        profileImageUrl: newProfileImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );

      // Update secure storage
      await SecureStorageService.saveAuthStatus(
        userId: _currentUser!.uid,
        email: _currentUser!.email,
        userData: _currentUser!.toMap(),
      );

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint('Error updating profile: $e');
      setError('Failed to update profile. Please try again.');
      return false;
    }
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

  //  Update user campus
  Future<void> updateCampus(String campus) async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'campus': campus,
      });

      _currentUser = _currentUser!.copyWith(campus: campus);
      notifyListeners();

      debugPrint(' Campus updated: $campus');
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
    if (error is String) {
      switch (error) {
        case 'user-not-found':
          return 'No account found with this email/username.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'invalid-credential':
          return 'Invalid email/username or password.';
        default:
          return 'Authentication failed. Please try again.';
      }
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
    resetUsernameCheck();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    aboutmeController.dispose();
    super.dispose();
  }
}
