import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/imports.dart';

final libraryDbProvider = Provider<LibraryDb>((ref) {
  return LibraryDb();
});

class LibraryDb {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<MyWorkModel>> getMyWork({
    required String userId,
    required int startAt,
    required int pageSize,
  }) async {
    try {
      final data = await _client.rpc(
        FunctionNames.get_user_works,
        params: {'p_user_id': userId, 'p_limit': pageSize, 'p_offset': startAt},
      );
      final dataList = List.from(data);
      return dataList.map((d) => MyWorkModel.fromMap(d)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
