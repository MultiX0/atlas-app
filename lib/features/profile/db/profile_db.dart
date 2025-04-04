import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
// import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/profile/models/follows_model.dart';
import 'package:atlas_app/imports.dart';

class ProfileDb {
  final client = Supabase.instance.client;
  // SupabaseQueryBuilder get _usersTable => client.from(TableNames.users);

  Future<FollowsCountModel> getFollowsCountString(String userId) async {
    try {
      final data = await client.rpc(FunctionNames.get_follow_counts, params: {"user_uuid": userId});
      log(data.toString());
      return FollowsCountModel.fromMap(data[0]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
