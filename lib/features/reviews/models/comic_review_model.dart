import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/imports.dart';

class ComicReviewModel {
  final String id;
  final int likes_count;
  final bool i_liked;
  final String comicId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double writingQuality;
  final double storyDevelopment;
  final double characterDesign;
  final double updateStability;
  final double worldBackground;
  final double overall;
  final bool spoilers;
  final String review;
  final List images;
  final UserModel? user;
  ComicReviewModel({
    required this.id,
    required this.likes_count,
    required this.i_liked,
    required this.comicId,
    required this.images,
    required this.userId,
    required this.writingQuality,
    required this.createdAt,
    this.updatedAt,
    required this.storyDevelopment,
    required this.characterDesign,
    required this.updateStability,
    required this.worldBackground,
    required this.overall,
    required this.review,
    required this.spoilers,
    this.user,
  });

  ComicReviewModel copyWith({
    String? comicId,
    String? userId,
    double? writingQuality,
    double? storyDevelopment,
    double? characterDesign,
    double? updateStability,
    double? worldBackground,
    double? overall,
    DateTime? updatedAt,
    DateTime? createdAt,
    bool? spoilers,
    String? review,
    UserModel? user,
    List? images,
    String? id,
    int? likes_count,
    bool? i_liked,
  }) {
    return ComicReviewModel(
      comicId: comicId ?? this.comicId,
      userId: userId ?? this.userId,
      writingQuality: writingQuality ?? this.writingQuality,
      storyDevelopment: storyDevelopment ?? this.storyDevelopment,
      characterDesign: characterDesign ?? this.characterDesign,
      updateStability: updateStability ?? this.updateStability,
      worldBackground: worldBackground ?? this.worldBackground,
      overall: overall ?? this.overall,
      spoilers: spoilers ?? this.spoilers,
      images: images ?? this.images,
      review: review ?? this.review,
      user: this.user,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      i_liked: i_liked ?? this.i_liked,
      id: id ?? this.id,
      likes_count: likes_count ?? this.likes_count,
    );
  }

  factory ComicReviewModel.from({required ComicReviewModel reviewModel}) {
    return ComicReviewModel(
      comicId: reviewModel.comicId,
      userId: reviewModel.userId,
      writingQuality: reviewModel.writingQuality,
      storyDevelopment: reviewModel.storyDevelopment,
      characterDesign: reviewModel.characterDesign,
      updateStability: reviewModel.updateStability,
      worldBackground: reviewModel.worldBackground,
      overall: reviewModel.overall,
      spoilers: reviewModel.spoilers,
      images: reviewModel.images,
      review: reviewModel.review,
      user: reviewModel.user,
      createdAt: reviewModel.createdAt,
      updatedAt: reviewModel.updatedAt,
      i_liked: reviewModel.i_liked,
      id: reviewModel.id,
      likes_count: reviewModel.likes_count,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.comic_id: comicId,
      KeyNames.userId: userId,
      KeyNames.id: id,
      KeyNames.writing_quality: writingQuality,
      KeyNames.story_development: storyDevelopment,
      KeyNames.character_design: characterDesign,
      KeyNames.update_stability: updateStability,
      KeyNames.world_background: worldBackground,
      KeyNames.overall: overall,
      KeyNames.spoilers: spoilers,
      KeyNames.images: images,
      KeyNames.review_text: review,
      KeyNames.created_at: createdAt.toIso8601String(),
      KeyNames.updated_at: updatedAt?.toIso8601String(),
    };
  }

  factory ComicReviewModel.fromMap(Map<String, dynamic> map) {
    return ComicReviewModel(
      id: map[KeyNames.id] ?? "",
      likes_count: map[KeyNames.like_count] ?? 0,
      i_liked: map[KeyNames.user_liked] ?? false,
      comicId: map[KeyNames.comic_id] ?? "",
      userId: map[KeyNames.userId] ?? "",
      writingQuality: map[KeyNames.writing_quality] ?? 1.0,
      storyDevelopment: map[KeyNames.story_development] ?? 1.0,
      characterDesign: map[KeyNames.character_design] ?? 1.0,
      updateStability: map[KeyNames.update_stability] ?? 1.0,
      worldBackground: map[KeyNames.world_background] ?? 1.0,
      images: List.from(map[KeyNames.images] ?? []),
      overall: map[KeyNames.overall] ?? 1.0,
      spoilers: map[KeyNames.spoilers] ?? false,
      user: map[TableNames.users] == null ? null : UserModel.fromMap(map[TableNames.users]),
      review: map[KeyNames.review_text] ?? "",
      createdAt: DateTime.parse(map[KeyNames.created_at]),
      updatedAt: DateTime.parse(map[KeyNames.updated_at]),
    );
  }

  @override
  String toString() {
    return 'ComicReviewModel(comicId: $comicId, userId: $userId, writingQuality: $writingQuality, storyDevelopment: $storyDevelopment, characterDesign: $characterDesign, updateStability: $updateStability, worldBackground: $worldBackground, overall: $overall, spoilers: $spoilers)';
  }

  @override
  bool operator ==(covariant ComicReviewModel other) {
    if (identical(this, other)) return true;

    return other.comicId == comicId &&
        other.userId == userId &&
        other.writingQuality == writingQuality &&
        other.storyDevelopment == storyDevelopment &&
        other.characterDesign == characterDesign &&
        other.updateStability == updateStability &&
        other.worldBackground == worldBackground &&
        other.overall == overall &&
        other.spoilers == spoilers;
  }

  @override
  int get hashCode {
    return comicId.hashCode ^
        userId.hashCode ^
        writingQuality.hashCode ^
        storyDevelopment.hashCode ^
        characterDesign.hashCode ^
        updateStability.hashCode ^
        worldBackground.hashCode ^
        overall.hashCode ^
        spoilers.hashCode;
  }
}
