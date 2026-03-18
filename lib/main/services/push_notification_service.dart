import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 [BG] Push received: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'campcon_push_channel',
    'Campcon Notifications',
    description: 'General notifications for Campcon',
    importance: Importance.max,
  );

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<User?>? _authSub;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Add timeouts to all async operations
    try {
      await _requestPermission().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('⚠️ Permission request error or timeout: $e');
    }

    try {
      await _initLocalNotifications().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('⚠️ Local notifications init error or timeout: $e');
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) async {
      final canShow = await _canShowForCategory(message);
      if (!canShow) return;
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🔔 Opened from push (background): ${message.data}');
    });

    // Get initial message with timeout
    try {
      final initial = await _messaging.getInitialMessage().timeout(
            const Duration(seconds: 3),
          );
      if (initial != null) {
        debugPrint('🔔 Opened from push (terminated): ${initial.data}');
      }
    } catch (e) {
      debugPrint('⚠️ Initial message error or timeout: $e');
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Non-blocking token sync
        syncTokenForUser(user.uid)
            .timeout(
          const Duration(seconds: 5),
        )
            .catchError((e) {
          debugPrint('⚠️ Token sync error or timeout: $e');
        });
      }
    });

    _tokenSub = _messaging.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _saveToken(uid, token)
          .timeout(
        const Duration(seconds: 5),
      )
          .catchError((e) {
        debugPrint('⚠️ Save token error or timeout: $e');
      });
    });

    // Initial token sync (non-blocking)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      syncTokenForUser(uid)
          .timeout(
        const Duration(seconds: 5),
      )
          .catchError((e) {
        debugPrint('⚠️ Initial token sync error or timeout: $e');
      });
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 Permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('🔔 Local notification tapped: ${response.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> syncTokenForUser(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _saveToken(userId, token);
    } catch (e) {
      debugPrint('❌ Failed syncing token: $e');
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      'notificationPreferences': {
        'messages': true,
        'social': true,
        'orders': true,
        'events': true,
        'tasks': true,
      },
    }, SetOptions(merge: true));
  }

  Future<bool> _canShowForCategory(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return true;

    final category = (message.data['category'] ?? 'messages').toString();
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final prefs = Map<String, dynamic>.from(
        data['notificationPreferences'] ?? {},
      );
      if (!prefs.containsKey(category)) return true;
      return prefs[category] == true;
    } catch (_) {
      return true;
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Campcon';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';

    final android = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(android: android, iOS: ios),
      payload: message.data.toString(),
    );
  }

  Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _authSub?.cancel();
  }
}
