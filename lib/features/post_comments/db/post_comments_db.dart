import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/features/notifications/interfaces/notifications_interface.dart';
import 'package:atlas_app/features/post_comments/models/comment_model.dart';
import 'package:atlas_app/features/post_comments/models/reply_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';

final postCommentsDbProvider = Provider<PostCommentsDb>((ref) {
  return PostCommentsDb();
});

class PostCommentsDb {
  SupabaseClient get _client => Supabase.instance.client;
  // SupabaseQueryBuilder get _commentsTable => _client.from(TableNames.post_comments);
  // SupabaseQueryBuilder get _commentRepliesTable => _client.from(TableNames.post_comment_replies);
  SupabaseQueryBuilder get _postCommetnRepliesView =>
      _client.from(ViewNames.post_comment_replies_with_likes);
  SupabaseQueryBuilder get _postCommentsView => _client.from(ViewNames.post_comments_with_meta);
  NotificationsDb get _notificationsDb => NotificationsDb();

  Dio get _dio => Dio();

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

  Future<void> handleCommentLike({
    required String id,
    required UserModel me,
    required String ownerId,
    required String postAuthorName,
    required String postId,
  }) async {
    try {
      final notification = NotificationsInterface.postReplyCommentNotification(
        userId: ownerId,
        username: me.username,
        postTitle: postAuthorName,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      await Future.wait([
        _client.rpc(FunctionNames.toggle_post_comment_like, params: {'p_comment_id': id}),
        if (me.userId != ownerId) _notificationsDb.sendNotificatiosn(notification),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleReplyLike({
    required String id,
    required UserModel me,
    required String ownerId,
    required String postAuthorName,
    required String postId,
  }) async {
    try {
      final notification = NotificationsInterface.postReplyCommentNotification(
        userId: ownerId,
        username: me.username,
        postTitle: postAuthorName,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      await Future.wait([
        _client.rpc(FunctionNames.toggle_post_comment_reply_like, params: {'p_reply_id': id}),
        if (me.userId != ownerId) _notificationsDb.sendNotificatiosn(notification),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _client.rpc(FunctionNames.delete_post_comment, params: {'p_comment_id': id});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteReply(String id) async {
    try {
      await _client.rpc(FunctionNames.delete_post_comment_reply, params: {'p_reply_id': id});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleAddNewCommentReply(
    PostCommentReplyModel reply, {
    required String postId,
  }) async {
    try {
      final notification = NotificationsInterface.commentReplyNotification(
        userId: reply.parentAuthorId,
        username: reply.user!.username,
        data: {'route': '${Routes.postPage}/$postId'},
      );
      final headers = await generateAuthHeaders();

      await Future.wait([
        if (reply.userId != reply.parentAuthorId) _notificationsDb.sendNotificatiosn(notification),
        _dio.post(
          '${appAPI}post-comment-reply',
          options: Options(headers: headers),
          data: jsonEncode({
            KeyNames.id: reply.id,
            KeyNames.userId: reply.userId,
            KeyNames.comment_id: reply.commentId,
            KeyNames.content: reply.content,
            'token': _client.auth.currentSession!.accessToken,
            KeyNames.parent_comment_author_id: reply.parentAuthorId,
          }),
        ),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleAddNewComment(PostModel post, PostCommentModel comment, UserModel me) async {
    try {
      final notification = NotificationsInterface.postCommentNotification(
        userId: post.userId,
        username: me.username,
        data: {'route': '${Routes.postPage}/${post.postId}'},
      );
      final headers = await generateAuthHeaders();
      await Future.wait([
        if (post.userId != me.userId) _notificationsDb.sendNotificatiosn(notification),
        _dio.post(
          '${appAPI}post-comment',
          options: Options(headers: headers),
          data: jsonEncode({
            KeyNames.id: comment.id,
            KeyNames.userId: me.userId,
            KeyNames.post_id: post.postId,
            KeyNames.content: comment.content,
            'token': _client.auth.currentSession!.accessToken,
          }),
        ),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
