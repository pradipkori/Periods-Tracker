import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'dart:convert';

class PushNotificationService {
  final DatabaseService _db;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  PushNotificationService(this._db);

  Future<void> init() async {
    // Request permission (especially for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }

    // Get the FCM token
    String? token = await _fcm.getToken();
    print("FCM Token: $token");

    // Handle initial message (when app is opened from a terminated state)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked! (App was in background)");
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    // Add logic to navigate to a specific screen if needed
    print("Handling message: ${message.data}");
    _saveToHistory(message);
  }

  Future<void> _saveToHistory(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final stored = StoredNotification(
      title: notification.title ?? "New Notification",
      body: notification.body ?? "",
      timestamp: DateTime.now(),
      type: 'remote',
      dataJson: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
    await _db.saveNotification(stored);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      _saveToHistory(message); // Save foreground messages to history too
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'push_notifications',
            'Push Notifications',
            channelDescription: 'Remote push notifications from Firebase',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}

// Background message handler (Must be a top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
