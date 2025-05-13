// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/imports.dart';

class PostCommentReplyModel {
  final String id;
  final String commentId;
  final String parentAuthorId;
  final String userId;
  final String content;
  final bool isDeleted;
  final bool isEdited;
  final int likeCounts;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserModel? user;
  final UserModel parent_user;

  final bool isLiked;

  PostCommentReplyModel({
    required this.id,
    required this.commentId,
    required this.parentAuthorId,
    required this.userId,
    required this.content,
    required this.isDeleted,
    required this.isEdited,
    required this.likeCounts,
    this.user,
    this.updatedAt,
    required this.isLiked,
    required this.createdAt,
    required this.parent_user,
  });

  PostCommentReplyModel copyWith({
    String? id,
    String? commentId,
    String? parentAuthorId,
    String? userId,
    String? content,
    bool? isDeleted,
    bool? isEdited,
    int? likeCounts,
    UserModel? user,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    UserModel? parent_user,
  }) {
    return PostCommentReplyModel(
      id: id ?? this.id,
      commentId: commentId ?? this.commentId,
      parentAuthorId: parentAuthorId ?? this.parentAuthorId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      likeCounts: likeCounts ?? this.likeCounts,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      parent_user: parent_user ?? this.parent_user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.comment_id: commentId,
      KeyNames.parent_comment_author_id: parentAuthorId,
      KeyNames.userId: userId,
      KeyNames.content: content,
      KeyNames.like_count: likeCounts,
      KeyNames.updated_at: updatedAt?.toIso8601String(),
    };
  }

  factory PostCommentReplyModel.fromMap(Map<String, dynamic> map) {
    return PostCommentReplyModel(
      id: map[KeyNames.id] ?? "",
      commentId: map[KeyNames.comment_id] ?? "",
      parentAuthorId: map[KeyNames.parent_comment_author_id] ?? "",
      userId: map[KeyNames.userId] ?? "",
      content: map[KeyNames.content] ?? "",
      isDeleted: map[KeyNames.is_deleted] ?? false,
      isEdited: map[KeyNames.is_edited] ?? false,
      likeCounts: map[KeyNames.likes_count] ?? 0,
      user: map[KeyNames.user] != null ? UserModel.fromMap(map[KeyNames.user]) : null,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      isLiked: map[KeyNames.is_liked] ?? false,
      updatedAt: map[KeyNames.updated_at] != null ? DateTime.parse(map[KeyNames.updated_at]) : null,
      parent_user: UserModel.fromMap(map[KeyNames.parent_user]),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostCommentReplyModel.fromJson(String source) =>
      PostCommentReplyModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostCommentReplyModel(id: $id, commentId: $commentId, parentAuthorId: $parentAuthorId, userId: $userId, content: $content, isDeleted: $isDeleted, isEdited: $isEdited, likeCounts: $likeCounts, user: $user)';
  }

  @override
  bool operator ==(covariant PostCommentReplyModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.commentId == commentId &&
        other.parentAuthorId == parentAuthorId &&
        other.userId == userId &&
        other.content == content &&
        other.isDeleted == isDeleted &&
        other.isEdited == isEdited &&
        other.likeCounts == likeCounts &&
        other.user == user;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        commentId.hashCode ^
        parentAuthorId.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        isDeleted.hashCode ^
        isEdited.hashCode ^
        likeCounts.hashCode ^
        user.hashCode;
  }
}
