import 'package:atlas_app/imports.dart';

class ChapterDraftModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String novelId;
  final String? title;
  final List<Map<String, dynamic>> content;
  final double? number;
  final String? originalChapterId;
  final String userId;
  ChapterDraftModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.novelId,
    this.title,
    required this.content,
    this.number,
    this.originalChapterId,
    required this.userId,
  });

  ChapterDraftModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? novelId,
    String? title,
    List<Map<String, dynamic>>? content,
    double? number,
    String? originalChapterId,
    String? userId,
  }) {
    return ChapterDraftModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      content: content ?? this.content,
      number: number ?? this.number,
      originalChapterId: originalChapterId ?? this.originalChapterId,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.created_at: createdAt.toIso8601String(),
      KeyNames.updated_at: updatedAt.toIso8601String(),
      KeyNames.novel_id: novelId,
      KeyNames.title: title,
      KeyNames.content: content,
      KeyNames.number: number,
      KeyNames.original_chapter_id: originalChapterId,
      KeyNames.userId: userId,
    };
  }

  factory ChapterDraftModel.fromMap(Map<String, dynamic> map) {
    return ChapterDraftModel(
      id: map[KeyNames.id] ?? "",
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      updatedAt: DateTime.parse(map[KeyNames.updated_at]),
      novelId: map[KeyNames.novel_id] ?? "",
      title: map[KeyNames.title] != null ? map[KeyNames.title] as String : null,
      content: List<Map<String, dynamic>>.from(map[KeyNames.content] ?? []),
      // ignore: prefer_null_aware_operators
      number: map[KeyNames.number] != null ? map[KeyNames.number].toDouble() : null,
      originalChapterId:
          map[KeyNames.original_chapter_id] != null
              ? map[KeyNames.original_chapter_id] as String
              : null,
      userId: map[KeyNames.userId] ?? "",
    );
  }
}
