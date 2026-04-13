import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/market_folder/market_cart.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/my_tickets_screen.dart';
import 'package:campcon/main/screens/onboarding/onboarding.dart';
import 'package:campcon/main/screens/profile/account_information_screen.dart';
import 'package:campcon/main/screens/profile/my_sales/payment_screen.dart';
import 'package:campcon/main/screens/profile/my_sales/sales_screen.dart';
import 'package:campcon/main/screens/profile/logistics/pickup_screen.dart';
import 'package:campcon/main/screens/profile/notification_preferences_screen.dart';
import 'package:campcon/main/screens/profile/password_security_screen.dart';
import 'package:campcon/main/screens/profile/professional_account_screen.dart';
import 'package:campcon/main/widgets/floating_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  bottom: BorderSide(color: AppTheme.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Iconify(
                      Ph.arrow_left,
                      color: AppTheme.textPrimary,
                      size: 24.sp,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Manage Account',
                        style: TextConstants.mediumText.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance for back button
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  SizedBox(height: 8.h),

                  // Account Section
                  _buildSectionHeader('Account'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.user,
                    iconColor: AppTheme.primary,
                    iconBgColor: AppTheme.primary.withValues(alpha: 0.1),
                    title: 'Account Information',
                    subtitle: 'View and edit your profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const AccountInformationScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.lock,
                    iconColor: AppTheme.primary,
                    iconBgColor: AppTheme.primary.withValues(alpha: 0.1),
                    title: 'Password & Security',
                    subtitle: 'Manage your password',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const PasswordSecurityScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.bell,
                    iconColor: AppTheme.primary,
                    iconBgColor: AppTheme.primary.withValues(alpha: 0.1),
                    title: 'Notification Preferences',
                    subtitle: 'Choose which push alerts you receive',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const NotificationPreferencesScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Marketplace Section
                  _buildSectionHeader('Marketplace'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.storefront,
                    iconColor: AppTheme.success,
                    iconBgColor: AppTheme.success.withValues(alpha: 0.1),
                    title: 'My Sales',
                    subtitle: 'Track orders and manage sales',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const SalesScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.shopping_bag,
                    iconColor: Colors.orange,
                    iconBgColor: Colors.orange.withValues(alpha: 0.1),
                    title: 'My Orders',
                    subtitle: 'View your purchase history',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const MarketCartScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.bank,
                    iconColor: Colors.teal,
                    iconBgColor: Colors.teal.withValues(alpha: 0.1),
                    title: 'Payments',
                    subtitle: 'Manage payouts and earnings',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const PaymentScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Events Section
                  _buildSectionHeader('Events'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.ticket,
                    iconColor: AppTheme.primary,
                    iconBgColor: AppTheme.primary.withValues(alpha: 0.1),
                    title: 'My Tickets',
                    subtitle: 'View your event tickets',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const MyTicketsScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Logistics Section
                  _buildSectionHeader('Logistics'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.map_pin,
                    iconColor: Colors.purple,
                    iconBgColor: Colors.purple.withValues(alpha: 0.1),
                    title: 'Pickup Center',
                    subtitle: 'Apply to become a pickup location',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const PickupScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Professional Account Section
                  _buildSectionHeader('Professional'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.check_circle,
                    iconColor: AppTheme.white,
                    iconBgColor: AppTheme.primary,
                    title: 'Professional Account',
                    subtitle: 'Unlock business features',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const ProfessionalAccountScreen(),
                          duration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Danger Zone Section
                  _buildSectionHeader('Danger Zone'),
                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.sign_out,
                    iconColor: AppTheme.white,
                    iconBgColor: AppTheme.error,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    titleColor: AppTheme.error,
                    onTap: () => _showLogoutDialog(context),
                    showArrow: false,
                  ),

                  SizedBox(height: 8.h),

                  _buildSettingsItem(
                    context: context,
                    icon: Ph.trash,
                    iconColor: AppTheme.white,
                    iconBgColor: AppTheme.error,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account',
                    titleColor: AppTheme.error,
                    onTap: () => _showDeleteAccountDialog(context),
                    showArrow: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: Text(
        title,
        style: TextConstants.smallText.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required String icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Iconify(
                  icon,
                  color: iconColor,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Iconify(
                Ph.caret_right,
                color: AppTheme.textLight,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Iconify(
                          Ph.x,
                          size: 24.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Error icon
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Iconify(
                      Ph.sign_out,
                      color: AppTheme.error,
                      size: 32.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Log out?',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 20.sp,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  'Are you sure you want to log out?\nYou can always log back in.',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.border, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Consumer<AuthProvider>(
                        builder: (consumerContext, authProvider, child) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    // Close the dialog first
                                    Navigator.of(dialogContext).pop();

                                    // Perform logout - this will sign out from Firebase and clear user data
                                    await authProvider.signOut();

                                    // Use pushAndRemoveUntil to clear entire navigation stack
                                    rootNavigator.pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const Onboarding(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Log Out',
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Iconify(
                          Ph.x,
                          size: 24.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Warning icon
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Iconify(
                      Ph.trash,
                      color: AppTheme.error,
                      size: 32.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Delete your account?',
                  style: TextConstants.boldText.copyWith(
                    fontSize: 20.sp,
                    color: AppTheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Warning message
                Text(
                  'Your account will be deleted permanently.\nThis action cannot be reversed.',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.border, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showDeleteAccountPasswordDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: TextConstants.mediumText.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            child: Iconify(
                              Ph.x,
                              size: 24.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Lock icon
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Iconify(
                          Ph.lock,
                          color: AppTheme.primary,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Title
                    Text(
                      'Enter your password',
                      style: TextConstants.boldText.copyWith(
                        fontSize: 18.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      'Confirm your identity to delete account',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: TextConstants.mediumText.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextConstants.smallText.copyWith(
                            color: AppTheme.textLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          suffixIcon: IconButton(
                            icon: Iconify(
                              obscurePassword ? Ph.eye : Ph.eye_slash,
                              color: AppTheme.textLight,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : () async {
                                    if (passwordController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Please enter password'),
                                          backgroundColor: AppTheme.error,
                                        ),
                                      );
                                      return;
                                    }

                                    authProvider.setLoading(true);
                                    try {
                                      final firebaseUser =
                                          FirebaseAuth.instance.currentUser;
                                      if (firebaseUser == null ||
                                          firebaseUser.email == null) {
                                        throw Exception(
                                            'No authenticated user');
                                      }

                                      // 1. Re-authenticate
                                      final credential =
                                          EmailAuthProvider.credential(
                                        email: firebaseUser.email!,
                                        password:
                                            passwordController.text.trim(),
                                      );
                                      await firebaseUser
                                          .reauthenticateWithCredential(
                                              credential);

                                      final uid = firebaseUser.uid;
                                      final firestore =
                                          FirebaseFirestore.instance;

                                      // 2. Delete user Firestore data (batch)
                                      final batch = firestore.batch();

                                      // Delete user document
                                      batch.delete(firestore
                                          .collection('users')
                                          .doc(uid));

                                      // Delete posts
                                      final posts = await firestore
                                          .collection('posts')
                                          .where('userId', isEqualTo: uid)
                                          .get();
                                      for (final doc in posts.docs) {
                                        batch.delete(doc.reference);
                                      }

                                      // Delete marketplace listings
                                      final products = await firestore
                                          .collection('marketplace')
                                          .where('userId', isEqualTo: uid)
                                          .get();
                                      for (final doc in products.docs) {
                                        batch.delete(doc.reference);
                                      }

                                      // Delete events
                                      final events = await firestore
                                          .collection('events')
                                          .where('organizerId', isEqualTo: uid)
                                          .get();
                                      for (final doc in events.docs) {
                                        batch.delete(doc.reference);
                                      }

                                      await batch.commit();

                                      // 3. Delete Firebase Auth account
                                      await firebaseUser.delete();

                                      // 4. Sign out locally
                                      await authProvider.signOut();

                                      if (context.mounted) {
                                        Navigator.pop(dialogContext);
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Onboarding(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      authProvider.setLoading(false);
                                      String msg;
                                      switch (e.code) {
                                        case 'wrong-password':
                                          msg =
                                              'Incorrect password. Please try again.';
                                          break;
                                        case 'requires-recent-login':
                                          msg =
                                              'Please log out and log back in before deleting.';
                                          break;
                                        default:
                                          msg = e.message ??
                                              'Authentication failed.';
                                      }
                                      if (context.mounted) {
                                        showFloatingSnackBar(context, msg,
                                            backgroundColor: AppTheme.error);
                                      }
                                    } catch (e) {
                                      authProvider.setLoading(false);
                                      debugPrint('Delete account error: $e');
                                      if (context.mounted) {
                                        showFloatingSnackBar(
                                            context, 'Failed to delete account',
                                            backgroundColor: AppTheme.error);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Delete Account',
                                    style: TextConstants.mediumText.copyWith(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
