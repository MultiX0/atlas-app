import 'dart:developer';

import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/post_comments/models/comment_model.dart';
import 'package:atlas_app/features/post_comments/models/reply_model.dart';
import 'package:atlas_app/imports.dart';

final postCommentsDbProvider = Provider<PostCommentsDb>((ref) {
  return PostCommentsDb();
});

class PostCommentsDb {
  SupabaseClient get _client => Supabase.instance.client;

  SupabaseQueryBuilder get _postCommetnRepliesView =>
      _client.from(ViewNames.post_comment_replies_with_likes);
  SupabaseQueryBuilder get _postCommentsView => _client.from(ViewNames.post_comments_with_meta);

  Future<List<PostCommentReplyModel>> getPostCommentsReplies({
    required String commentId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _postCommetnRepliesView
          .select("*")
          .eq(KeyNames.comment_id, commentId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      return data.map((r) => PostCommentReplyModel.fromMap(r)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<PostCommentModel>> getPostComments({
    required String postId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _postCommentsView
          .select("*")
          .eq(KeyNames.post_id, postId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      return data.map((c) => PostCommentModel.fromMap(c)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
