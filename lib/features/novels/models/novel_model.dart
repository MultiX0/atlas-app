import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

class NovelModel {
  final String id;
  final String title;
  final String synopsis;
  final String poster;
  final String? banner;
  final DateTime? publishedAt;
  final int ageRating;
  final List<NovelsGenreModel> genrese;
  final int favoriteCount;
  final bool isFavorite;
  final int viewsCount;
  final bool isViewed;
  final int postsCount;
  final String userId;
  final UserModel user;
  final Color color;
  NovelModel({
    required this.id,
    required this.title,
    required this.synopsis,
    this.banner,
    required this.publishedAt,
    required this.ageRating,
    required this.genrese,
    required this.favoriteCount,
    required this.isFavorite,
    required this.viewsCount,
    required this.isViewed,
    required this.postsCount,
    required this.user,
    required this.userId,
    required this.color,
    required this.poster,
  });

  NovelModel copyWith({
    String? id,
    String? title,
    String? synopsis,
    String? banner,
    DateTime? publishedAt,
    int? ageRating,
    List<NovelsGenreModel>? genrese,
    int? favoriteCount,
    bool? isFavorite,
    int? viewsCount,
    bool? isViewed,
    int? postsCount,
    String? user_id,
    UserModel? user,
    Color? color,
    String? poster,
  }) {
    return NovelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      banner: banner ?? this.banner,
      publishedAt: publishedAt ?? this.publishedAt,
      ageRating: ageRating ?? this.ageRating,
      genrese: genrese ?? this.genrese,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isFavorite: isFavorite ?? this.isFavorite,
      viewsCount: viewsCount ?? this.viewsCount,
      isViewed: isViewed ?? this.isViewed,
      postsCount: postsCount ?? this.postsCount,
      user: user ?? this.user,
      userId: user_id ?? userId,
      color: color ?? this.color,
      poster: poster ?? this.poster,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'id': id,
  //     'title': title,
  //     'synopsis': synopsis,
  //     'banner': banner,
  //     'publishedAt': publishedAt.millisecondsSinceEpoch,
  //     'ageRating': ageRating,
  //     'genrese': genrese.map((x) => x.toMap()).toList(),
  //     'favoriteCount': favoriteCount,
  //     'isFavorite': isFavorite,
  //     'viewsCount': viewsCount,
  //     'isViewed': isViewed,
  //     'postsCount': postsCount,
  //   };
  // }

  factory NovelModel.fromMap(Map<String, dynamic> map) {
    return NovelModel(
      id: map[KeyNames.id] ?? "",
      title: map[KeyNames.title] ?? "",
      synopsis: map[KeyNames.story] ?? "",
      banner: map[KeyNames.banner] != null ? map[KeyNames.banner] ?? "" : null,
      publishedAt:
          map[KeyNames.published_at] == null ? null : DateTime.parse(map[KeyNames.published_at]),
      ageRating: map['ageRating'] ?? -1,
      genrese:
          map[TableNames.genres] == null
              ? []
              : List.from(
                (map[TableNames.genres] as List).map<NovelsGenreModel>(
                  (x) => NovelsGenreModel.fromMap(x as Map<String, dynamic>),
                ),
              ),
      favoriteCount: map[KeyNames.favorite_count] ?? 0,
      isFavorite: map[KeyNames.is_favorite] ?? false,
      viewsCount: map[KeyNames.view_count] ?? 0,
      isViewed: map[KeyNames.is_viewed] ?? false,
      postsCount: map[KeyNames.mentioned_posts] ?? 0,
      user: UserModel.fromMap(map[KeyNames.user]),
      poster: map[KeyNames.poster] ?? "",
      userId: map[KeyNames.userId] ?? "",
      color:
          map[KeyNames.theme_color] == null
              ? AppColors.primary
              : HexColor(map[KeyNames.theme_color]),
    );
  }
}
