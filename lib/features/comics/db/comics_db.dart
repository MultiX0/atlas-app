import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/models/comic_published_model.dart';
import 'package:atlas_app/features/comics/models/comic_titles_model.dart';
import 'package:atlas_app/features/comics/models/genres_model.dart';
import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

final comicsDBProvider = Provider<ComicsDb>((ref) {
  return ComicsDb(ref: ref);
});

class ComicsDb {
  final Ref _ref;

  ComicsDb({required Ref ref}) : _ref = ref;

  final client = Supabase.instance.client;
  SupabaseQueryBuilder get _comicsTable => client.from(TableNames.comics);
  SupabaseQueryBuilder get _comicsTitlesTable => client.from(TableNames.comic_titles);
  SupabaseQueryBuilder get _comicsGenresTable => client.from(TableNames.comic_genres);

  SupabaseQueryBuilder get _comicsPublishedDateTable =>
      client.from(TableNames.comic_published_dates);

  static final dio = Dio();

  Future<void> insertComicsPublishDate(ComicPublishedModel date, String comicId) async {
    try {
      await _comicsPublishedDateTable.upsert({
        KeyNames.from: date.from?.toIso8601String(),
        KeyNames.to: date.to?.toIso8601String(),
        KeyNames.string: date.string,
        KeyNames.comic_id: comicId,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertComicTitles(List<ComicTitlesModel> titles, String comicId) async {
    try {
      List<Map<String, dynamic>> _titles = [];
      for (final title in titles) {
        final map = title.toMap();
        map[KeyNames.comic_id] = comicId;
        _titles.add(map);
      }
      // Use _titles instead of titles
      await _comicsTitlesTable.upsert(_titles);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertComicsGenres(List<GenresModel> genress, String comicId) async {
    try {
      List<Map<String, dynamic>> _genress = [];
      for (final genres in genress) {
        final map = genres.toMap();
        map[KeyNames.comic_id] = comicId;
        final id = genres.mal_id;
        map.remove(KeyNames.mal_id);
        map[KeyNames.genre_id] = id;
        map.remove(KeyNames.type);
        map.remove(KeyNames.name);
        _genress.add(map);
      }
      // Use _genress instead of genress
      await _comicsGenresTable.upsert(_genress);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertComics(List<ComicModel> comics) async {
    try {
      const uuid = Uuid();
      Map<int, String> _ids = {};
      List<Map<String, dynamic>> _comics = [];

      for (final comic in comics) {
        // Log the mal_id to see what's happening
        log("Processing comic with mal_id: ${comic.malId}");

        final map = comic.toMap();
        final id = uuid.v4();
        map[KeyNames.id] = id;

        // Make sure mal_id is included in the map with the correct key name
        map[KeyNames.mal_id] = comic.malId;

        _ids[comic.malId] = id;
        _comics.add(map);
      }

      // Debug: print the prepared data
      log("Comics to insert: ${_comics.length}");

      // Try inserting one by one to identify which one causes the issue
      for (var comicMap in _comics) {
        try {
          await _comicsTable.upsert([comicMap], onConflict: KeyNames.mal_id);
        } catch (e) {
          log("Error on comic with mal_id: ${comicMap[KeyNames.mal_id]}");
          log(e.toString());
          continue;
        }
      }

      // Now handle related data
      for (final comic in comics) {
        try {
          final id = _ids[comic.malId]!;
          await Future.wait([
            insertComicTitles(comic.titles, id),
            insertComicsGenres(comic.genres, id),
            insertComicsPublishDate(comic.publishedDate, id),
          ]);
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<ComicModel>> searchComics(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];
    query = query.trim().toLowerCase();

    try {
      _ref.read(manhwaSearchStateProvider.notifier).reset();
      _ref.read(manhwaSearchStateProvider.notifier).handleLoading(true);
      final comicIds = await _comicsTitlesTable
          .select(KeyNames.comic_id)
          .ilike(KeyNames.title, "%$query%")
          .order(KeyNames.title, ascending: true)
          .limit(limit);

      log(comicIds.toString());
      if (comicIds.isEmpty) {
        log("our database have 0 results, switch to mal");
        final data = await searchMalApi(query: query);
        final comics =
            data.map((comic) => ComicModel.fromMap(comic as Map<String, dynamic>)).toSet().toList();
        _ref.read(manhwaSearchStateProvider.notifier).updateComics(comics);
        _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
        await insertComics(comics);
        return comics;
      }

      final ids = (comicIds as List).map((row) => row[KeyNames.comic_id] ?? "").toList();
      if (ids.isEmpty) return [];
      final data = await _comicsTable
          .select('''
            *,
            ${TableNames.comic_titles} (*),
            ${TableNames.comic_published_dates} (*),
            ${TableNames.comic_genres} (
              ${TableNames.genres} (*)
            )
          ''')
          .inFilter('id', ids);

      log("found on our db");
      // log(data.first.toString());

      final _data = data.map((comic) => ComicModel.fromMap(comic)).toList();
      log(_data.length.toString());
      _ref.read(manhwaSearchStateProvider.notifier).updateComics(_data);
      _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
      return _data;
    } catch (e) {
      _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
      _ref.read(manhwaSearchStateProvider.notifier).handleError("please try again later");

      log(e.toString());
      return [];
    }
  }

  Future<List<Map>> searchMalApi({required String query, int limit = 25}) async {
    try {
      final res = await dio.get('$malAPI?q=$query &limit=$limit&sfw=false');
      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        final data = List<Map<dynamic, dynamic>>.from(res.data["data"]);
        // log(data.toString());
        final _data = filterComics(data);

        return _data;
      }
      throw DioException(requestOptions: res.requestOptions);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  List<Map<dynamic, dynamic>> filterComics(List<Map<dynamic, dynamic>> data) {
    final filtered =
        data
            .where(
              (comic) =>
                  (comic["type"].toString().toLowerCase() == "manga" ||
                      comic["type"].toString().toLowerCase() == "manhwa" ||
                      comic["type"].toString().toLowerCase() == "manhua"),
            )
            .where((comic) {
              final genres = List<Map<dynamic, dynamic>>.from(comic["genres"]);
              final lowerGenres = genres.map((g) => g["name"].toString().toLowerCase()).toList();
              return !lowerGenres.contains("hentai") &&
                  !lowerGenres.contains("boys love") &&
                  !lowerGenres.contains("girls love");
            })
            .toList();

    final seenIds = <dynamic>{};
    final unique = <Map<dynamic, dynamic>>[];

    for (final comic in filtered) {
      final malId = comic["mal_id"];
      if (!seenIds.contains(malId)) {
        seenIds.add(malId);
        unique.add(comic);
      }
    }

    return unique;
  }
}
