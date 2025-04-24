import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/profile/models/follows_model.dart';
import 'package:atlas_app/imports.dart';

class ProfileDb {
  final client = Supabase.instance.client;
  SupabaseQueryBuilder get _usersTable => client.from(TableNames.users);

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

  Future<List<Map<String, dynamic>>> fetchUsersForMention(String query) async {
    final response = await _usersTable
        .select('${KeyNames.id}, ${KeyNames.username}, ${KeyNames.fullName}, ${KeyNames.avatar}')
        .ilike('username', '%$query%')
        .order('username')
        .limit(8);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _usersTable.update(user.toMap()).eq(KeyNames.id, user.userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
