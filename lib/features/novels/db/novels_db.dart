import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

final novelDbProvider = Provider<NovelsDb>((ref) {
  return NovelsDb();
});

class NovelsDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _novelsGenresesData => _client.from(TableNames.novels_genreses_data);
  // SupabaseQueryBuilder get _novelsGenresTable => _client.from(TableNames.novel_genres);

  Future<List<NovelsGenreModel>> getNovelsGenreses() async {
    try {
      final data = await _novelsGenresesData.select("*");
      return data.map((mapData) => NovelsGenreModel.fromMap(mapData)).toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
