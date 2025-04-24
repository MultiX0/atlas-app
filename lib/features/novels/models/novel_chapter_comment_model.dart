import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/features/auth/models/user_model.dart';

class NovelChapterCommentWithMeta {
  final String id;
  final String chapterId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final bool isDeleted;
  final bool isEdited;
  final int likesCount;
  final bool isLiked;
  final int repliesCount;
  final UserModel user;

  NovelChapterCommentWithMeta({
    required this.id,
    required this.chapterId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    required this.isDeleted,
    required this.isEdited,
    required this.likesCount,
    required this.isLiked,
    required this.repliesCount,
    required this.user,
  });

  factory NovelChapterCommentWithMeta.fromMap(Map<String, dynamic> map) {
    return NovelChapterCommentWithMeta(
      id: map[KeyNames.id] ?? "",
      chapterId: map[KeyNames.chapter_id] ?? "",
      content: map[KeyNames.content] ?? "",
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      updatedAt: map[KeyNames.updated_at] != null ? DateTime.parse(map[KeyNames.updated_at]) : null,
      userId: map[KeyNames.userId],
      isDeleted: map[KeyNames.is_deleted],
      isEdited: map[KeyNames.is_edited],
      likesCount: map[KeyNames.likes_count],
      isLiked: map[KeyNames.is_liked],
      repliesCount: map[KeyNames.replies_count],
      user: UserModel.fromMap(map[KeyNames.user]),
    );
  }

  NovelChapterCommentWithMeta copyWith({
    String? id,
    String? chapterId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isDeleted,
    bool? isEdited,
    int? likesCount,
    bool? isLiked,
    int? repliesCount,
    UserModel? user,
  }) {
    return NovelChapterCommentWithMeta(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      repliesCount: repliesCount ?? this.repliesCount,
      user: user ?? this.user,
    );
  }
}
