// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/imports.dart';

class PostInteractionModel {
  final String id;
  final String userId;
  final String postId;
  final bool liked;
  final bool shared;
  final bool favorite;
  PostInteractionModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.liked,
    required this.shared,
    required this.favorite,
  });

  PostInteractionModel copyWith({
    String? id,
    String? userId,
    String? postId,
    bool? liked,
    bool? shared,
    bool? favorite,
  }) {
    return PostInteractionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      liked: liked ?? this.liked,
      shared: shared ?? this.shared,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.userId: userId,
      KeyNames.post_id: postId,
      KeyNames.liked: liked,
      KeyNames.shared: shared,
      KeyNames.favorited: favorite,
    };
  }

  factory PostInteractionModel.fromMap(Map<String, dynamic> map) {
    return PostInteractionModel(
      id: map[KeyNames.id] ?? "",
      userId: map[KeyNames.userId] ?? "",
      postId: map[KeyNames.post_id] ?? "",
      liked: map[KeyNames.liked] ?? false,
      shared: map[KeyNames.shared] ?? false,
      favorite: map[KeyNames.favorited] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostInteractionModel.fromJson(String source) =>
      PostInteractionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostInteractionModel(id: $id, userId: $userId, postId: $postId, liked: $liked, shared: $shared, favorite: $favorite)';
  }

  @override
  bool operator ==(covariant PostInteractionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.postId == postId &&
        other.liked == liked &&
        other.shared == shared &&
        other.favorite == favorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        postId.hashCode ^
        liked.hashCode ^
        shared.hashCode ^
        favorite.hashCode;
  }
}
