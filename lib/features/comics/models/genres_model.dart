// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GenresModel {
  final int mal_id;
  final String type;
  final String name;
  GenresModel({required this.mal_id, required this.type, required this.name});

  GenresModel copyWith({int? mal_id, String? type, String? name}) {
    return GenresModel(
      mal_id: mal_id ?? this.mal_id,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'mal_id': mal_id, 'type': type, 'name': name};
  }

  factory GenresModel.fromMap(Map<String, dynamic> map) {
    return GenresModel(
      mal_id: map['mal_id'] ?? -1,
      type: map['type'] ?? "",
      name: map['name'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory GenresModel.fromJson(String source) =>
      GenresModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'GenresModel(mal_id: $mal_id, type: $type, name: $name)';

  @override
  bool operator ==(covariant GenresModel other) {
    if (identical(this, other)) return true;

    return other.mal_id == mal_id && other.type == type && other.name == name;
  }

  @override
  int get hashCode => mal_id.hashCode ^ type.hashCode ^ name.hashCode;
}
