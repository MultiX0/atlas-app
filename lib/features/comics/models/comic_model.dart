// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/comics/models/comic_published_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

import 'package:atlas_app/features/comics/models/comic_titles_model.dart';
import 'package:atlas_app/features/comics/models/genres_model.dart';

class ComicModel {
  final String comicId;
  final int malId;
  final String type;
  final int? chapters;
  final int? volumes;
  final String status;
  final double score;
  final int scored_by;
  final int rank;
  final String synopsis;
  final List<dynamic> title_synonyms;
  final List<ComicTitlesModel> titles;
  final List<GenresModel> genres;
  final ComicPublishedModel publishedDate;
  final String image;
  ComicModel({
    required this.malId,
    required this.type,
    this.chapters,
    this.volumes,
    required this.status,
    required this.score,
    required this.scored_by,
    required this.rank,
    required this.synopsis,
    required this.title_synonyms,
    required this.titles,
    required this.genres,
    required this.comicId,
    required this.publishedDate,
    required this.image,
  });

  ComicModel copyWith({
    int? malId,
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
  }) {
    return ComicModel(
      malId: malId ?? this.malId,
      type: type ?? this.type,
      chapters: chapters ?? this.chapters,
      volumes: volumes ?? this.volumes,
      status: status ?? this.status,
      score: score ?? this.score,
      scored_by: scored_by ?? this.scored_by,
      rank: rank ?? this.rank,
      synopsis: synopsis ?? this.synopsis,
      title_synonyms: title_synonyms ?? this.title_synonyms,
      titles: titles ?? this.titles,
      genres: genres ?? this.genres,
      comicId: comicId ?? this.comicId,
      publishedDate: publishedDate ?? this.publishedDate,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.mal_id: malId,
      KeyNames.type: type,
      KeyNames.chapters: chapters,
      KeyNames.volumes: volumes,
      KeyNames.status: status,
      KeyNames.score: score,
      KeyNames.scored_by: scored_by,
      KeyNames.rank: rank,
      KeyNames.synopsis: synopsis,
      KeyNames.title_synonyms: title_synonyms,
      KeyNames.id: comicId,
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
      malId: map[KeyNames.mal_id] ?? -1,
      type: map[KeyNames.type] ?? "",
      chapters: map[KeyNames.chapters],
      volumes: map[KeyNames.volumes],
      status: map[KeyNames.status] ?? "",
      score: map[KeyNames.score] ?? 0.0,
      scored_by: map[KeyNames.scored_by] ?? 0,
      rank: map[KeyNames.rank] ?? 0,
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
    return 'ComicModel(malId: $malId, type: $type, chapters: $chapters, volumes: $volumes, status: $status, score: $score, scored_by: $scored_by, rank: $rank, synopsis: $synopsis, title_synonyms: $title_synonyms, titles: $titles, genres: $genres, image: $image)';
  }

  @override
  bool operator ==(covariant ComicModel other) {
    if (identical(this, other)) return true;

    return other.malId == malId &&
        other.type == type &&
        other.chapters == chapters &&
        other.volumes == volumes &&
        other.status == status &&
        other.score == score &&
        other.scored_by == scored_by &&
        other.rank == rank &&
        other.synopsis == synopsis &&
        listEquals(other.title_synonyms, title_synonyms) &&
        listEquals(other.titles, titles) &&
        listEquals(other.genres, genres) &&
        other.image == image;
  }

  @override
  int get hashCode {
    return malId.hashCode ^
        type.hashCode ^
        chapters.hashCode ^
        volumes.hashCode ^
        status.hashCode ^
        score.hashCode ^
        scored_by.hashCode ^
        rank.hashCode ^
        synopsis.hashCode ^
        title_synonyms.hashCode ^
        titles.hashCode ^
        genres.hashCode ^
        image.hashCode;
  }
}
