import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/notifications/models/notification_container_model.dart';
import 'package:atlas_app/features/reports/models/post_report_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final reportsDbProvider = Provider<ReportsDb>((ref) {
  return ReportsDb();
});

class ReportsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postReportsTable => _client.from(TableNames.post_reports);
  SupabaseQueryBuilder get _postCommentsReportsTable =>
      _client.from(TableNames.post_comment_reports);

  SupabaseQueryBuilder get _novelChaptersCommentReport =>
      _client.from(TableNames.novel_chapters_comment_report);
  SupabaseQueryBuilder get _novelChapterReports => _client.from(TableNames.novel_chapter_reports);
  SupabaseQueryBuilder get _novelReportsTable => _client.from(TableNames.novel_reports);
  SupabaseQueryBuilder get _usersReportsTable => _client.from(TableNames.user_reports);

  static Dio get _dio => Dio();

  NotificationContainerModel get notification => NotificationContainerModel(
    body: "هنالك بلاغ جديد الرجاء التحقق منه في أقرب وقت ممكن!",
    title: "بلاغ جديد",
    userId: '',
  );

  Future<void> sendNotificatiosn() async {
    try {
      final headers = await generateAuthHeaders();
      await _dio.post(
        "${appAPI}report",
        options: Options(headers: headers),
        data: jsonEncode({"title": notification.title, "body": notification.body}),
      );
    } catch (e) {
      log(e.toString());
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<void> newReport(PostReportModel report) async {
    try {
      await Future.wait([_postReportsTable.insert(report.toMap()), sendNotificatiosn()]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addChapterCommentReport({
    required String report,
    required String reporter_id,
    required bool isReply,
    required String contentId,
  }) async {
    try {
      await Future.wait([
        _novelChaptersCommentReport.insert({
          KeyNames.reporter_id: reporter_id,
          KeyNames.content: report,
          KeyNames.is_reply: isReply,
          KeyNames.content_id: contentId,
        }),
        sendNotificatiosn(),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addPostCommentReport({
    required String report,
    required String reporter_id,
    required bool isReply,
    required String contentId,
  }) async {
    try {
      await Future.wait([
        _postCommentsReportsTable.insert({
          KeyNames.reporter_id: reporter_id,
          KeyNames.content: report,
          KeyNames.is_reply: isReply,
          KeyNames.content_id: contentId,
        }),
        sendNotificatiosn(),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addChapterReport({
    required String report,
    required String reporter_id,
    required String chapter_id,
  }) async {
    try {
      await Future.wait([
        _novelChapterReports.insert({
          KeyNames.reporter_id: reporter_id,
          KeyNames.chapter_id: chapter_id,
          KeyNames.content: report,
        }),
        sendNotificatiosn(),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addNovelReport({
    required String report,
    required String reporter_id,
    required String novelId,
  }) async {
    try {
      await Future.wait([
        _novelReportsTable.insert({
          KeyNames.reporter_id: reporter_id,
          KeyNames.novel_id: novelId,
          KeyNames.content: report,
        }),
        sendNotificatiosn(),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addUserReport({
    required String reported_id,
    required String reporter_id,
    required String reason,
    required String details,
  }) async {
    try {
      await Future.wait([
        _usersReportsTable.insert({
          KeyNames.reporter_id: reporter_id,
          KeyNames.reported_user_id: reported_id,
          KeyNames.reason: reason,
          KeyNames.details: details,
        }),
        sendNotificatiosn(),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
