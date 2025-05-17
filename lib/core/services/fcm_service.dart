// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Background message handler
@pragma('vm:entry-point') // Required for background handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handling if needed
  // await Firebase.initializeApp(); // Uncomment if needed in your setup

  log('Handling background message: ${message.messageId}');

  // Must create the notification channel in the background handler too
  const androidChannel = AndroidNotificationChannel(
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

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // Set up the initialization settings
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Check if this is a notification message (with notification payload)
  // If it is, we don't need to show it manually as FCM will show it
  // If it's a data message, we need to show it manually
  if (message.notification == null || message.data.containsKey('forceCustomNotification')) {
    // Only show our custom notification if there's no notification payload
    // or if we specifically want to force our custom notification
    await _showLocalNotification(message, flutterLocalNotificationsPlugin);
  }

  // Store route in shared preferences for later retrieval when app opens
  final prefs = await SharedPreferences.getInstance();
  if (message.data['route'] != null) {
    await prefs.setString('pending_notification_route', message.data['route']);
  }
}

Future<void> _showLocalNotification(
  RemoteMessage message,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) async {
  final notification = message.notification;
  String? title;
  String? body;

  // Get notification content either from notification payload or from data
  if (notification != null) {
    title = notification.title;
    body = notification.body;
  } else {
    // For data-only messages, check if data contains title and body
    title = message.data['title'];
    body = message.data['body'];
  }

  // Only show notification if we have at least a title or body
  if (title != null || body != null) {
    await flutterLocalNotificationsPlugin.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'main', // Channel ID
          'app_notifications', // Channel name
          channelDescription: 'Main notification channel',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true, // Show notification prominently
          ticker: title, // Improve visibility
        ),
      ),
      payload: message.data['route'] ?? '/',
    );
    log('Local notification shown for message: ${message.messageId}');
  } else {
    log('No notification shown - missing title and body for message: ${message.messageId}');
  }
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String _deepLinkBase = 'https://app.atlasapp.app';

  // Store context for later use with notifications

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

  Future<void> initLocalFlutterNotifications(BuildContext context) async {
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          log('Notification tapped with payload: ${response.payload}');
          if (response.payload != null) {
            // Handle the notification tap directly if context is available
            try {
              await _handleNavigation(response.payload!, context);
            } catch (e) {
              log('Error handling notification tap: $e');
              // Store for later handling if context is not ready
              await _storePendingRoute(response.payload!);
            }
          }
        },
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      // Check for any notification actions that happened while the app was terminated
      final notificationAppLaunchDetails =
          await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (notificationAppLaunchDetails != null &&
          notificationAppLaunchDetails.didNotificationLaunchApp &&
          notificationAppLaunchDetails.notificationResponse?.payload != null) {
        log(
          'App launched from notification with payload: ${notificationAppLaunchDetails.notificationResponse?.payload}',
        );
        await _storePendingRoute(notificationAppLaunchDetails.notificationResponse!.payload!);
      }
    } catch (e) {
      log('Error initializing local notifications: $e');
      rethrow;
    }
  }

  WidgetRef? _ref;
  Future<void> initialize(BuildContext context, {required WidgetRef ref}) async {
    try {
      _ref = ref;
      // Initialize Firebase for better background message handling
      // await Firebase.initializeApp(); // Uncomment if needed in your setup

      // Register background handler before other setup
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

      // Initialize local notifications first
      await initLocalFlutterNotifications(context);

      // IMPORTANT: Disable direct notification presentation from FCM on Android
      // This prevents duplicate notifications since we'll handle them with flutter_local_notifications
      await _configureAndroidFcmNotificationSettings();

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

  // Configure Android FCM settings to prevent automatic notification display
  Future<void> _configureAndroidFcmNotificationSettings() async {
    try {
      // This is a platform-specific implementation to disable automatic notification display
      // It uses a method channel to communicate with native Android code
      const platform = MethodChannel('app.atlasapp/fcm_config');
      await platform.invokeMethod('disableAutomaticNotificationHandling');
      log('Disabled automatic FCM notification handling on Android');
    } catch (e) {
      log('Error configuring Android FCM settings: $e');
      // Continue even if this fails, as it might not be implemented yet
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
      log('Handling foreground message: ${message.messageId}');

      // In foreground, we manually show the notification to have control over it
      // If FCM would show it, we can decide based on message type
      // - If it has a notification payload, FCM might show it automatically
      // - If it's a data-only message, we need to show it ourselves

      // Regardless of message type, we always show our custom notification in foreground
      // for consistent handling and to ensure deep linking works properly
      await _showLocalNotification(message, _flutterLocalNotificationsPlugin);
    } catch (e) {
      log('Error handling foreground message: $e');
    }
  }

  Future<void> _handleNavigationFromMessage(RemoteMessage message, BuildContext context) async {
    log('Handling navigation from message: ${message.messageId}');
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
        // context.push(route);
        if (_ref != null) {
          _ref!.read(routerProvider).push(route);
        }
        log('Cannot launch deep link: $deepLink');
        // CustomToast.error('Cannot launch deep link: $deepLink');
      }
    } catch (deepLinkError) {
      log('Deep link error: $deepLinkError');
      context.push(route);
    }
  }

  Future<void> _storePendingRoute(String route) async {
    log('Storing pending route: $route');
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
