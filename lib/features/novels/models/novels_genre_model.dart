import 'package:atlas_app/imports.dart';

class NovelsGenreModel {
  final int id;
  final String name;
  final String description;
  NovelsGenreModel({required this.id, required this.name, required this.description});

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{'id': id, 'name': name, 'description': description};
  // }

  factory NovelsGenreModel.fromMap(Map<String, dynamic> map) {
    return NovelsGenreModel(
      id: map[KeyNames.id] ?? -1,
      name: map[KeyNames.name_ar] ?? "",
      description: map[KeyNames.description_ar] ?? "",
    );
  }

  NovelsGenreModel copyWith({int? id, String? name, String? description}) {
    return NovelsGenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
