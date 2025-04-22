import 'package:atlas_app/imports.dart';

class NovelChapterCommentReplyWithLikes {
  final String id;
  final String commentId;
  final String content;
  final String userId;
  final String parentCommentAuthorId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final bool isDeleted;
  final int likesCount;
  final bool isLiked;
  final UserModel user;

  NovelChapterCommentReplyWithLikes({
    required this.id,
    required this.commentId,
    required this.content,
    required this.userId,
    required this.parentCommentAuthorId,
    required this.createdAt,
    this.updatedAt,
    required this.user,
    required this.isEdited,
    required this.isDeleted,
    required this.likesCount,
    required this.isLiked,
  });

  factory NovelChapterCommentReplyWithLikes.fromMap(Map<String, dynamic> map) {
    return NovelChapterCommentReplyWithLikes(
      id: map[KeyNames.id] ?? "",
      commentId: map[KeyNames.comment_id] ?? "",
      content: map[KeyNames.content] ?? "",
      userId: map[KeyNames.userId] ?? "",
      parentCommentAuthorId: map[KeyNames.parent_comment_author_id] ?? "",
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      updatedAt: map[KeyNames.updated_at] != null ? DateTime.parse(map[KeyNames.updated_at]) : null,
      isEdited: map[KeyNames.is_edited] ?? false,
      isDeleted: map[KeyNames.is_deleted] ?? false,
      likesCount: map[KeyNames.likes_count] ?? 0,
      isLiked: map[KeyNames.is_liked] ?? false,
      user: UserModel.fromMap(map[KeyNames.user]),
    );
  }

  NovelChapterCommentReplyWithLikes copyWith({
    String? id,
    String? commentId,
    String? content,
    String? userId,
    String? parentCommentAuthorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isDeleted,
    int? likesCount,
    bool? isLiked,
    UserModel? user,
  }) {
    return NovelChapterCommentReplyWithLikes(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      parentCommentAuthorId: parentCommentAuthorId ?? this.parentCommentAuthorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      user: user ?? this.user,
    );
  }
}
