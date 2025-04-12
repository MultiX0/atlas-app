// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:atlas_app/features/characters/models/character_preview_model.dart';
import 'package:atlas_app/features/comics/models/comic_preview_model.dart';
import 'package:atlas_app/features/novels/models/novel_preview_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

import 'package:atlas_app/features/posts/models/post_preview_model.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';

class PostModel {
  final String postId;
  final DateTime createdAt;
  final String content;
  final String userId;
  final String? parentId;
  final PostPreviewModel? parent;
  final UserModel user;
  final List images;
  final bool canReposted;
  final int likeCount;
  final bool userLiked;
  final int commentsCount;
  final int repostedCount;
  final List<ComicPreviewModel> manhwaMentioned;
  final List<CharacterPreviewModel> charactersMentioned;
  final List<NovelPreviewModel> novelsMentioned;
  final ComicReviewModel? reviewMentioned;
  final List hashtags;
  PostModel({
    required this.postId,
    required this.createdAt,
    required this.content,
    required this.userId,
    this.parentId,
    this.parent,
    required this.user,
    required this.images,
    required this.canReposted,
    required this.likeCount,
    required this.userLiked,
    required this.commentsCount,
    required this.repostedCount,
    required this.manhwaMentioned,
    required this.charactersMentioned,
    required this.novelsMentioned,
    this.reviewMentioned,
    required this.hashtags,
  });

  PostModel copyWith({
    String? postId,
    DateTime? createdAt,
    String? content,
    String? userId,
    String? parentId,
    PostPreviewModel? parent,
    UserModel? user,
    List? images,
    bool? canReposted,
    int? likeCount,
    bool? userLiked,
    int? commentsCount,
    int? repostedCount,
    List<ComicPreviewModel>? manhwaMentioned,
    List<CharacterPreviewModel>? charactersMentioned,
    List<NovelPreviewModel>? novelsMentioned,
    ComicReviewModel? reviewMentioned,
    List? hashtags,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      parent: parent ?? this.parent,
      user: user ?? this.user,
      images: images ?? this.images,
      canReposted: canReposted ?? this.canReposted,
      likeCount: likeCount ?? this.likeCount,
      userLiked: userLiked ?? this.userLiked,
      commentsCount: commentsCount ?? this.commentsCount,
      repostedCount: repostedCount ?? this.repostedCount,
      manhwaMentioned: manhwaMentioned ?? this.manhwaMentioned,
      charactersMentioned: charactersMentioned ?? this.charactersMentioned,
      novelsMentioned: novelsMentioned ?? this.novelsMentioned,
      reviewMentioned: reviewMentioned ?? this.reviewMentioned,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'content': content,
      'userId': userId,
      'parentId': parentId,
      'parent': parent?.postId,
      'user': user.toMap(),
      'images': images,
      'canReposted': canReposted,
      'likeCount': likeCount,
      'userLiked': userLiked,
      'commentsCount': commentsCount,
      'repostedCount': repostedCount,
      // 'manhwaMentioned': manhwaMentioned.map((x) => x.toMap()).toList(),
      // 'charactersMentioned': charactersMentioned.map((x) => x.toMap()).toList(),
      // 'novelsMentioned': novelsMentioned.map((x) => x.toMap()).toList(),
      'reviewMentioned': reviewMentioned?.toMap(),
      'hashtags': hashtags,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map[KeyNames.post_id] as String,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      content: map[KeyNames.content] as String,
      userId: map[KeyNames.userId] as String,
      parentId: map[KeyNames.parent_post],
      parent:
          map[KeyNames.parent] != null
              ? PostPreviewModel.fromMap(map[KeyNames.parent] as Map<String, dynamic>)
              : null,
      user: UserModel.fromMap(map[KeyNames.user] as Map<String, dynamic>),
      images: List.from((jsonDecode(map[KeyNames.images]) ?? [])),
      canReposted: map[KeyNames.can_reposted] as bool,
      likeCount: map[KeyNames.like_count] as int,
      userLiked: map[KeyNames.user_liked] as bool,
      commentsCount: map[KeyNames.comments_count] as int,
      repostedCount: map[KeyNames.reposts_count] as int,
      manhwaMentioned:
          map[KeyNames.manhwa_mentions] == null
              ? []
              : List<ComicPreviewModel>.from(
                (map[KeyNames.manhwa_mentions] as List).map((x) => ComicPreviewModel.fromMap(x)),
              ),

      charactersMentioned:
          map[KeyNames.character_mentions] == null
              ? []
              : List<CharacterPreviewModel>.from(
                (map[KeyNames.character_mentions] as List).map(
                  (x) => CharacterPreviewModel.fromMap(x),
                ),
              ),
      novelsMentioned:
          map[KeyNames.novel_mentions] == null
              ? []
              : List<NovelPreviewModel>.from(
                (map[KeyNames.novel_mentions] as List).map((x) => NovelPreviewModel.fromMap(x)),
              ),
      reviewMentioned:
          map[KeyNames.review_mentioned] != null
              ? ComicReviewModel.fromMap(map[KeyNames.review_mentioned])
              : null,
      hashtags: List.from((map[KeyNames.hashtags] ?? [])),
    );
  }
  @override
  String toString() {
    return 'PostModel(postId: $postId, createdAt: $createdAt, content: $content, userId: $userId, parentId: $parentId, parent: $parent, user: $user, images: $images, canReposted: $canReposted, likeCount: $likeCount, userLiked: $userLiked, commentsCount: $commentsCount, repostedCount: $repostedCount, manhwaMentioned: $manhwaMentioned, charactersMentioned: $charactersMentioned, novelsMentioned: $novelsMentioned, reviewMentioned: $reviewMentioned, hashtags: $hashtags)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.postId == postId &&
        other.createdAt == createdAt &&
        other.content == content &&
        other.userId == userId &&
        other.parentId == parentId &&
        other.parent == parent &&
        other.user == user &&
        listEquals(other.images, images) &&
        other.canReposted == canReposted &&
        other.likeCount == likeCount &&
        other.userLiked == userLiked &&
        other.commentsCount == commentsCount &&
        other.repostedCount == repostedCount &&
        listEquals(other.manhwaMentioned, manhwaMentioned) &&
        listEquals(other.charactersMentioned, charactersMentioned) &&
        listEquals(other.novelsMentioned, novelsMentioned) &&
        other.reviewMentioned == reviewMentioned &&
        listEquals(other.hashtags, hashtags);
  }

  @override
  int get hashCode {
    return postId.hashCode ^
        createdAt.hashCode ^
        content.hashCode ^
        userId.hashCode ^
        parentId.hashCode ^
        parent.hashCode ^
        user.hashCode ^
        images.hashCode ^
        canReposted.hashCode ^
        likeCount.hashCode ^
        userLiked.hashCode ^
        commentsCount.hashCode ^
        repostedCount.hashCode ^
        manhwaMentioned.hashCode ^
        charactersMentioned.hashCode ^
        novelsMentioned.hashCode ^
        reviewMentioned.hashCode ^
        hashtags.hashCode;
  }
}
