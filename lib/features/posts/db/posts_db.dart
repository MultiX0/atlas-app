import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/posts/models/post_model.dart';
import 'package:atlas_app/imports.dart';

class PostsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postsView => _client.from(ViewNames.post_details_with_mentions);

  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final _data = await _postsView.select("*").eq(KeyNames.userId, userId);
      log(_data.toString());

      return _data.map((post) => PostModel.fromMap(post)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> slashMentionSearch(String query) async {
    try {
      final data = await _client.rpc(FunctionNames.search_all, params: {'keyword': query}) as List;
      // log(data.toString());
      return List.from(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
