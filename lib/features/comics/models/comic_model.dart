// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/characters/models/comic_characters_model.dart';
import 'package:atlas_app/features/comics/models/comic_published_model.dart';
import 'package:atlas_app/features/comics/models/external_links_model.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

import 'package:atlas_app/features/comics/models/comic_titles_model.dart';
import 'package:atlas_app/features/comics/models/genres_model.dart';

class ComicModel {
  final String comicId;
  final int aniId;
  final String englishTitle;
  final String type;
  final int? chapters;
  final int? volumes;
  final String? banner;
  final String status;
  final double score;
  final String synopsis;
  final List<dynamic> title_synonyms;
  final List<ComicTitlesModel> titles;
  final List<GenresModel> genres;
  final ComicPublishedModel publishedDate;
  final List<ExternalLinksModel>? externalLinks;
  final DateTime? lastUpdateAt;
  final String ar_synopsis;
  final String? color;
  final String image;
  final List<ComicReviewModel>? reviews;
  final List<ComicCharacterModel>? characters;
  ComicModel({
    required this.aniId,
    required this.englishTitle,
    required this.type,
    this.chapters,
    this.lastUpdateAt,
    this.volumes,
    this.banner,
    required this.status,
    required this.score,
    required this.synopsis,
    required this.title_synonyms,
    required this.titles,
    required this.genres,
    this.color,
    required this.comicId,
    required this.publishedDate,
    required this.image,
    required this.ar_synopsis,
    this.externalLinks,
    this.reviews,
    this.characters,
  });

  ComicModel copyWith({
    int? aniId,
    String? type,
    int? chapters,
    int? volumes,
    String? status,
    double? score,
    int? scored_by,
    int? rank,
    String? synopsis,
    String? comicId,
    List<dynamic>? title_synonyms,
    List<ComicTitlesModel>? titles,
    List<GenresModel>? genres,
    ComicPublishedModel? publishedDate,
    String? image,
    String? banner,
    String? englishTitle,
    DateTime? lastUpdateAt,
    String? color,
    String? ar_synopsis,
    List<ExternalLinksModel>? externalLinks,
    List<ComicReviewModel>? reviews,
    List<ComicCharacterModel>? characters,
  }) {
    return ComicModel(
      aniId: aniId ?? this.aniId,
      type: type ?? this.type,
      chapters: chapters ?? this.chapters,
      volumes: volumes ?? this.volumes,
      status: status ?? this.status,
      score: score ?? this.score,
      synopsis: synopsis ?? this.synopsis,
      title_synonyms: title_synonyms ?? this.title_synonyms,
      titles: titles ?? this.titles,
      genres: genres ?? this.genres,
      comicId: comicId ?? this.comicId,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      publishedDate: publishedDate ?? this.publishedDate,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      englishTitle: englishTitle ?? this.englishTitle,
      externalLinks: externalLinks ?? this.externalLinks,
      color: color ?? this.color,
      ar_synopsis: ar_synopsis ?? this.ar_synopsis,
      reviews: reviews ?? this.reviews,
      characters: characters ?? this.characters,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.ani_id: aniId,
      KeyNames.type: type,
      KeyNames.chapters: chapters,
      KeyNames.volumes: volumes,
      KeyNames.status: status,
      KeyNames.score: score,
      KeyNames.synopsis: synopsis,
      KeyNames.title_synonyms: title_synonyms,
      KeyNames.id: comicId,
      KeyNames.title_english: englishTitle,
      KeyNames.theme_color: color,
      KeyNames.banner: banner,
      KeyNames.ar_synopsis: ar_synopsis,
      KeyNames.last_update_at: lastUpdateAt?.toIso8601String(),
      KeyNames.external_links: externalLinks?.map((external) => external.toMap()).toList(),
      // 'titles': titles.map((x) => x.toMap()).toList(),
      // 'genres': genres.map((x) => x.toMap()).toList(),
      KeyNames.image: image,
    };
  }

  factory ComicModel.fromMap(Map<String, dynamic> map) {
    List<GenresModel> genres = [];

    if (map['genres'] != null) {
      genres = List<GenresModel>.from(
        (map['genres']).map<GenresModel>((x) => GenresModel.fromMap(x)),
      );
    } else {
      final comicsGenres = List<Map>.from(map[TableNames.comic_genres]);
      genres = List<GenresModel>.from(
        comicsGenres.map<GenresModel>((x) => GenresModel.fromMap(x[TableNames.genres])),
      );
    }

    return ComicModel(
      comicId: map[KeyNames.id] ?? "",
      aniId: map[KeyNames.ani_id] ?? -1,
      lastUpdateAt:
          map[KeyNames.last_update_at] == null
              ? null
              : DateTime.parse(map[KeyNames.last_update_at]),
      type: map[KeyNames.type] ?? "",
      englishTitle: map[KeyNames.title_english],
      chapters: map[KeyNames.chapters],
      volumes: map[KeyNames.volumes],
      status: map[KeyNames.status] ?? "",
      score: map[KeyNames.score] ?? 0.0,
      characters:
          map[TableNames.comic_characters] == null
              ? []
              : List<Map<String, dynamic>>.from(
                map[TableNames.comic_characters],
              ).map((char) => ComicCharacterModel.fromDB(char)).toList(),
      reviews:
          map[TableNames.comic_reviews] == null
              ? null
              : List<Map<String, dynamic>>.from(
                map[TableNames.comic_reviews],
              ).map((review) => ComicReviewModel.fromMap(review)).toList(),
      color: map[KeyNames.theme_color],
      ar_synopsis: map[KeyNames.ar_synopsis] ?? "",
      externalLinks:
          map[KeyNames.external_links] != null
              ? List<ExternalLinksModel>.from(
                map[KeyNames.external_links].map((link) => ExternalLinksModel.fromMap(link)),
              ).toList()
              : null,
      banner: map[KeyNames.banner],
      publishedDate: ComicPublishedModel.fromMap(
        map['published'] ?? map[TableNames.comic_published_dates][0],
      ),
      synopsis: map[KeyNames.synopsis] ?? "",
      title_synonyms: List<dynamic>.from((map[KeyNames.title_synonyms])),
      titles: List<ComicTitlesModel>.from(
        map['titles'] == null
            ? map[TableNames.comic_titles].map<ComicTitlesModel>((x) => ComicTitlesModel.fromMap(x))
            : map['titles'].map<ComicTitlesModel>((x) => ComicTitlesModel.fromMap(x)),
      ),
      genres: genres,
      image:
          map['images']?['jpg']?['image_url'] ??
          map[KeyNames.image] ??
          map['images']?['jpg']?['large_image_url'] ??
          "",
    );
  }

  @override
  String toString() {
    return 'ComicModel(malId: $aniId, type: $type, chapters: $chapters, volumes: $volumes, status: $status, score: $score,  synopsis: $synopsis, title_synonyms: $title_synonyms, titles: $titles, genres: $genres, image: $image)';
  }

  @override
  bool operator ==(covariant ComicModel other) {
    if (identical(this, other)) return true;

    return other.aniId == aniId &&
        other.type == type &&
        other.chapters == chapters &&
        other.volumes == volumes &&
        other.status == status &&
        other.score == score &&
        other.synopsis == synopsis &&
        listEquals(other.title_synonyms, title_synonyms) &&
        listEquals(other.titles, titles) &&
        listEquals(other.genres, genres) &&
        other.image == image;
  }

  @override
  int get hashCode {
    return aniId.hashCode ^
        type.hashCode ^
        chapters.hashCode ^
        volumes.hashCode ^
        status.hashCode ^
        score.hashCode ^
        synopsis.hashCode ^
        title_synonyms.hashCode ^
        titles.hashCode ^
        genres.hashCode ^
        image.hashCode;
  }
}
