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

  Future<void> newReport(PostReportModel report) async {
    try {
      await _postReportsTable.insert(report.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
