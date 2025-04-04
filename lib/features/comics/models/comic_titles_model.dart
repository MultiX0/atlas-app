// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ComicTitlesModel {
  final String type;
  final String title;
  ComicTitlesModel({required this.type, required this.title});

  ComicTitlesModel copyWith({String? type, String? title}) {
    return ComicTitlesModel(type: type ?? this.type, title: title ?? this.title);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'type': type, 'title': title};
  }

  factory ComicTitlesModel.fromMap(Map<String, dynamic> map) {
    return ComicTitlesModel(type: map['type'] ?? "", title: map['title'] ?? "");
  }

  String toJson() => json.encode(toMap());

  factory ComicTitlesModel.fromJson(String source) =>
      ComicTitlesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ComicTitlesModel(type: $type, title: $title)';

  @override
  bool operator ==(covariant ComicTitlesModel other) {
    if (identical(this, other)) return true;

    return other.type == type && other.title == title;
  }

  @override
  int get hashCode => type.hashCode ^ title.hashCode;
}
