import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email (auto-generates password)
  Future<UserCredential?> signUpWithEmail(String email) async {
    try {
      // Generate a secure random password (user won't need to remember this)
      String tempPassword = DateTime.now().millisecondsSinceEpoch.toString() +
          email.hashCode.toString();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      // Send verification email immediately
      await result.user?.sendEmailVerification();

      return result;
    } catch (e) {
      print('Error creating account: $e');
      rethrow;
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Error resending verification email: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({bool createProfile = true}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      if (createProfile && result.user != null) {
        bool exists = await _checkUserExists(result.user!.uid);
        if (!exists) {
          await _createDefaultProfile(result.user!);
        }
      }

      return result;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Check if user profile exists
  Future<bool> _checkUserExists(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Create default profile for Google sign-in
  Future<void> _createDefaultProfile(User user) async {
    try {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        username: user.email?.split('@')[0].toLowerCase() ?? '',
        phoneNumber: user.phoneNumber ?? '',
        profileImageUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveUserData(newUser);
    } catch (e) {
      print('Error creating default profile: $e');
      rethrow;
    }
  }

  // Check if user needs profile setup
  Future<bool> needsProfileSetup(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return true;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['username'] == null ||
          data['username'].toString().isEmpty ||
          data['name'] == null ||
          data['name'].toString().isEmpty;
    } catch (e) {
      print('Error checking profile setup: $e');
      return true;
    }
  }

  // Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      return result.docs.isEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Get email from username
  Future<String?> getEmailFromUsername(String username) async {
    try {
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final userData = result.docs.first.data() as Map<String, dynamic>;
        return userData['email'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting email from username: $e');
      return null;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File image, String uid) async {
    try {
      Reference ref = _storage.ref().child('profile_images').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Update user type (student or not) with student details
  Future<void> updateUserType(
    String uid,
    bool isStudent, {
    Map<String, String>? studentDetails,
    List<String>? interests, // Add this
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'isStudent': isStudent,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add student details if provided
      if (isStudent && studentDetails != null) {
        updateData['school'] = studentDetails['school'];
        updateData['level'] = studentDetails['level'];
        updateData['department'] = studentDetails['department'];
      }

      // Add interests if provided
      if (interests != null && interests.isNotEmpty) {
        updateData['interests'] = interests;
      }

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      print('Error updating user type: $e');
      rethrow;
    }
  }

  // Re-authenticate user before sensitive operations
  Future<bool> reauthenticateUser(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('Error re-authenticating user: $e');
      return false;
    }
  }

  // Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user from Firebase Auth
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }
}
