import 'package:atlas_app/imports.dart';

class ChapterModel {
  final String id;
  final DateTime created_at;
  final double number;
  final String novelId;
  final String? title;
  final Map<String, dynamic> content;
  ChapterModel({
    required this.id,
    required this.created_at,
    required this.number,
    required this.novelId,
    this.title,
    required this.content,
  });

  ChapterModel copyWith({
    String? id,
    DateTime? created_at,
    double? number,
    String? novelId,
    String? title,
    Map<String, dynamic>? content,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      number: number ?? this.number,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': created_at.millisecondsSinceEpoch,
      'number': number,
      'novelId': novelId,
      'title': title,
      'content': content,
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map[KeyNames.id] ?? "",
      created_at: DateTime.parse(map[KeyNames.created_at]),
      number: map[KeyNames.number].toDouble(),
      novelId: map[KeyNames.novel_id] ?? "",
      title: map[KeyNames.title],
      content: Map<String, dynamic>.from((map[KeyNames.content])),
    );
  }
}
