// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/imports.dart';

class ComicPublishedModel {
  final DateTime? from;
  final DateTime? to;
  final String? string;
  ComicPublishedModel({required this.from, this.to, required this.string});

  ComicPublishedModel copyWith({DateTime? from, DateTime? to, String? string}) {
    return ComicPublishedModel(
      from: from ?? this.from,
      to: to ?? this.to,
      string: string ?? this.string,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
      'string': string,
    };
  }

  factory ComicPublishedModel.fromMap(Map<String, dynamic> map) {
    return ComicPublishedModel(
      from: map[KeyNames.from] == null ? null : DateTime.parse(map[KeyNames.from]),
      to: map[KeyNames.to] != null ? DateTime.parse(map[KeyNames.to]) : null,
      string: map[KeyNames.string],
    );
  }

  String toJson() => json.encode(toMap());

  factory ComicPublishedModel.fromJson(String source) =>
      ComicPublishedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ComicPublishedModel(from: $from, to: $to, string: $string)';

  @override
  bool operator ==(covariant ComicPublishedModel other) {
    if (identical(this, other)) return true;

    return other.from == from && other.to == to && other.string == string;
  }

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ string.hashCode;
}
