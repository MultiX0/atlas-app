import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/imports.dart';

class HashtagsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _hashTagsTable => _client.from(TableNames.hashtags);
  SupabaseQueryBuilder get _postsHashtags => _client.from(TableNames.post_hashtags);

  Future<void> insertNewHashTag(List<String> hashtags) async {
    try {
      final now = DateTime.now().toIso8601String();
      final _data =
          hashtags
              .map(
                (hashtag) => {
                  KeyNames.hashtag: hashtag,
                  KeyNames.created_at: now,
                  KeyNames.lpc_at: now,
                },
              )
              .toList();
      await _hashTagsTable.upsert(_data, onConflict: KeyNames.hashtag, ignoreDuplicates: false);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertPostHashTag(List<String> hashtags, String postId) async {
    try {
      final _data =
          hashtags.map((hashtag) => {KeyNames.hashtag: hashtag, KeyNames.post_id: postId}).toList();
      await _postsHashtags.insert(_data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
