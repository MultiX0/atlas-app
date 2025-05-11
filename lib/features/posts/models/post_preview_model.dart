// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

class PostPreviewModel {
  final String postId;
  final String content;
  final List<String> images;
  final UserModel user;
  final DateTime createdAt;
  PostPreviewModel({
    required this.postId,
    required this.content,
    required this.images,
    required this.user,
    required this.createdAt,
  });

  PostPreviewModel copyWith({
    String? postId,
    String? content,
    List<String>? images,
    UserModel? user,
    DateTime? createdAt,
  }) {
    return PostPreviewModel(
      postId: postId ?? this.postId,
      content: content ?? this.content,
      images: images ?? this.images,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostPreviewModel.fromMap(Map<String, dynamic> map) {
    return PostPreviewModel(
      postId: map[KeyNames.id] ?? '',
      content: map[KeyNames.content] ?? '',
      images: [],
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      user: UserModel.fromMap(map[KeyNames.user] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'PostPreviewModel(postId: $postId, content: $content, images: $images, user: $user)';
  }

  @override
  bool operator ==(covariant PostPreviewModel other) {
    if (identical(this, other)) return true;

    return other.postId == postId &&
        other.content == content &&
        listEquals(other.images, images) &&
        other.user == user;
  }

  @override
  int get hashCode {
    return postId.hashCode ^ content.hashCode ^ images.hashCode ^ user.hashCode;
  }
}
