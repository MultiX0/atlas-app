import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/imports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);
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

  // Method to manually get current token if needed
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
