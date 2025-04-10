import 'package:atlas_app/core/common/constants/key_names.dart';

class AvgReviewsModel {
  final double writing_quality_avg;
  final double story_development_avg;
  final double character_design_avg;
  final double update_stability_avg;
  final double world_background_avg;
  final double overall_avg;
  AvgReviewsModel({
    required this.writing_quality_avg,
    required this.story_development_avg,
    required this.character_design_avg,
    required this.update_stability_avg,
    required this.world_background_avg,
    required this.overall_avg,
  });

  AvgReviewsModel copyWith({
    double? writing_quality_avg,
    double? story_development_avg,
    double? character_design_avg,
    double? update_stability_avg,
    double? world_background_avg,
    double? overall_avg,
  }) {
    return AvgReviewsModel(
      writing_quality_avg: writing_quality_avg ?? this.writing_quality_avg,
      story_development_avg: story_development_avg ?? this.story_development_avg,
      character_design_avg: character_design_avg ?? this.character_design_avg,
      update_stability_avg: update_stability_avg ?? this.update_stability_avg,
      world_background_avg: world_background_avg ?? this.world_background_avg,
      overall_avg: overall_avg ?? this.overall_avg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.writing_quality_avg: writing_quality_avg,
      KeyNames.story_development_avg: story_development_avg,
      KeyNames.character_design_avg: character_design_avg,
      KeyNames.update_stability_avg: update_stability_avg,
      KeyNames.world_background_avg: world_background_avg,
      KeyNames.overall_avg: overall_avg,
    };
  }

  factory AvgReviewsModel.fromMap(Map<String, dynamic> map) {
    return AvgReviewsModel(
      writing_quality_avg: map[KeyNames.writing_quality_avg] ?? 0.0,
      story_development_avg: map[KeyNames.story_development_avg] ?? 0.0,
      character_design_avg: map[KeyNames.character_design_avg] ?? 0.0,
      update_stability_avg: map[KeyNames.update_stability_avg] ?? 0.0,
      world_background_avg: map[KeyNames.world_background_avg] ?? 0.0,
      overall_avg: map[KeyNames.overall_avg] ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'AvgReviewsModel(writing_quality_avg: $writing_quality_avg, story_development_avg: $story_development_avg, character_design_avg: $character_design_avg, update_stability_avg: $update_stability_avg, world_background_avg: $world_background_avg, overall_avg: $overall_avg)';
  }

  @override
  bool operator ==(covariant AvgReviewsModel other) {
    if (identical(this, other)) return true;

    return other.writing_quality_avg == writing_quality_avg &&
        other.story_development_avg == story_development_avg &&
        other.character_design_avg == character_design_avg &&
        other.update_stability_avg == update_stability_avg &&
        other.world_background_avg == world_background_avg &&
        other.overall_avg == overall_avg;
  }

  @override
  int get hashCode {
    return writing_quality_avg.hashCode ^
        story_development_avg.hashCode ^
        character_design_avg.hashCode ^
        update_stability_avg.hashCode ^
        world_background_avg.hashCode ^
        overall_avg.hashCode;
  }
}
