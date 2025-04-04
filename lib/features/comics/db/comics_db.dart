import 'dart:developer';
import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/genres_json.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/models/comic_published_model.dart';
import 'package:atlas_app/features/comics/models/comic_titles_model.dart';
import 'package:atlas_app/features/comics/models/genres_model.dart';
import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
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
      await _comicsTitlesTable.upsert(_titles, onConflict: KeyNames.title, ignoreDuplicates: true);
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
        final id = genres.id;
        map[KeyNames.genre_id] = id;
        map.remove(KeyNames.type);
        map.remove(KeyNames.id);
        map.remove(KeyNames.name);
        _genress.add(map);
      }
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
      final _unFoundIds =
          await client.rpc(
                FunctionNames.check_unavailable_comics,
                params: {'p_ani_ids': comics.map((c) => c.aniId).toList()},
              )
              as List;

      List<int> unavailableIds =
          _unFoundIds.map((comic) => comic["unavailable_ani_id"] as int).toList();

      List<ComicModel> newComics = List.from(comics);
      newComics.retainWhere((comic) => unavailableIds.contains(comic.aniId));

      for (final comic in newComics) {
        // Log the mal_id to see what's happening
        log("Processing comic with ani_id: ${comic.aniId}");

        final map = comic.toMap();
        final id = uuid.v4();
        map[KeyNames.id] = id;

        _ids[comic.aniId] = id;
        _comics.add(map);
      }

      // Debug: print the prepared data
      log("Comics to insert: ${_comics.length}");

      // Try inserting one by one to identify which one causes the issue
      for (var comicMap in _comics) {
        try {
          await _comicsTable.upsert(comicMap);
        } catch (e) {
          log("Error on comic with mal_id: ${comicMap[KeyNames.ani_id]}");
          log(e.toString());
          continue;
        }
      }

      // Now handle related data
      for (final comic in comics) {
        try {
          final id = _ids[comic.aniId]!;
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

  Future<List<ComicModel>> searchComics(String query, {int limit = 20, more = false}) async {
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

      if (comicIds.isEmpty || more) {
        log("our database have 0 results, switch to mal");
        final data = await searchMalApi(searchQuery: query, limit: limit);
        final comics =
            data.map((comic) => ComicModel.fromMap(comic as Map<String, dynamic>)).toSet().toList();
        _ref.read(manhwaSearchStateProvider.notifier).updateComics(comics);
        _ref.read(searchGlobalProvider.notifier).state = false;
        _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
        _ref.read(manhwaSearchStateProvider.notifier).handleError(null);
        await insertComics(comics);
        return comics;
      }

      _ref.read(searchGlobalProvider.notifier).state = true;
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

      final _data = data.map((comic) => ComicModel.fromMap(comic)).toList();
      _ref.read(manhwaSearchStateProvider.notifier).updateComics(_data);
      _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
      return _data;
    } catch (e) {
      _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
      _ref.read(manhwaSearchStateProvider.notifier).handleError(e.toString());
      log(e.toString());
      return [];
    }
  }

  Future<List<Map>> searchMalApi({required String searchQuery, int limit = 25}) async {
    const String query = '''
  query SearchManga(\$search: String, \$limit: Int) {
    Page(page: 1, perPage: \$limit) {
      media(search: \$search, type: MANGA) {
        id
        title {
          romaji
          english
          native
        }
        status
        format
        description
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        season
        seasonYear
        episodes
        chapters
        volumes
        genres
        synonyms
        isAdult
        averageScore
        popularity
        tags {
          name
          description
        }
        studios {
          edges {
            node {
              id
              name
            }
          }
        }
        externalLinks {
          url
          site
        }
        coverImage {
          extraLarge
          large
          medium
          color
        }
        bannerImage
      }
    }
  }
''';

    final variables = {'search': searchQuery, 'limit': limit};

    try {
      final res = await dio.post(aniListAPI, data: {'query': query, 'variables': variables});
      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        final data = List<Map<dynamic, dynamic>>.from(res.data["data"]["Page"]["media"]);
        final _data = filterComics(data);
        return _data;
      }
      throw DioException(requestOptions: res.requestOptions);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

List<Map<String, dynamic>> filterComics(List<Map<dynamic, dynamic>> data) {
  final seenIds = <dynamic>{};
  final unique = <Map<String, dynamic>>[];
  final _data = data.where((d) => d["isAdult"] == false).toList();

  for (final comic in _data) {
    final aniId = comic["id"];
    if (!seenIds.contains(aniId)) {
      seenIds.add(aniId);

      final genreMap = {
        for (var genre in genres) genre["name"].toString().toLowerCase(): genre["id"],
      };

      final enrichedGenres =
          (comic["genres"] as List<dynamic>)
              .map((g) {
                final genreName = g.toString().toLowerCase();
                final genreId = genreMap[genreName];

                if (genreId == null) return null;

                return {
                  "id": genreId,
                  "type": "manga",
                  "name": g,
                  "url": "https://myanimelist.net/manga/genre/0/$g",
                };
              })
              .nonNulls
              .toList();

      final convertedComic = {
        KeyNames.ani_id: aniId,
        "banner": comic["bannerImage"],
        "external_links": comic["externalLinks"] ?? [],
        "images": {
          "jpg": {
            "image_url": comic["coverImage"]["extraLarge"],
            "small_image_url": comic["coverImage"]["medium"],
            "large_image_url": comic["coverImage"]["large"],
          },
          "webp": {
            "image_url": comic["coverImage"]["extraLarge"],
            "small_image_url": comic["coverImage"]["medium"],
            "large_image_url": comic["coverImage"]["large"],
          },
        },
        "approved": true,
        "titles": [
          {"type": "Default", "title": comic["title"]["romaji"]},
          if (comic["title"]["native"] != null)
            {"type": "Japanese", "title": comic["title"]["native"]},
          if (comic["title"]["english"] != null)
            {"type": "English", "title": comic["title"]["english"]},
        ],
        "title_english": comic["title"]?["english"] ?? comic["title"]["romaji"],
        "title_synonyms": comic["synonyms"] ?? [],
        "type": comic["format"],
        "chapters": comic["chapters"],
        "volumes": comic["volumes"],
        "status": comic["status"],
        "publishing": comic["status"] != "FINISHED",
        "published": {
          "from": _formatDate(comic["startDate"]),
          "to": _formatDate(comic["endDate"]),
          "prop": {"from": comic["startDate"], "to": comic["endDate"]},
          "string": _dateRangeToString(comic["startDate"], comic["endDate"]),
        },
        "score": comic["averageScore"] != null ? comic["averageScore"] / 10.0 : null,
        "scored": null,
        "scored_by": null,
        "rank": null,
        "popularity": comic["popularity"],
        "members": null,
        "favorites": null,
        "synopsis": _stripHtmlTags(comic["description"]),
        "background": "",
        "authors": [],
        "serializations": [],
        "genres": enrichedGenres,
        "explicit_genres": [],
        "themes": _extractThemes(comic["tags"]),
        "demographics": [],
      };

      unique.add(convertedComic);
    }
  }

  return unique;
}

String? _formatDate(Map<String, dynamic>? date) {
  if (date == null || date["year"] == null) return null;

  final year = date["year"].toString().padLeft(4, '0');
  final month = (date["month"] ?? 1).toString().padLeft(2, '0');
  final day = (date["day"] ?? 1).toString().padLeft(2, '0');
  return "$year-$month-${day}T00:00:00+00:00";
}

String _dateRangeToString(Map<String, dynamic>? from, Map<String, dynamic>? to) {
  String format(Map<String, dynamic>? d) {
    if (d == null || d["year"] == null) return "Unknown";
    return "${_monthName(d["month"] ?? 1)} ${d["day"] ?? 1}, ${d["year"]}";
  }

  return "${format(from)} to ${format(to)}";
}

String _monthName(int month) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[month];
}

String _stripHtmlTags(String? htmlText) {
  if (htmlText == null) return "";
  final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '').trim();
}

List<Map<String, dynamic>> _extractThemes(List<dynamic>? tags) {
  if (tags == null) return [];

  final themeTags = [
    "Time Manipulation",
    "Revenge",
    "Time Skip",
    "Age Regression",
    "Dungeon",
    "Gods",
    "Magic",
    "Demons",
    "Video Games",
    "Surreal Comedy",
    "Female Harem",
  ];

  return tags
      .where((tag) => themeTags.contains(tag["name"]))
      .map(
        (tag) => {
          "mal_id": null,
          "type": "manga",
          "name": tag["name"],
          "url":
              "https://myanimelist.net/manga/genre/0/${tag["name"].toString().replaceAll(' ', '_')}",
        },
      )
      .toList();
}
