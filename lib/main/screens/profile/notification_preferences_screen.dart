import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _loading = true;
  bool _saving = false;

  final Map<String, bool> _prefs = {
    'messages': true,
    'social': true,
    'orders': true,
    'events': true,
    'tasks': true,
  };

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      final data = doc.data() ?? {};
      final map = Map<String, dynamic>.from(
        data['notificationPreferences'] ?? {},
      );
      _prefs.updateAll((key, value) => map[key] == null ? value : map[key]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePref(String key, bool value) async {
    setState(() {
      _prefs[key] = value;
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'notificationPreferences': _prefs,
      }, SetOptions(merge: true));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Notification Preferences',
          style: TextConstants.mediumText.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                if (_saving)
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    children: [
                      _buildItem(
                        icon: Ph.chats_circle,
                        title: 'Messages',
                        subtitle: 'Direct and random chat messages',
                        keyName: 'messages',
                      ),
                      _buildItem(
                        icon: Ph.heart,
                        title: 'Social',
                        subtitle: 'Likes, comments, follows and mentions',
                        keyName: 'social',
                      ),
                      _buildItem(
                        icon: Ph.shopping_bag,
                        title: 'Orders',
                        subtitle: 'Order updates and marketplace activity',
                        keyName: 'orders',
                      ),
                      _buildItem(
                        icon: Ph.ticket,
                        title: 'Events',
                        subtitle: 'Event reminders and event updates',
                        keyName: 'events',
                      ),
                      _buildItem(
                        icon: Ph.check_circle,
                        title: 'Tasks',
                        subtitle: 'Task due-date reminders',
                        keyName: 'tasks',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildItem({
    required String icon,
    required String title,
    required String subtitle,
    required String keyName,
  }) {
    final enabled = _prefs[keyName] ?? true;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Iconify(icon, color: AppTheme.primary, size: 18.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextConstants.mediumText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextConstants.smallText.copyWith(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppTheme.primary,
            onChanged: (value) => _updatePref(keyName, value),
          ),
        ],
      ),
    );
  }
}
