import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
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

  Future<void> handleAddNewChapterCommentReply(NovelChapterCommentReplyWithLikes reply) async {
    try {
      await _novelChapterCommentRepliesTable.insert({
        KeyNames.id: reply.id,
        KeyNames.userId: reply.userId,
        KeyNames.content: reply.content,
        KeyNames.parent_comment_author_id: reply.parentCommentAuthorId,
        KeyNames.comment_id: reply.commentId,
      });
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

  Future<void> handleFavorite(NovelModel novel) async {
    try {
      await _client.rpc(FunctionNames.toggle_favorite_novel, params: {'p_novel_id': novel.id});
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

  Future<void> handleChapterLike(ChapterModel chapter) async {
    try {
      await _client.rpc(FunctionNames.toggle_chapter_like, params: {'p_chapter_id': chapter.id});
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
    required String userId,
  }) async {
    try {
      await _novelChapterCommentsTable.insert({
        KeyNames.content: content,
        KeyNames.id: commentId,
        KeyNames.userId: userId,
        KeyNames.chapter_id: chapterId,
      });
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

  Future<void> handleChapterCommentReplyLike(String replyId) async {
    try {
      await _client.rpc(
        FunctionNames.toggle_chapter_comment_reply_like,
        params: {'p_reply_id': replyId},
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> publishNovel(String novelId) async {
    try {
      await _novelsTable.update({KeyNames.novel_id: novelId}).eq(KeyNames.id, novelId);
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
      await _draftChaptersTable.delete().eq(KeyNames.id, draft.id);
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

  Future<void> deleteNovelGenreses(List<int> ids, String novelId) async {
    try {
      await _novelsGenresTable
          .delete()
          .eq(KeyNames.novel_id, novelId)
          .inFilter(KeyNames.genre_id, ids);
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
      final authHeaders = await generateAuthHeaders();
      await _dio.post(
        '${appAPI}update-user-embedding?user_id=${data[KeyNames.userId]}',
        options: Options(headers: authHeaders),
      );
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
      List<NovelsGenreModel> oldOnlyGenres =
          oldGenreses.where((oldGenre) {
            return !genres.any((newGenre) => newGenre.id == oldGenre.id);
          }).toList();

      List<NovelsGenreModel> newOnlyGenres =
          genres.where((newGenre) {
            return !oldGenreses.any((oldGenre) => oldGenre.id == oldGenre.id);
          }).toList();

      await deleteNovelGenreses(oldOnlyGenres.map((g) => g.id).toList(), id);

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
      await insertNovelGenreses(newOnlyGenres, id);
      return newOnlyGenres;
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
      novelData.toString();
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
