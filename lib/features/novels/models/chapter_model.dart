// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class ChapterModel {
  final String id;
  final DateTime created_at;
  final double number;
  final String novelId;
  final String? title;
  final int views;
  final List<Map<String, dynamic>> content;
  final bool has_viewed_recently;
  final int likeCount;
  final bool isLiked;
  final int commentsCount;
  ChapterModel({
    required this.id,
    required this.created_at,
    required this.number,
    required this.novelId,
    required this.commentsCount,
    required this.isLiked,
    required this.likeCount,
    this.title,
    this.views = 0,
    this.has_viewed_recently = false,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.created_at: created_at.toIso8601String(),
      KeyNames.number: number,
      KeyNames.novel_id: novelId,
      KeyNames.title: title,
      KeyNames.content: content,
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map[KeyNames.id] ?? "",
      created_at: DateTime.parse(map[KeyNames.created_at]),
      number: map[KeyNames.number].toDouble(),
      novelId: map[KeyNames.novel_id] ?? "",
      title: map[KeyNames.title],
      content: List<Map<String, dynamic>>.from(map[KeyNames.content] ?? []),
      views: map[KeyNames.view_count] ?? 0,
      has_viewed_recently: map[KeyNames.has_viewed_recently] ?? false,
      commentsCount: map[KeyNames.comment_count] ?? 0,
      isLiked: map[KeyNames.is_liked] ?? false,
      likeCount: map[KeyNames.likes_count] ?? 0,
    );
  }

  @override
  String toString() {
    return 'ChapterModel(id: $id, created_at: $created_at, number: $number, novelId: $novelId, title: $title, views: $views, has_viewed_recently: $has_viewed_recently)';
  }

  ChapterModel copyWith({
    String? id,
    DateTime? created_at,
    double? number,
    String? novelId,
    String? title,
    int? views,
    List<Map<String, dynamic>>? content,
    bool? has_viewed_recently,
    int? likeCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      created_at: created_at ?? this.created_at,
      number: number ?? this.number,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      views: views ?? this.views,
      content: content ?? this.content,
      has_viewed_recently: has_viewed_recently ?? this.has_viewed_recently,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
