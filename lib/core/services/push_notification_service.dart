import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('Background message: ${message.messageId}');
  } catch (error) {
    debugPrint('Background handler init failed: $error');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    try {
      await Firebase.initializeApp();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');

      await _messaging.subscribeToTopic('all');
      final token = await _messaging.getToken();
      debugPrint('FCM token: $token');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Foreground message: ${message.messageId}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Opened from notification: ${message.messageId}');
      });

      _initialized = true;
    } catch (error) {
      debugPrint('Push initialization skipped: $error');
    }
  }
}
