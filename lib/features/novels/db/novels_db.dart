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
  SupabaseQueryBuilder get _novelChaptersTable => _client.from(TableNames.novel_chapters);
  SupabaseQueryBuilder get _draftChaptersTable => _client.from(TableNames.novel_chapter_drafts);

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
      final data = await _novelChaptersTable
          .select("*")
          .order(KeyNames.number, ascending: false)
          .range(startIndex, (startIndex + pageSize - 1));

      return data.map((c) => ChapterModel.fromMap(c)).toList();
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
      await _draftChaptersTable.insert(chapter.toMap());
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
          .update({KeyNames.content: content, KeyNames.title: title})
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
      return data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> publishChapter(ChapterDraftModel draft, ChapterModel chapter) async {
    try {
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
