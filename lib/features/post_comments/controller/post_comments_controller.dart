import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/post_comments/db/post_comments_db.dart';
import 'package:atlas_app/features/post_comments/models/comment_model.dart';
import 'package:atlas_app/features/post_comments/models/reply_model.dart';
import 'package:atlas_app/features/post_comments/providers/comment_replies_providers.dart';
import 'package:atlas_app/features/post_comments/providers/comments_state_provider.dart';
import 'package:atlas_app/features/post_comments/providers/providers.dart';
import 'package:atlas_app/features/posts/db/posts_db.dart';
import 'package:atlas_app/features/posts/providers/post_state.dart';
import 'package:atlas_app/features/reports/db/reports_db.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

final postCommentsControllerProvider =
    StateNotifierProvider.family<PostCommentsController, bool, String>((ref, postId) {
      return PostCommentsController(ref: ref);
    });

class PostCommentsController extends StateNotifier<bool> {
  final Ref _ref;
  PostCommentsController({required Ref ref}) : _ref = ref, super(false);

  Uuid uuid = const Uuid();

  PostCommentsDb get db => _ref.watch(postCommentsDbProvider);
  PostsDb get _postsDb => _ref.watch(postsDbProvider);
  ReportsDb get _reportsDb => ReportsDb();

  PostModel? postModel;

  Future<void> addPostComment({required String content, required String postId}) async {
    final me = _ref.read(userState.select((s) => s.user!));
    final id = uuid.v4();

    final comment = PostCommentModel(
      id: id,
      postId: postId,
      createdAt: DateTime.now(),
      content: content,
      isDeleted: false,
      isUpdated: false,
      userId: me.userId,
      likesCount: 0,
      repliesCount: 0,
      isLiked: false,
      user: me,
    );
    _ref.read(postCommentsStateProvider(postId).notifier).addComment(comment);

    final post = postModel ?? await _postsDb.getPostByID(postId);
    postModel = post;
    final _currentPost = _ref.read(postStateProvider);
    final _current =
        (_currentPost != null)
            ? (_currentPost.postId == post.postId)
                ? _currentPost
                : null
            : null;

    try {
      await db.handleAddNewComment(post, comment, me);
      if (_current != null) {
        final newPost = _current.copyWith(commentsCount: post.commentsCount + 1);
        _ref.read(postStateProvider.notifier).updatePost(newPost);
        postModel = newPost;
      }
    } catch (e, trace) {
      _ref.read(postStateProvider.notifier).updatePost(post);
      _ref.read(postCommentReplisStateNotifier(comment.id).notifier).deleteComment(id);

      CustomToast.error(errorMsg);
      log(e.toString(), stackTrace: trace);
      if (kDebugMode) {
        print('$e\n$trace');
      }

      rethrow;
    }
  }

  Future<void> replyToComment({
    required String commentId,
    required String replyContent,
    required String postId,
  }) async {
    final post = postModel ?? await _postsDb.getPostByID(postId);
    postModel = post;

    final id = uuid.v4();

    final _currentPost = _ref.read(postStateProvider);
    final _current =
        (_currentPost != null)
            ? (_currentPost.postId == post.postId)
                ? _currentPost
                : null
            : null;

    final comment = _ref.read(postCommentsStateProvider(post.postId).notifier).getById(commentId);
    try {
      final _map = Map.from(_ref.read(postCommentRepliedToProvider) ?? {});
      _ref.read(postCommentRepliedToProvider.notifier).state = null;

      final parentCommentUserId = _map[KeyNames.parent_comment_author_id];
      final me = _ref.read(userState.select((s) => s.user!));
      final replyModel = PostCommentReplyModel(
        parent_user: _map[KeyNames.parent_user],
        id: id,
        commentId: commentId,
        content: replyContent,
        userId: me.userId,
        parentAuthorId: parentCommentUserId,
        createdAt: DateTime.now(),
        user: me,
        isEdited: false,
        isDeleted: false,
        likeCounts: 0,
        isLiked: false,
      );

      _ref.read(postCommentReplisStateNotifier(commentId).notifier).addComment(replyModel);
      _ref
          .read(postCommentsStateProvider(postId).notifier)
          .updateComment(comment.copyWith(repliesCount: comment.repliesCount + 1));
      if (_current != null) {
        final newPost = _current.copyWith(commentsCount: post.commentsCount + 1);
        _ref.read(postStateProvider.notifier).updatePost(newPost);
        postModel = newPost;
      }
      await db.handleAddNewCommentReply(replyModel, postId: post.postId);
    } catch (e, trace) {
      CustomToast.error(errorMsg);
      _ref.read(postCommentReplisStateNotifier(comment.id).notifier).deleteComment(id);
      _ref.read(postCommentsStateProvider(post.postId).notifier).updateComment(comment);
      _ref.read(postStateProvider.notifier).updatePost(post);

      log(e.toString(), stackTrace: trace);
      if (kDebugMode) {
        print('$e\n$trace');
      }

      rethrow;
    }
  }

  Future<void> handlePostCommentReplyLike(
    PostCommentReplyModel reply, {
    required String postId,
  }) async {
    try {
      final me = _ref.read(userState.select((s) => s.user!));
      final post = postModel ?? await _postsDb.getPostByID(postId);
      postModel = post;

      _ref
          .read(postCommentReplisStateNotifier(reply.commentId).notifier)
          .updateComment(
            reply.copyWith(
              likeCounts: reply.isLiked ? reply.likeCounts - 1 : reply.likeCounts + 1,
              isLiked: !reply.isLiked,
            ),
          );
      await db.handleReplyLike(
        id: reply.id,
        me: me,
        ownerId: reply.userId,
        postAuthorName: post.user.username,
        postId: post.postId,
        commentId: reply.commentId,
      );
    } catch (e) {
      _ref.read(postCommentReplisStateNotifier(reply.commentId).notifier).updateComment(reply);
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleCommentLike(PostCommentModel comment) async {
    final me = _ref.read(userState.select((s) => s.user!));
    final post = postModel ?? await _postsDb.getPostByID(comment.postId);
    postModel = post;
    try {
      _ref
          .read(postCommentsStateProvider(comment.postId).notifier)
          .updateComment(
            comment.copyWith(
              likesCount: comment.isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
              isLiked: !comment.isLiked,
            ),
          );
      await db.handleCommentLike(
        id: comment.id,
        me: me,
        ownerId: post.userId,
        postAuthorName: post.user.username,
        postId: post.postId,
      );
    } catch (e) {
      _ref.read(postCommentsStateProvider(comment.postId).notifier).updateComment(comment);
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleCommentDelete({
    required bool isReply,
    required String id,
    required String commentId,
    required String postId,
  }) async {
    final post = postModel ?? await _postsDb.getPostByID(postId);
    postModel = post;
    log("post comments: ${post.commentsCount}");
    try {
      PostModel newPost;
      if (isReply) {
        _ref.read(postCommentReplisStateNotifier(commentId).notifier).deleteComment(id);
        newPost = post.copyWith(commentsCount: post.commentsCount - 1);
        await db.deleteReply(id);
      } else {
        final comment = _ref.read(postCommentsStateProvider(postId).notifier).getById(commentId);
        _ref.read(postCommentsStateProvider(postId).notifier).deleteComment(commentId);

        newPost = post.copyWith(commentsCount: post.commentsCount - (1 + comment.repliesCount));
        await db.deleteComment(commentId);
      }

      _ref.read(postStateProvider.notifier).updatePost(newPost);
      postModel = newPost;
      CustomToast.success("تم حذف التعليق بنجاح");
    } catch (e) {
      _ref.read(postStateProvider.notifier).updatePost(post);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addPostCommentReport({
    required String report,
    required BuildContext context,
    required bool isReply,
    required String contentId,
  }) async {
    try {
      final me = _ref.read(userState.select((s) => s.user!));
      await _reportsDb.addPostCommentReport(
        report: report,
        reporter_id: me.userId,
        contentId: contentId,
        isReply: isReply,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
