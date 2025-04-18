import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/core/common/utils/extract_key_words.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/features/hashtags/db/hashtags_db.dart';
import 'package:atlas_app/imports.dart';

final postsDbProvider = Provider<PostsDb>((ref) {
  return PostsDb();
});

class PostsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postsView => _client.from(ViewNames.post_details_with_mentions);
  SupabaseQueryBuilder get _postsTable => _client.from(TableNames.posts);
  SupabaseQueryBuilder get _postLikesTable => _client.from(TableNames.post_likes);
  SupabaseQueryBuilder get _mentionsTable => _client.from(TableNames.post_mentions);
  HashtagsDb get hashtagDb => HashtagsDb();

  Future<List<PostModel>> getUserPosts({
    required int startIndex,
    required int pageSize,
    required String userId,
  }) async {
    try {
      final _data = await _postsView
          .select("*")
          .eq(KeyNames.userId, userId)
          .range(startIndex, startIndex + pageSize - 1);

      return _data.map((post) => PostModel.fromMap(post)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertPost(
    String postId,
    String post,
    String userId,
    List<String>? images, {
    bool canRepost = true,
    bool canComment = true,
    String? parentId,
  }) async {
    try {
      await _postsTable.insert({
        KeyNames.id: postId,
        KeyNames.content: post,
        KeyNames.userId: userId,
        KeyNames.images: images ?? [],
        KeyNames.can_reposted: canRepost,
        KeyNames.comments_open: canComment,
        KeyNames.parent_post: parentId,
      });

      final hashtags = extractHashtagKeyword(post);
      final mentions = extractSlashKeywords(post);
      await Future.wait([hashtagDb.insertNewHashTag(hashtags), insertMentions(mentions, postId)]);
      await hashtagDb.insertPostHashTag(hashtags, postId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertMentions(List<SlashEntity> mentions, String postId) async {
    try {
      final data =
          mentions
              .map(
                (mention) => {
                  KeyNames.entity_id: mention.id,
                  KeyNames.mention_type: mention.type == 'char' ? "character" : mention.type,
                  KeyNames.post_id: postId,
                },
              )
              .toList();
      await _mentionsTable.upsert(data);
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

  Future<void> handleUserLike(PostModel post, String userId) async {
    try {
      log("Database operation: post.userLiked = ${post.userLiked}");

      if (!post.userLiked) {
        // User IS liking the post now, so INSERT a like
        log("Inserting like");
        await _postLikesTable.insert({KeyNames.userId: userId, KeyNames.post_id: post.postId});
      } else {
        // User is NOT liking the post now, so DELETE the like
        log("Deleting like");
        await _postLikesTable
            .delete()
            .eq(KeyNames.post_id, post.postId)
            .eq(KeyNames.userId, userId);
      }
    } catch (e) {
      log("Database error: ${e.toString()}");
      rethrow;
    }
  }

  Future<List<PostModel>> getPostsByHashtag({
    required String hashtag,
    required int startIndex,
    required int pageSize,
    required HashtagFilter filter,
  }) async {
    try {
      var query = _postsView
          .select("*")
          .contains(KeyNames.hashtags, [hashtag])
          .range(startIndex, startIndex + pageSize - 1);
      if (filter == HashtagFilter.LAST_CREATED) {
        query = query.order(KeyNames.created_at, ascending: false);
      } else {
        query = query.order(KeyNames.like_count, ascending: false);
      }

      final data = await query;
      return data.map((post) => PostModel.fromMap(post)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
