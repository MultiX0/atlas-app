// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
  await _showNotification(message);
}

Future<void> _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    const androidChannel = AndroidNotificationChannel(
      'main',
      'app_notifications',
      enableVibration: true,
      importance: Importance.max,
      audioAttributesUsage: AudioAttributesUsage.notification,
      showBadge: true,
      playSound: true,
      ledColor: Color(0xFF0000FF), // Blue LED for visibility
      enableLights: true,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true, // Show notification prominently
          ticker: notification.title, // Improve visibility
        ),
      ),
      payload: message.data['route'] ?? '/',
    );
  }
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _deepLinkBase = 'https://app.atlasapp.app';

  // Notification channel configuration
  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'main',
    'app_notifications',
    enableVibration: true,
    importance: Importance.max,
    audioAttributesUsage: AudioAttributesUsage.notification,
    showBadge: true,
    playSound: true,
    ledColor: Color(0xFF0000FF),
    enableLights: true,
  );

  Future<void> initLocalFlutterNotifications() async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null) {
            await _storePendingRoute(response.payload!);
          }
        },
      );

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
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
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
        _handleForegroundMessage(message);
      });

      // Handle background/terminated messages when app is opened
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

      // Check for any stored route from background notification click
      await _checkPendingRoute(context);
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

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      await _showNotification(message);
    } catch (e) {
      log('Error handling foreground message: $e');
    }
  }

  Future<void> _handleNavigationFromMessage(RemoteMessage message, BuildContext context) async {
    final route = message.data['route'];
    if (route != null && route is String) {
      await _handleNavigation(route, context);
    }
  }

  Future<void> _handleNavigation(String route, BuildContext context) async {
    try {
      final deepLink = '$_deepLinkBase$route';
      log('Attempting deep link: $deepLink');
      if (await canLaunchUrlString(deepLink)) {
        await launchUrlString(deepLink, mode: LaunchMode.externalApplication);
      } else {
        log('Cannot launch deep link: $deepLink');
        CustomToast.error('Cannot launch deep link: $deepLink');
        context.go('/');
      }
    } catch (deepLinkError) {
      log('Deep link error: $deepLinkError');
      context.go('/');
    }
  }

  Future<void> _storePendingRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_notification_route', route);
  }

  Future<void> _checkPendingRoute(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRoute = prefs.getString('pending_notification_route');
    if (pendingRoute != null) {
      log('Found pending route: $pendingRoute');
      await _handleNavigation(pendingRoute, context);
      await prefs.remove('pending_notification_route');
    }
  }

  // Method to manually get current token if needed
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
