import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

final novelDbProvider = Provider<NovelsDb>((ref) {
  return NovelsDb();
});

class NovelsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _novelsGenresesData => _client.from(TableNames.novels_genreses_data);
  SupabaseQueryBuilder get _novelsGenresTable => _client.from(TableNames.novel_genres);
  SupabaseQueryBuilder get _novelsTable => _client.from(TableNames.novels);
  SupabaseQueryBuilder get _novelsView => _client.from(ViewNames.novels_details);

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
