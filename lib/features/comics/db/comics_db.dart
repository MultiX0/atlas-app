import 'dart:developer';
import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/genres_json.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/features/characters/db/characters_db.dart';
import 'package:atlas_app/features/comics/models/comic_published_model.dart';
import 'package:atlas_app/features/comics/models/comic_titles_model.dart';
import 'package:atlas_app/features/comics/models/genres_model.dart';
import 'package:atlas_app/features/search/providers/manhwa_search_state.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
import 'package:atlas_app/features/translate/translate_service.dart';
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
  SupabaseQueryBuilder get _comicReviewsTable => client.from(TableNames.comic_reviews);
  SupabaseQueryBuilder get _comicsView => client.from(ViewNames.comic_details_with_views);
  SupabaseQueryBuilder get _comicsViewsTable => client.from(TableNames.comic_views);

  TranslationService get _translationService => TranslationService();

  SupabaseQueryBuilder get _comicsPublishedDateTable =>
      client.from(TableNames.comic_published_dates);

  static final dio = Dio();

  Future<void> viewComic({required String userId, required String comicId}) async {
    try {
      final currentComic = _ref.read(selectedComicProvider)!;
      await _comicsViewsTable.upsert({KeyNames.userId: userId, KeyNames.comic_id: comicId});
      _ref.read(selectedComicProvider.notifier).state = currentComic.copyWith(
        views: currentComic.views + 1,
        is_viewed: true,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

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

  Future<List<ComicModel>> translateComics(List<ComicModel> comics) async {
    try {
      List<Future<ComicModel>> translationFutures =
          comics.map((comic) async {
            if (comic.ar_synopsis.isEmpty) {
              try {
                final ar_synopsis = await _translationService.translate('en', 'ar', comic.synopsis);
                if (ar_synopsis.trim().toLowerCase().contains("translation failed")) {
                  return comic.copyWith(ar_synopsis: '');
                }
                return comic.copyWith(ar_synopsis: ar_synopsis);
              } catch (e) {
                log(e.toString());
                return comic;
              }
            } else {
              return comic;
            }
          }).toList();

      return await Future.wait(translationFutures);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertComics(List<ComicModel> comics, List<Map<String, dynamic>> characters) async {
    try {
      if (comics.isEmpty) return;
      List<Map<String, dynamic>> _comics = [];

      List<ComicModel> newComics = List.from(comics);

      for (final comic in newComics) {
        // Log the mal_id to see what's happening
        log("Processing comic with ani_id: ${comic.aniId}");

        final map = comic.toMap();
        map[KeyNames.last_update_at] = DateTime.now().toUtc().toIso8601String();
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
      for (final comic in newComics) {
        try {
          await Future.wait([
            insertComicTitles(comic.titles, comic.comicId),
            insertComicsGenres(comic.genres, comic.comicId),
            insertComicsPublishDate(comic.publishedDate, comic.comicId),
            _ref.read(characterDbProvider).handleInsertCharacters(comic, characters),
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

  ComicModel makeIdForComic(ComicModel comic) {
    if (comic.comicId.trim().isNotEmpty) {
      return comic;
    }
    const uuid = Uuid();
    final id = uuid.v4();
    return comic.copyWith(comicId: id);
  }

  Future<void> updateComic(ComicModel comic, List<Map<String, dynamic>> characters) async {
    try {
      Map<String, dynamic> map = comic.toMap();
      map.remove(KeyNames.id);
      if (comic.ar_synopsis.isEmpty) {
        final translated = await translateComics([comic]);
        map[KeyNames.ar_synopsis] = translated.first.ar_synopsis;
      }

      await Future.wait([
        _comicsTable.update(map).eq(KeyNames.ani_id, comic.aniId),
        _ref.read(characterDbProvider).handleInsertCharacters(comic, characters),
      ]);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Main search function that orchestrates the search process
  Future<List<ComicModel>> searchComics(String query, {int limit = 20, bool more = false}) async {
    if (query.isEmpty) return [];
    query = query.trim().toLowerCase();
    try {
      _resetSearchState();

      // Set the search mode at the beginning
      // If more=true, we're doing an API search
      // If more=false, we're doing a local DB search
      _ref.read(searchGlobalProvider.notifier).state = !more;

      // Try to search in local database first (if not explicitly requesting API)
      if (!more) {
        final comicIds = await _searchComicsInLocalDb(query, limit);

        // If we found results in local DB, return them
        if (comicIds.isNotEmpty) {
          return await _fetchComicDetailsFromLocalDb(comicIds);
        }
      }

      // If nothing found locally or more results requested, search using API
      return await _fetchComicsFromExternalApi(query, limit);
    } catch (e) {
      _handleSearchError(e.toString());
      return [];
    }
  }

  // Reset search state before starting a new search
  void _resetSearchState() {
    _ref.read(manhwaSearchStateProvider.notifier).reset();
    _ref.read(manhwaSearchStateProvider.notifier).handleLoading(true);
  }

  // Search for comic IDs in the local database
  Future<List> _searchComicsInLocalDb(String query, int limit) async {
    final comicIds = await _comicsTitlesTable
        .select(KeyNames.comic_id)
        .textSearch(KeyNames.title, query, type: TextSearchType.plain)
        .order(KeyNames.title, ascending: true)
        .limit(limit);

    if (comicIds.isEmpty) return [];
    return (comicIds as List).map((row) => row[KeyNames.comic_id] ?? "").toList();
  }

  // Fetch comics from external API, process and save them
  Future<List<ComicModel>> _fetchComicsFromExternalApi(String query, int limit) async {
    log("our database have 0 results, switch to mal");

    // Fetch from external API
    final data = await searchMalApi(searchQuery: query, limit: limit);

    final characters = extractCharactersFromProcessedComics(data as List<Map<String, dynamic>>);

    final comics = data.map((comic) => ComicModel.fromMap(comic)).toSet().toList();

    final alreadyAvailableIds = await _getIdsOfAvailableData(comics);
    final availableComics = await fetchComicsFromDbByAniId(alreadyAvailableIds);

    // Process comics
    List<ComicModel> idsComics = [];
    for (final c in comics) {
      idsComics.add(makeIdForComic(c));
    }

    // Translate and save comics
    List<ComicModel> finalComics = await translateComics(idsComics);
    for (final c in availableComics) {
      finalComics.removeWhere((com) => com.aniId == c.aniId);
      idsComics.removeWhere((com) => com.aniId == c.aniId);
    }

    finalComics.addAll(availableComics);
    _updateStateAfterApiSearch(finalComics);

    await insertComics(idsComics, characters);

    // Update state

    return comics;
  }

  Future<List<int>> _getIdsOfAvailableData(List<ComicModel> comics) async {
    final _unFoundIds =
        await client.rpc(
              FunctionNames.check_unavailable_comics,
              params: {'p_ani_ids': comics.map((c) => c.aniId).toList()},
            )
            as List;

    List<int> unavailableIds =
        _unFoundIds.map((comic) => comic["unavailable_ani_id"] as int).toList();

    List<ComicModel> newComics = List.from(comics);
    newComics.retainWhere((comic) => !(unavailableIds.contains(comic.aniId)));
    return newComics.map((c) => c.aniId).toList();
  }

  // Update app state after API search
  void _updateStateAfterApiSearch(List<ComicModel> comics) {
    _ref.read(manhwaSearchStateProvider.notifier).updateComics(comics);
    _ref.read(searchGlobalProvider.notifier).state = false; // This should be false for API results
    _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
    _ref.read(manhwaSearchStateProvider.notifier).handleError(null);
  }

  // Fetch detailed comic data from local database using IDs
  Future<List<ComicModel>> _fetchComicDetailsFromLocalDb(List ids) async {
    if (ids.isEmpty) return [];

    final data = await _comicsView.select('*').inFilter('comic_id', ids);

    log("found on our db");

    // IMPORTANT: For local database results, we should set searchGlobalProvider to true
    // This allows the "ألا ترى ما تبحث عنه؟" text to appear
    _ref.read(searchGlobalProvider.notifier).state = true;

    final comics = data.map((comic) => ComicModel.fromMap(comic)).toList();

    // Update state
    _ref.read(manhwaSearchStateProvider.notifier).updateComics(comics);
    _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);

    return comics;
  }

  // Handle search errors
  void _handleSearchError(String errorMessage) {
    _ref.read(manhwaSearchStateProvider.notifier).handleLoading(false);
    _ref.read(manhwaSearchStateProvider.notifier).handleError(errorMessage);
    log(errorMessage);
  }

  Future<List<ComicModel>> fetchComicsFromDbByAniId(List ids) async {
    if (ids.isEmpty) return [];

    final data = await _comicsView.select('*').inFilter(KeyNames.ani_id, ids);

    final comics = data.map((comic) => ComicModel.fromMap(comic)).toList();
    return comics;
  }

  Future<ComicReviewModel?> getComicReview({
    required String userId,
    required String comicId,
  }) async {
    try {
      final data =
          await _comicReviewsTable
              .select("*,${TableNames.users}")
              .eq(KeyNames.userId, userId)
              .eq(KeyNames.comic_id, comicId)
              .maybeSingle();
      if (data == null) return null;
      return ComicReviewModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleUpdateComic(ComicModel comic) async {
    try {
      final now = DateTime.now().toUtc();
      if (comic.lastUpdateAt != null &&
          comic.lastUpdateAt!.add(const Duration(hours: 24)).isAfter(now)) {
        log("next update in ${comic.lastUpdateAt!.add(const Duration(hours: 24))}");
        return;
      }

      final comicData = await getComicById(comic.aniId);
      log(comicData.toString());
      ComicModel comicModel = ComicModel.fromMap(comicData);
      final characters = extractCharactersFromProcessedComics([comicData]);
      comicModel = comicModel.copyWith(
        lastUpdateAt: DateTime.now().toUtc(),
        comicId: comic.comicId,
        ar_synopsis: comic.ar_synopsis,
        characters: comic.characters,
        genres: comic.genres,
        views: comic.views,
        is_viewed: comic.is_viewed,
        favorite_count: comic.favorite_count,
        posts_count: comic.posts_count,
        user_favorite: comic.user_favorite,
      );
      log("updating { ${comicModel.aniId} } ...");
      _ref.read(manhwaSearchStateProvider.notifier).updateSpecificComic(comicModel);
      await updateComic(comicModel, characters);
    } catch (e) {
      log(e.toString());
      rethrow;
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
characters {
  edges {
    role
    node {
      id
      name {
        full
        native
        alternative
      }
      image {
        large
        medium
      }
      gender
      dateOfBirth {
        year
        month
        day
      }
      age
      bloodType
      description(asHtml: true)
      siteUrl
    }
  }
}
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

  Future<Map<String, dynamic>> getComicById(int id) async {
    const String query = '''
    query GetMangaById(\$id: Int) {
      Media(id: \$id, type: MANGA) {
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
characters {
  edges {
    role
    node {
      id
      name {
        full
        native
        alternative
      }
      image {
        large
        medium
      }
      gender
      dateOfBirth {
        year
        month
        day
      }
      age
      bloodType
      description(asHtml: true)
      siteUrl
    }
  }
}

      }
    }
  ''';

    final variables = {'id': id};

    try {
      final res = await dio.post(aniListAPI, data: {'query': query, 'variables': variables});

      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        final media = res.data["data"]["Media"];
        final comicMap = Map<String, dynamic>.from(media);
        final comicMapFixed = filterComics([comicMap]);
        return comicMapFixed.first;
      }

      throw DioException(requestOptions: res.requestOptions);
    } catch (e) {
      log("Error fetching manga by ID: $e");
      rethrow;
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
        final characters = extractCharactersFromApi(comic);
        final tags = extractTagsFromApi(comic);
        final genres = extractGenresFromApi(comic);

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
          "tags": tags,
          "members": null,
          "favorites": null,
          "synopsis": _stripHtmlTags(comic["description"]),
          "background": "",
          "authors": [],
          "serializations": [],
          "genres": genres,
          KeyNames.theme_color: comic["coverImage"]["color"],
          "explicit_genres": [],
          "themes": _extractThemes(comic["tags"]),
          "demographics": [],
          "characters": characters,
        };

        unique.add(convertedComic);
      }
    }

    return unique;
  }

  List<Map<String, dynamic>> extractGenresFromApi(Map<dynamic, dynamic> comic) {
    try {
      final genreMap = {
        for (var genre in genres) genre["name"].toString().toLowerCase(): genre["id"],
      };

      final comicGenres = (comic["genres"] as List<dynamic>);
      if (comicGenres.isEmpty) return [];

      log(genreMap.toString());
      log("=========================");
      log(comicGenres.toString());
      log("=========================");

      List<Map<String, dynamic>> _enrichedGenres = [];
      for (final g in (comic["genres"] as List<dynamic>)) {
        final genreName = g.toString().toLowerCase();
        final genreId = genreMap[genreName];
        if (genreId == null || (g == null || g.toString().isEmpty)) continue;
        final gen = {
          "id": genreId,
          "type": "manga",
          "name": g,
          "url": "https://myanimelist.net/manga/genre/0/$g",
        };
        _enrichedGenres.add(gen);
      }

      return _enrichedGenres;
    } catch (e) {
      log("Exception in extractGenresFrom Api $e");
      rethrow;
    }
  }

  List<String> extractTagsFromApi(Map<dynamic, dynamic> comic) {
    final List<Map<String, dynamic>> tags = List.from(comic['tags']);
    return tags.map((tag) => tag["name"].toString().trim().toLowerCase()).toList();
  }

  List<Map<String, dynamic>> extractCharactersFromApi(Map<dynamic, dynamic> comic) {
    final characters =
        List<Map<String, dynamic>>.from(comic["characters"]["edges"]).map((c) {
          final node = c["node"];
          return {
            "role": c["role"],
            "character": {
              "id": node["id"],
              "full_name": node["name"]["full"],
              "alternative_names": List<String>.from(node["name"]["alternative"] ?? []),
              "gender": node["gender"],
              "age": node["age"],
              "blood_type": node["bloodType"],
              "description": _stripHtmlTags(node["description"]),
              "image": node["image"]?["large"] ?? node["image"]?["medium"],
              "birth_year": node["dateOfBirth"]["year"],
              "birth_month": node["dateOfBirth"]["month"],
              "birth_day": node["dateOfBirth"]["day"],
            },
          };
        }).toList();
    return characters;
  }

  List<Map<String, dynamic>> extractCharactersFromProcessedComics(
    List<Map<String, dynamic>> processedComics,
  ) {
    List<Map<String, dynamic>> _data = [];
    for (final comic in processedComics) {
      final List<Map<String, dynamic>> characters = comic["characters"];
      _data.add({"comic_ani_id": comic["ani_id"], "characters": characters});
    }
    return _data;
  }

  List<Map<String, dynamic>> extractCharactersFromDBComics(List<ComicModel> comics) {
    List<Map<String, dynamic>> _data = [];
    List<Map<String, dynamic>> _characters = [];
    for (final comic in comics) {
      _characters.clear();
      final comicCharacters = comic.characters ?? [];
      if (comicCharacters.isEmpty) continue;
      for (final comicCharacter in comicCharacters) {
        // log("${comicCharacter.character?.fullName}");

        _characters.add(comicCharacter.character!.toJson());
      }
      _data.add({"comic_ani_id": comic.aniId, "characters": _characters});
    }

    return _data;
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
}
