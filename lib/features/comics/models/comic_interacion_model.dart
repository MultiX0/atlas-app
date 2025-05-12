// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class ComicInteracionModel {
  final String id;
  final String userId;
  final String comicId;
  final bool liked;
  final bool shared;
  final bool favorite;
  ComicInteracionModel({
    required this.id,
    required this.userId,
    required this.comicId,
    required this.liked,
    required this.shared,
    required this.favorite,
  });

  ComicInteracionModel copyWith({
    String? id,
    String? userId,
    String? comicId,
    bool? liked,
    bool? shared,
    bool? favorite,
  }) {
    return ComicInteracionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      comicId: comicId ?? this.comicId,
      liked: liked ?? this.liked,
      shared: shared ?? this.shared,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.userId: userId,
      KeyNames.comic_id: comicId,
      KeyNames.liked: liked,
      KeyNames.shared: shared,
      KeyNames.favorited: favorite,
    };
  }

  factory ComicInteracionModel.fromMap(Map<String, dynamic> map) {
    return ComicInteracionModel(
      id: map[KeyNames.id] ?? "",
      userId: map[KeyNames.userId] ?? "",
      comicId: map[KeyNames.comic_id] ?? "",
      liked: map[KeyNames.liked] ?? false,
      shared: map[KeyNames.shared] ?? false,
      favorite: map[KeyNames.favorited] ?? false,
    );
  }

  @override
  String toString() {
    return 'ComicInteracionModel(id: $id, userId: $userId, comicId: $comicId, liked: $liked, shared: $shared, favorite: $favorite)';
  }
}
