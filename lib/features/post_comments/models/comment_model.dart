// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/features/auth/models/user_model.dart';

class PostCommentModel {
  final String id;
  final String postId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String content;
  final bool isDeleted;
  final bool isUpdated;
  final String userId;
  final int likesCount;
  final int repliesCount;
  final UserModel? user;
  final bool isLiked;

  PostCommentModel({
    this.user,
    required this.id,
    required this.postId,
    required this.createdAt,
    this.updatedAt,
    required this.content,
    required this.isDeleted,
    required this.isUpdated,
    required this.userId,
    required this.likesCount,
    required this.repliesCount,
    required this.isLiked,
  });

  PostCommentModel copyWith({
    String? id,
    String? postId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? content,
    bool? isDeleted,
    bool? isUpdated,
    String? userId,
    int? likesCount,
    int? repliesCount,
    UserModel? user,
    bool? isLiked,
  }) {
    return PostCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      content: content ?? this.content,
      isDeleted: isDeleted ?? this.isDeleted,
      isUpdated: isUpdated ?? this.isUpdated,
      userId: userId ?? this.userId,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      user: user ?? this.user,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.post_id: postId,
      KeyNames.updated_at: updatedAt?.toIso8601String(),
      KeyNames.content: content,
      KeyNames.is_deleted: isDeleted,
      KeyNames.is_edited: isUpdated,
      KeyNames.userId: userId,
      KeyNames.like_count: likesCount,
      KeyNames.replies_count: repliesCount,
    };
  }

  factory PostCommentModel.fromMap(Map<String, dynamic> map) {
    return PostCommentModel(
      id: map[KeyNames.id] ?? "",
      postId: map[KeyNames.post_id] ?? "",
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      updatedAt: map[KeyNames.updated_at] != null ? DateTime.parse(map[KeyNames.updated_at]) : null,
      content: map[KeyNames.content] ?? "",
      isDeleted: map[KeyNames.is_deleted] ?? false,
      isUpdated: map[KeyNames.is_edited] ?? false,
      userId: map[KeyNames.userId] ?? "",
      likesCount: map[KeyNames.likes_count] ?? 0,
      repliesCount: map[KeyNames.replies_count] ?? 0,
      user: map[KeyNames.user] != null ? UserModel.fromMap(map[KeyNames.user]) : null,
      isLiked: map[KeyNames.is_liked] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostCommentModel.fromJson(String source) =>
      PostCommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostCommentModel(id: $id, postId: $postId, createdAt: $createdAt, updatedAt: $updatedAt, content: $content, isDeleted: $isDeleted, isUpdated: $isUpdated, userId: $userId, likesCount: $likesCount, repliesCount: $repliesCount)';
  }

  @override
  bool operator ==(covariant PostCommentModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.postId == postId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.content == content &&
        other.isDeleted == isDeleted &&
        other.isUpdated == isUpdated &&
        other.userId == userId &&
        other.likesCount == likesCount &&
        other.repliesCount == repliesCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        content.hashCode ^
        isDeleted.hashCode ^
        isUpdated.hashCode ^
        userId.hashCode ^
        likesCount.hashCode ^
        repliesCount.hashCode;
  }
}
