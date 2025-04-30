// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/imports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
  // You can add custom handling for background messages here
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channel configuration
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'main',
    'app_notifications',
    enableVibration: true,
    importance: Importance.max,
    audioAttributesUsage: AudioAttributesUsage.notification,
    showBadge: true,
    playSound: true,
  );

  Future<void> initLocalFlutterNotifications(BuildContext context) async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      // Initialize local notifications with callback for handling clicks
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null) {
            _handleNavigation(response.payload!, context);
          }
        },
      );

      // Create notification channel
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    } catch (e) {
      log('Error initializing local notifications: $e');
      rethrow;
    }
  }

  Future<void> initialize(BuildContext context) async {
    try {
      // Request permission
      await _firebaseMessaging.requestPermission();
      await _firebaseMessaging.setAutoInitEnabled(true);

      // Get and save initial token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

      // Set foreground notification options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message, context);
      });

      // Handle background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNavigationFromMessage(message, context);
      });

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Check if app was opened from a terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNavigationFromMessage(initialMessage, context);
      }
    } catch (e) {
      log('Error initializing FCM: $e');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    log('FCM Token refreshed: $token');
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.rpc(
          FunctionNames.upsert_user_fcm_token,
          params: {'p_user_id': userId, 'p_token': token},
        );
        log('FCM token updated in database');
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message, BuildContext context) async {
    try {
      final notification = message.notification;
      if (notification != null) {
        // Show notification using flutter_local_notifications
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          payload: message.data['route'] ?? '/',
        );
      }
    } catch (e) {
      log('Error handling foreground message: $e');
    }
  }

  void _handleNavigationFromMessage(RemoteMessage message, BuildContext context) {
    final route = message.data['route'];
    if (route != null && route is String) {
      _handleNavigation(route, context);
    }
  }

  void _handleNavigation(String route, BuildContext context) {
    try {
      // Navigate using go_router
      context.go(route);
    } catch (e) {
      log('Navigation error: $e');
      // Fallback navigation to home
      context.go('/');
    }
  }

  // Method to manually get current token if needed
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
