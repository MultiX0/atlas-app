import 'package:atlas_app/imports.dart';

class ComicPreviewModel {
  final String id;
  final String title;
  final String poster;
  final String banner;
  ComicPreviewModel({
    required this.id,
    required this.title,
    required this.poster,
    required this.banner,
  });

  ComicPreviewModel copyWith({String? id, String? title, String? poster, String? banner}) {
    return ComicPreviewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      banner: banner ?? this.banner,
    );
  }

  factory ComicPreviewModel.fromMap(Map<String, dynamic> map) {
    return ComicPreviewModel(
      id: map[KeyNames.entity_id] ?? "",
      title: map[KeyNames.title] ?? "",
      poster: map[KeyNames.poster] ?? "",
      banner: map[KeyNames.banner] ?? "",
    );
  }

  @override
  String toString() {
    return 'ComicPreviewModel(id: $id, title: $title, poster: $poster, banner: $banner)';
  }

  @override
  bool operator ==(covariant ComicPreviewModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.poster == poster &&
        other.banner == banner;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ poster.hashCode ^ banner.hashCode;
  }
}
