import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/hashtags/models/hashtag_model.dart';
import 'package:atlas_app/imports.dart';

final hashtagsDbProvider = Provider<HashtagsDb>((ref) {
  return HashtagsDb();
});

class HashtagsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _hashTagsTable => _client.from(TableNames.hashtags);
  SupabaseQueryBuilder get _postsHashtags => _client.from(TableNames.post_hashtags);
  SupabaseQueryBuilder get _hashTagsView => _client.from(ViewNames.hashtag_post_counts);

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

  Future<List<HashtagModel>> searchHashTags(String query) async {
    try {
      final data = await _hashTagsView.select("*").ilike(KeyNames.hashtag, "%$query%");
      return data.map((hashTag) => HashtagModel.fromMap(hashTag)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
