import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/enum/hashtag_enum.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/core/common/utils/extract_key_words.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';
import 'package:atlas_app/core/services/user_vector_service.dart';
import 'package:atlas_app/features/hashtags/db/hashtags_db.dart';
import 'package:atlas_app/features/interactions/db/interactions_db.dart';
import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/features/notifications/interfaces/notifications_interface.dart';
import 'package:atlas_app/features/interactions/models/post_interaction_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final postsDbProvider = Provider<PostsDb>((ref) {
  return PostsDb();
});

class PostsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _postsView => _client.from(ViewNames.post_details_with_mentions);
  SupabaseQueryBuilder get _postsTable => _client.from(TableNames.posts);
  SupabaseQueryBuilder get _mentionsTable => _client.from(TableNames.post_mentions);
  SupabaseQueryBuilder get _pinnedPostsTable => _client.from(TableNames.pinned_posts);
  SupabaseQueryBuilder get _savedPostsTable => _client.from(TableNames.saved_posts);
  // SupabaseQueryBuilder get _postInteractionsTable => _client.from(TableNames.post_interactions);

  static Dio get _dio => Dio();
  HashtagsDb get hashtagDb => HashtagsDb();
  NotificationsDb get notificationsDb => NotificationsDb();
  InteractionsDb get _interactionsDb => InteractionsDb();

  Future<List<PostModel>> getUserPosts({
    required int startIndex,
    required int pageSize,
    required String userId,
  }) async {
    try {
      final _data = await _postsView
          .select("*")
          .eq(KeyNames.userId, userId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      return _data.map((post) => PostModel.fromMap(post)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<PostModel> getPostByID(String postId) async {
    try {
      final postData = await _postsView.select("*").eq(KeyNames.post_id, postId).maybeSingle();
      if (postData != null) return PostModel.fromMap(postData);
      throw Exception("Post with id: $postId is not found");
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertPost(
    String postId,
    String post,
    UserModel user,
    List<String>? images, {
    bool canRepost = true,
    bool canComment = true,
    String? parentId,
  }) async {
    try {
      final userId = user.userId;
      await _postsTable.insert({
        KeyNames.id: postId,
        KeyNames.content: post,
        KeyNames.userId: userId,
        KeyNames.images: images ?? [],
        KeyNames.can_reposted: canRepost,
        KeyNames.comments_open: canComment,
        KeyNames.parent_post: parentId,
      });

      final hashtags = extractHashtagKeyword(post).toSet().toList();
      List<SlashEntity> mentions = [];
      for (final m in extractSlashKeywords(post)) {
        if (!mentions.any((_m) => m.id == _m.id)) {
          mentions.add(m);
        }
      }

      List<String> userMentions =
          extractMentionKeywords(post).where((m) => m != user.username.toLowerCase()).toList();

      if (parentId != null && parentId.isNotEmpty) {
        final String userId = await getUserIdByPost(parentId);
        final notification = NotificationsInterface.postRepostNotification(
          userId: userId,
          username: user.username,
        );
        await notificationsDb.sendNotificatiosn(notification);
      }

      try {
        await Future.wait([
          hashtagDb.insertNewHashTag(hashtags),
          insertMentions(mentions, postId),
          if (userMentions.isNotEmpty)
            notificationsDb.sendMentionNotifications(userMentions, 'p', user),
        ]);
      } catch (e) {
        rethrow;
      }
      await Future.wait([
        hashtagDb.insertPostHashTag(hashtags, postId),
        insertEmbedding(id: postId, content: post, userId: userId),
      ]);
      await updateUserVector(userId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> seePost(String postId, String userId) async {
    try {
      await _client.rpc(
        FunctionNames.mark_post_as_seen,
        params: {'p_user_id': userId, 'p_post_id': postId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertEmbedding({
    required String id,
    required String content,
    required String userId,
  }) async {
    try {
      final body = jsonEncode({
        "type": "post",
        "content": content,
        "content_id": id,
        "user_id": userId,
      });
      final headers = await generateAuthHeaders();
      await _dio.post('${appAPI}embedding', options: Options(headers: headers), data: body);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handlePostPin(PostModel post) async {
    try {
      if (post.isPinned) {
        await _pinnedPostsTable.delete().eq(KeyNames.post_id, post.postId);
      } else {
        await _pinnedPostsTable.insert({KeyNames.post_id: post.postId});
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handlePostSave(PostModel post, String userId) async {
    try {
      if (post.isSaved) {
        await _savedPostsTable
            .delete()
            .eq(KeyNames.post_id, post.postId)
            .eq(KeyNames.userId, userId);
      } else {
        await _savedPostsTable.insert({KeyNames.post_id: post.postId, KeyNames.userId: userId});
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updatePost(
    PostModel post,
    List<String> ogHashtags,
    List<SlashEntity> ogMentions,
  ) async {
    try {
      final hashtags = extractHashtagKeyword(post.content);
      final mentions = extractSlashKeywords(post.content);

      final removedHashtags = ogHashtags.where((tag) => !hashtags.contains(tag)).toList();
      final addedHashtags = hashtags.where((tag) => !ogHashtags.contains(tag)).toList();
      final removedMentions =
          ogMentions.where((mention) => !mentions.any((m) => m.id == mention.id)).toList();
      List<String> removedMentionsIds = removedMentions.map((m) => m.id).toList();
      final addedMentions =
          mentions.where((mention) => !ogMentions.any((m) => m.id == mention.id)).toList();
      await _postsTable
          .update({
            KeyNames.content: post.content,
            KeyNames.can_reposted: post.canReposted,
            KeyNames.comments_open: post.comments_open,
            KeyNames.updated_at: DateTime.now().toIso8601String(),
          })
          .eq(KeyNames.id, post.postId);
      await Future.wait([
        hashtagDb.removeHashtagsFromPost(removedHashtags, post.postId),
        removeMentionFromPost(removedMentionsIds, post.postId),
        hashtagDb.insertNewHashTag(addedHashtags),
        insertMentions(addedMentions, post.postId),
      ]);
      await hashtagDb.insertPostHashTag(addedHashtags, post.postId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await Future.wait([
        _client.rpc(FunctionNames.soft_delete_post, params: {KeyNames.post_id: postId}),
        removePostVectorPoint(postId),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> removePostVectorPoint(String id) async {
    try {
      final headers = await generateAuthHeaders();
      await _dio.post(
        "${appAPI}delete-post",
        options: Options(headers: headers),
        data: jsonEncode({"id": id}),
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertMentions(List<SlashEntity> mentions, String postId) async {
    try {
      final _mentions =
          mentions
              .map((m) => m.type == 'char' ? SlashEntity('character', m.id, m.title) : m)
              .toList();
      for (final mention in _mentions) {
        await _client.rpc(
          FunctionNames.upsert_post_mention,
          params: {"p_post_id": postId, "p_entity_id": mention.id, "p_mention_type": mention.type},
        );
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> removeMentionFromPost(List<String> ids, String postId) async {
    try {
      await _mentionsTable.delete().eq(KeyNames.post_id, postId).inFilter(KeyNames.entity_id, ids);
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

  Future<void> handleUserLike(PostModel post, UserModel user) async {
    try {
      log("Database operation: post.userLiked = ${post.userLiked}");

      log("Inserting like");
      final notification = NotificationsInterface.postLikeNotification(
        userId: post.userId,
        username: user.username,
      );
      await Future.wait([
        if ((user.userId != post.userId) && !post.userLiked)
          notificationsDb.sendNotificatiosn(notification),
        _client.rpc(FunctionNames.toggle_post_like, params: {'target_post_id': post.postId}),
      ]);
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

  Future<List<String>> fetchUserRecommendation({required String userId, required int page}) async {
    try {
      final url = '${appAPI}recommend-posts?user_id=$userId&page=$page';
      final headers = await generateAuthHeaders();
      final options = Options(headers: headers);
      final res = await _dio.get(url, options: options);
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! <= 299) {
        if (res.data == null) {
          log('Error: Response data is null');
          return [];
        }

        final data = jsonDecode(res.data.toString());

        if (data is List) {
          return List<String>.from(
            data.where((item) => item != null).map((item) => item.toString()),
          );
        } else {
          log('Error: Expected a List but got ${data.runtimeType}');
          return [];
        }
      }
      return [];
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<List<PostModel>> getMainFeeds({
    required String userId,
    required int page,
    required int startAt,
    required int pageSize,
  }) async {
    try {
      final ids = await fetchUserRecommendation(userId: userId, page: page);
      var query = _postsView.select("*");

      if (ids.isNotEmpty) {
        query = query.inFilter(KeyNames.post_id, ids);
        if (!kDebugMode) {
          //remove personal posts from the feeds in prod
          query = query.neq(KeyNames.userId, userId);
        }
      } else {
        query.range(startAt, startAt + pageSize - 1);
      }

      final data = await query;
      final idIndexMap = {for (var i = 0; i < ids.length; i++) ids[i]: i};
      data.sort(
        (a, b) => (idIndexMap[a[KeyNames.post_id]] ?? ids.length).compareTo(
          idIndexMap[b[KeyNames.post_id]] ?? ids.length,
        ),
      );
      return data.map((p) => PostModel.fromMap(p)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insetPostInteraction(PostInteractionModel interactionModel) async {
    try {
      await _interactionsDb.upsertPostInteraction(interactionModel);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<String> getUserIdByPost(String postId) async {
    try {
      final data = await _postsTable.select(KeyNames.userId).eq(KeyNames.id, postId).maybeSingle();
      return data?[KeyNames.userId] ?? "";
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateInteractionModel(PostInteractionModel interactionModel) async {
    try {
      await _interactionsDb.upsertPostInteraction(interactionModel);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
