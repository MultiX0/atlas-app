import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/reports/models/post_report_model.dart';
import 'package:atlas_app/imports.dart';

final reportsDbProvider = Provider<ReportsDb>((ref) {
  return ReportsDb();
});

class ReportsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postReportsTable => _client.from(TableNames.post_reports);
  SupabaseQueryBuilder get _novelChaptersCommentReport =>
      _client.from(TableNames.novel_chapters_comment_report);
  SupabaseQueryBuilder get _novelChapterReports => _client.from(TableNames.novel_chapter_reports);
  SupabaseQueryBuilder get _novelReportsTable => _client.from(TableNames.novel_reports);
  SupabaseQueryBuilder get _usersReportsTable => _client.from(TableNames.user_reports);

  Future<void> newReport(PostReportModel report) async {
    try {
      await _postReportsTable.insert(report.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addChapterCommentReport({
    required String report,
    required String reporter_id,
    required String reported_id,
  }) async {
    try {
      await _novelChaptersCommentReport.insert({
        KeyNames.reporter_id: reporter_id,
        KeyNames.reported_id: reported_id,
        KeyNames.content: report,
      });
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
      await _novelChapterReports.insert({
        KeyNames.reporter_id: reporter_id,
        KeyNames.chapter_id: chapter_id,
        KeyNames.content: report,
      });
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
      await _novelReportsTable.insert({
        KeyNames.reporter_id: reporter_id,
        KeyNames.novel_id: novelId,
        KeyNames.content: report,
      });
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
      await _usersReportsTable.insert({
        KeyNames.reporter_id: reporter_id,
        KeyNames.reported_user_id: reported_id,
        KeyNames.reason: reason,
        KeyNames.details: details,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
