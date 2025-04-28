import 'package:atlas_app/imports.dart';

class NovelPreviewModel {
  final String id;
  final String title;
  final String poster;
  final String banner;
  final String description;
  final String color;
  NovelPreviewModel({
    required this.id,
    required this.title,
    this.color = "0084ff",
    required this.poster,
    required this.banner,
    required this.description,
  });

  NovelPreviewModel copyWith({
    String? id,
    String? title,
    String? poster,
    String? banner,
    String? description,
    String? color,
  }) {
    return NovelPreviewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      banner: banner ?? this.banner,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'title': title, 'poster': poster, 'banner': banner};
  }

  factory NovelPreviewModel.fromMap(Map<String, dynamic> map) {
    return NovelPreviewModel(
      id: map[KeyNames.entity_id] ?? "",
      title: map[KeyNames.title] ?? '',
      poster: map[KeyNames.poster] ?? "",
      banner: map[KeyNames.banner] ?? "",
      description: map[KeyNames.story] ?? "",
    );
  }

  @override
  String toString() {
    return 'NovelPreviewModel(id: $id, title: $title, poster: $poster, banner: $banner)';
  }

  @override
  bool operator ==(covariant NovelPreviewModel other) {
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
