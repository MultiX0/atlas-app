import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/core/services/user_vector_service.dart';
import 'package:atlas_app/features/notifications/db/notifications_db.dart';
import 'package:atlas_app/features/notifications/interfaces/notifications_interface.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_model.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_reply_model.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/models/novel_preview_model.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';

final novelsDbProvider = Provider<NovelsDb>((ref) {
  return NovelsDb();
});

class NovelsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _novelsGenresesData => _client.from(TableNames.novels_genreses_data);
  SupabaseQueryBuilder get _novelsGenresTable => _client.from(TableNames.novel_genres);
  SupabaseQueryBuilder get _novelsTable => _client.from(TableNames.novels);
  SupabaseQueryBuilder get _novelsView => _client.from(ViewNames.novels_details);
  // SupabaseQueryBuilder get _novelViewsTable => _client.from(TableNames.novel_views);
  SupabaseQueryBuilder get _novelChaptersTable => _client.from(TableNames.novel_chapters);
  SupabaseQueryBuilder get _draftChaptersTable => _client.from(TableNames.novel_chapter_drafts);
  SupabaseQueryBuilder get _chaptersView => _client.from(ViewNames.novel_chapters_with_views);
  SupabaseQueryBuilder get _chapterCommetnsView =>
      _client.from(ViewNames.novel_chapter_comments_with_meta);

  SupabaseQueryBuilder get _chapterCommetnRepliesView =>
      _client.from(ViewNames.novel_chapter_comment_replies_with_likes);

  SupabaseQueryBuilder get _novelChapterCommentsTable =>
      _client.from(TableNames.novel_chapter_comments);

  SupabaseQueryBuilder get _novelChapterCommentRepliesTable =>
      _client.from(TableNames.novel_chapter_comment_replies);

  static Dio get _dio => Dio();
  NotificationsDb get _notificationsDb => NotificationsDb();

  // SupabaseQueryBuilder get _novelsFavoriteTable => _client.from(TableNames.users_favorite_novels);

  Future<NovelModel?> getNovel(String id) async {
    try {
      final data = await _novelsView.select("*").eq(KeyNames.id, id).maybeSingle();
      if (data == null) return null;
      return NovelModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<ChapterModel>> getChapters({
    required String novelId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _chaptersView
          .select("*")
          .eq(KeyNames.novel_id, novelId)
          .order(KeyNames.number, ascending: false)
          .range(startIndex, (startIndex + pageSize - 1));

      return data.map((c) => ChapterModel.fromMap(c)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelChapterCommentWithMeta>> getChapterComments({
    required String chapterId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _chapterCommetnsView
          .select("*")
          .eq(KeyNames.chapter_id, chapterId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      return data.map((c) => NovelChapterCommentWithMeta.fromMap(c)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelChapterCommentReplyWithLikes>> getChapterCommentsReplies({
    required String commentId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _chapterCommetnRepliesView
          .select("*")
          .eq(KeyNames.comment_id, commentId)
          .order(KeyNames.created_at, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      return data.map((r) => NovelChapterCommentReplyWithLikes.fromMap(r)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteChapter(String chapterId) async {
    try {
      await _novelChaptersTable.delete().eq(KeyNames.id, chapterId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleAddNewChapterCommentReply(
    NovelChapterCommentReplyWithLikes reply,
    NovelModel novel,
  ) async {
    try {
      final notification = NotificationsInterface.novelChapterReplyCommentNotification(
        userId: reply.parentCommentAuthorId,
        username: reply.user.username,
        novelTitle: novel.title,
      );
      await Future.wait([
        if (reply.userId != reply.parentCommentAuthorId)
          _notificationsDb.sendNotificatiosn(notification),
        _novelChapterCommentRepliesTable.insert({
          KeyNames.id: reply.id,
          KeyNames.userId: reply.userId,
          KeyNames.content: reply.content,
          KeyNames.parent_comment_author_id: reply.parentCommentAuthorId,
          KeyNames.comment_id: reply.commentId,
        }),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleChapterView(String chapterId) async {
    try {
      await _client.rpc(FunctionNames.log_novel_chapter_view, params: {'p_chapter_id': chapterId});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleFavorite(NovelModel novel, UserModel user) async {
    try {
      final notification = NotificationsInterface.novelLikeNotification(
        userId: novel.userId,
        username: user.username,
      );
      Future.wait([
        if (novel.userId != user.userId && !novel.isFavorite)
          _notificationsDb.sendNotificatiosn(notification),
        _client.rpc(FunctionNames.toggle_favorite_novel, params: {'p_novel_id': novel.id}),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleNovelView(String novelId) async {
    try {
      await _client.rpc(FunctionNames.log_novel_view, params: {'p_novel_id': novelId});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleChapterLike(ChapterModel chapter, UserModel user, NovelModel novel) async {
    try {
      final notification = NotificationsInterface.novelChapterLikeNotification(
        userId: novel.userId,
        username: user.username,
        novelTitle: novel.title,
      );
      Future.wait([
        if (novel.userId != user.userId && !chapter.isLiked)
          _notificationsDb.sendNotificatiosn(notification),
        _client.rpc(FunctionNames.toggle_chapter_like, params: {'p_chapter_id': chapter.id}),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNewDraft(ChapterDraftModel draft) async {
    try {
      await _draftChaptersTable.insert(draft.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNewChapterComment({
    required String chapterId,
    required String commentId,
    required String content,
    required UserModel user,
    required String novelAuthor,
  }) async {
    try {
      final notification = NotificationsInterface.novelChapterCommentNotification(
        userId: novelAuthor,
        username: user.username,
      );
      await Future.wait([
        if (user.userId != novelAuthor) _notificationsDb.sendNotificatiosn(notification),
        _novelChapterCommentsTable.insert({
          KeyNames.content: content,
          KeyNames.id: commentId,
          KeyNames.userId: user.userId,
          KeyNames.chapter_id: chapterId,
        }),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleChapterCommentLike(String commentId) async {
    try {
      await _client.rpc(
        FunctionNames.toggle_chapter_comment_like,
        params: {'p_comment_id': commentId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleChapterCommentReplyLike(
    String replyId,
    UserModel me,
    NovelModel novel,
    String commentOwnerId,
  ) async {
    try {
      final notification = NotificationsInterface.novelChapterLikeCommentNotification(
        userId: commentOwnerId,
        username: me.username,
        novelTitle: novel.title,
      );

      await Future.wait([
        if (me.userId != commentOwnerId) _notificationsDb.sendNotificatiosn(notification),
        _client.rpc(
          FunctionNames.toggle_chapter_comment_reply_like,
          params: {'p_reply_id': replyId},
        ),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> publishNovel(String novelId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _novelsTable.update({KeyNames.published_at: now}).eq(KeyNames.id, novelId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNewChapter(ChapterModel chapter, NovelModel novel) async {
    try {
      if (novel.publishedAt == null) {
        await publishNovel(novel.id);
      }
      await _novelChaptersTable.insert(chapter.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<ChapterDraftModel>> getDrafts({
    required String novelId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _draftChaptersTable
          .select("*")
          .eq(KeyNames.novel_id, novelId)
          .eq(KeyNames.is_deleted, false)
          .order(KeyNames.updated_at, ascending: false)
          .range(startIndex, (startIndex + pageSize - 1));

      return data.map((dC) => ChapterDraftModel.fromMap(dC)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateDraft({
    required List<Map<String, dynamic>> content,
    required String? title,
    required String id,
  }) async {
    try {
      await _draftChaptersTable
          .update({
            KeyNames.content: content,
            KeyNames.title: title,
            KeyNames.updated_at: DateTime.now().toIso8601String(),
          })
          .eq(KeyNames.id, id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteDraft(ChapterDraftModel draft) async {
    try {
      await _draftChaptersTable.update({KeyNames.is_deleted: true}).eq(KeyNames.id, draft.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getNextChapterNumber(String novelId) async {
    try {
      final data = await _client.rpc(
        FunctionNames.get_next_chapter_number,
        params: {'novel_id_input': novelId},
      );
      return data.toInt();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateChapter(ChapterModel chapter) async {
    try {
      await _novelChaptersTable
          .update({KeyNames.title: chapter.title, KeyNames.content: chapter.content})
          .eq(KeyNames.id, chapter.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> publishChapter(
    NovelModel novel,
    ChapterDraftModel draft,
    ChapterModel chapter,
  ) async {
    try {
      log("original chapter: ${draft.originalChapterId}");
      if (draft.originalChapterId != null && draft.originalChapterId!.isNotEmpty) {
        await updateChapter(chapter.copyWith(id: draft.originalChapterId));
        await deleteDraft(draft);
        return;
      }
      await Future.wait([deleteDraft(draft), insertNewChapter(chapter, novel)]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelModel>> searchNovels({
    required int startIndex,
    required int pageSize,
    required String query,
  }) async {
    try {
      final data = await _novelsView
          .select("*")
          .textSearch(KeyNames.title, query)
          .range(startIndex, startIndex + pageSize - 1);

      return data.map((n) => NovelModel.fromMap(n)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelsGenreModel>> getNovelsGenreses() async {
    try {
      final data = await _novelsGenresesData.select("*");
      return data.map((mapData) => NovelsGenreModel.fromMap(mapData)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNovelGenreses(List<NovelsGenreModel> genres, String novelId) async {
    try {
      if (genres.isEmpty) return;
      final data =
          genres.map((g) => {KeyNames.genre_id: g.id, KeyNames.novel_id: novelId}).toList();
      await _novelsGenresTable.insert(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteNovelGenreses(String novelId) async {
    try {
      await _novelsGenresTable.delete().eq(KeyNames.novel_id, novelId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNovel(Map<String, dynamic> data) async {
    try {
      await Future.wait([
        _novelsTable.upsert(data, ignoreDuplicates: false, onConflict: KeyNames.id),
        insertEmbedding(
          content: "${data[KeyNames.title]}\n${data[KeyNames.story]}",
          id: data[KeyNames.id],
          userId: data[KeyNames.userId],
        ),
      ]);
      await updateUserVector(data[KeyNames.userId]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteChapterComment(String commentId) async {
    try {
      await _client.rpc(FunctionNames.delete_chapter_comment, params: {'p_comment_id': commentId});
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteChapterCommentReply(String replyId) async {
    try {
      await _client.rpc(
        FunctionNames.delete_chapter_comment_reply,
        params: {'p_reply_id': replyId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getUserChaptersReadCount(String novelId) async {
    try {
      final count = await _client.rpc(
        FunctionNames.get_user_chapters_read_count,
        params: {KeyNames.novel_id: novelId},
      );

      if (count == null) return 0;

      if (count is int) return count;
      if (count is double) return count.toInt();
      if (count is num) return count.toInt();

      return int.tryParse(count.toString()) ?? 0;
    } catch (e, stackTrace) {
      log(
        'Error getting chapters read count for novel $novelId: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> handleInsertNewNovel({
    required String id,
    required String title,
    required String story,
    required String src_lang,
    required int age_rating,
    required String userId,
    required String poster,
    required List<NovelsGenreModel> genres,
    String? banner,
  }) async {
    try {
      final data = {
        KeyNames.title: title,
        KeyNames.story: story,
        KeyNames.userId: userId,
        KeyNames.poster: poster,
        KeyNames.age_rating: age_rating,
        KeyNames.banner: banner,
        KeyNames.src_lang: src_lang,
        KeyNames.id: id,
      };
      await insertNovel(data);
      await insertNovelGenreses(genres, id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<NovelsGenreModel>> handleUpdatedNewNovel({
    required String id,
    required String title,
    required String story,
    required String src_lang,
    required int age_rating,
    required String userId,
    required String poster,
    required List<NovelsGenreModel> genres,
    required List<NovelsGenreModel> oldGenreses,
    String? banner,
  }) async {
    try {
      await deleteNovelGenreses(id);

      final data = {
        KeyNames.title: title,
        KeyNames.story: story,
        KeyNames.userId: userId,
        KeyNames.poster: poster,
        KeyNames.age_rating: age_rating,
        KeyNames.banner: banner,
        KeyNames.src_lang: src_lang,
        KeyNames.id: id,
      };
      await insertNovel(data);
      await insertNovelGenreses(genres, id);
      return genres;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<String>> fetchUserRecommendation({required String userId, required int page}) async {
    try {
      final url = '${appAPI}recommend-novels?user_id=$userId&page=$page';
      final headers = await generateAuthHeaders();
      final options = Options(headers: headers);
      final res = await _dio.get(url, options: options);
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! <= 299) {
        if (res.data == null) {
          log('Error: Response data is null');
          return [];
        }

        log('Response data: ${res.data.toString()}');

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

  Future<List<NovelPreviewModel>> getNovelExplore({
    required String userId,
    required int page,
    required int startAt,
    required int pageSize,
  }) async {
    try {
      final ids = await fetchUserRecommendation(userId: userId, page: page);
      var query = _novelsTable.select("*");

      if (ids.isNotEmpty) {
        log("there is recommendation data");
        log(ids.toString());
        query = query.inFilter(KeyNames.id, ids).filter(KeyNames.published_at, 'not.is', null);
      } else {
        query.filter(KeyNames.published_at, 'not.is', null).range(startAt, startAt + pageSize - 1);
      }

      final novelData = await query;
      final idIndexMap = {for (var i = 0; i < ids.length; i++) ids[i]: i};
      novelData.sort(
        (a, b) => (idIndexMap[a[KeyNames.post_id]] ?? ids.length).compareTo(
          idIndexMap[b[KeyNames.post_id]] ?? ids.length,
        ),
      );

      return novelData
          .map(
            (n) => NovelPreviewModel(
              id: n[KeyNames.id],
              title: n[KeyNames.title],
              poster: n[KeyNames.poster],
              banner: n[KeyNames.banner] ?? "",
              description: n[KeyNames.story],
              color: n[KeyNames.color] ?? "0084ff",
            ),
          )
          .toList();
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
        "type": "novel",
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

  Future<List<NovelPreviewModel>> getUserNovels(String userId) async {
    try {
      final data = await _novelsTable
          .select("*")
          .eq(KeyNames.userId, userId)
          .filter(KeyNames.published_at, 'not.is', null)
          .order(KeyNames.published_at, ascending: false);

      return data
          .map(
            (n) => NovelPreviewModel(
              id: n[KeyNames.id],
              title: n[KeyNames.title],
              poster: n[KeyNames.poster],
              banner: n[KeyNames.banner] ?? "",
              description: n[KeyNames.story],
              color: n[KeyNames.color] ?? "0084ff",
            ),
          )
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
