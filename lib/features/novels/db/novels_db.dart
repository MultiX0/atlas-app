import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

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

  Future<void> deleteChapter(String chapterId) async {
    try {
      await _novelChaptersTable.delete().eq(KeyNames.id, chapterId);
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

  Future<void> insertNewDraft(ChapterDraftModel draft) async {
    try {
      await _draftChaptersTable.insert(draft.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNewChapter(ChapterModel chapter) async {
    try {
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
      await Future.wait([deleteDraft(draft), insertNewChapter(chapter)]);
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
      final data =
          genres.map((g) => {KeyNames.genre_id: g.id, KeyNames.novel_id: novelId}).toList();
      await _novelsGenresTable.insert(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertNovel(Map<String, dynamic> data) async {
    try {
      await _novelsTable.insert(data);
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
}
