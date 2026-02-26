import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('Background message: ${message.messageId}');
  } catch (error) {
    debugPrint('Background handler init failed: $error');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'newsappjs_high_importance_channel',
        'News Alerts',
        description: 'News and breaking alerts',
        importance: Importance.max,
      );

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
        'newsappjs_high_importance_channel',
        'News Alerts',
        channelDescription: 'News and breaking alerts',
        importance: Importance.max,
        priority: Priority.high,
      );

  static const NotificationDetails _foregroundNotificationDetails =
      NotificationDetails(android: _androidNotificationDetails);

  static bool _initialized = false;
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
  static StreamSubscription<String>? _onTokenRefreshSubscription;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    final supportedPlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (!supportedPlatform) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      await _initializeLocalNotifications();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _messaging.subscribeToTopic('all');
      final token = await _messaging.getToken();
      debugPrint('FCM token: $token');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _onMessageSubscription?.cancel();
      _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) async {
        debugPrint('Foreground message: ${message.messageId}');
        await _showForegroundNotification(message);
      });

      _onMessageOpenedSubscription?.cancel();
      _onMessageOpenedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Opened from notification: ${message.messageId}');
      });

      _onTokenRefreshSubscription?.cancel();
      _onTokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM token refreshed: $newToken');
      });

      _initialized = true;
    } catch (error) {
      debugPrint('Push initialization skipped: $error');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initializationSettings);

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final notification = message.notification;
    final title = notification?.title;
    final body = notification?.body;

    if (title == null && body == null) return;

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      _foregroundNotificationDetails,
    );
  }
}
