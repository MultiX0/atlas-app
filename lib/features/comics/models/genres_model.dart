// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/core/common/constants/key_names.dart';

class GenresModel {
  final int id;
  final String type;
  final String name;
  GenresModel({required this.id, required this.type, required this.name});

  GenresModel copyWith({int? id, String? type, String? name}) {
    return GenresModel(id: id ?? this.id, type: type ?? this.type, name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{KeyNames.id: id, KeyNames.type: type, KeyNames.name: name};
  }

  factory GenresModel.fromMap(Map<String, dynamic> map) {
    return GenresModel(
      id: map[KeyNames.id] ?? -1,
      type: map[KeyNames.type] ?? "",
      name: map[KeyNames.name] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory GenresModel.fromJson(String source) =>
      GenresModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'GenresModel(mal_id: $id, type: $type, name: $name)';

  @override
  bool operator ==(covariant GenresModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.type == type && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ name.hashCode;
}
