import 'package:atlas_app/imports.dart';

class CharacterPreviewModel {
  final String id;
  final String name;
  final String poster;
  CharacterPreviewModel({required this.id, required this.name, required this.poster});

  CharacterPreviewModel copyWith({String? id, String? name, String? poster}) {
    return CharacterPreviewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      poster: poster ?? this.poster,
    );
  }

  factory CharacterPreviewModel.fromMap(Map<String, dynamic> map) {
    return CharacterPreviewModel(
      id: map[KeyNames.entity_id] ?? "",
      name: map[KeyNames.fullName] ?? "",
      poster: map[KeyNames.poster] ?? "",
    );
  }

  @override
  String toString() => 'CharacterPreviewModel(id: $id, name: $name, poster: $poster)';

  @override
  bool operator ==(covariant CharacterPreviewModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.poster == poster;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ poster.hashCode;
}
