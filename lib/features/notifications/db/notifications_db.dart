import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/notifications/interfaces/notifications_interface.dart';
import 'package:atlas_app/features/notifications/models/notification_container_model.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NotificationsDb {
  // SupabaseClient get _client => Supabase.instance.client;
  static Dio get _dio => Dio();
  ProfileDb get _profileDb => ProfileDb();

  Future<void> sendNotificatiosn(NotificationContainerModel notification) async {
    try {
      final headers = await generateAuthHeaders();
      await _dio.post(
        "${appAPI}send-notification",
        options: Options(headers: headers),
        data: jsonEncode(notification.toMap()),
      );
    } catch (e) {
      log(e.toString());
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<void> sendMentionNotifications(List<String> mentions, String type, UserModel me) async {
    try {
      NotificationContainerModel notification;

      switch (type.trim()) {
        case 'pc':
          notification = NotificationsInterface.userMentionedInComment(
            userId: '',
            username: me.username,
          );
          break;

        case 'cc':
          notification = NotificationsInterface.userMentionedInChapterComment(
            userId: '',
            username: me.username,
          );
          break;
        default:
          notification = NotificationsInterface.userMentionedInPost(
            userId: '',
            username: me.username,
          );
      }
      final data = await Future.wait<dynamic>([
        generateAuthHeaders(),
        _profileDb.getUserIdBasedOnUsername(mentions),
      ]);
      final [headers, users] = data;
      final body = jsonEncode({
        'title': notification.title,
        'body': notification.body,
        'ids': users,
      });
      await _dio.post(
        "${appAPI}send-notification-batch",
        options: Options(headers: headers),
        data: body,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
