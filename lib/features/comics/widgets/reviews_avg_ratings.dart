import 'package:atlas_app/core/common/constants/fonts_constants.dart';
import 'package:flutter/material.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/single_rating_item.dart';

class ReviewsAverageRatings extends StatelessWidget {
  const ReviewsAverageRatings({
    super.key,
    required this.writingQualityAvg,
    required this.storyDevelopmentAvg,
    required this.characterDesignAvg,
    required this.updateStabilityAvg,
    required this.worldBackgroundAvg,
    required this.overallAvg,
    required this.color,
    this.padding = const EdgeInsets.all(16.0),
    this.radius = 15.0,
    this.spacing = 10.0,
  });

  final double writingQualityAvg;
  final double storyDevelopmentAvg;
  final double characterDesignAvg;
  final double updateStabilityAvg;
  final double worldBackgroundAvg;
  final double overallAvg;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleRatingItem(label: "جودة الكتابة", rating: writingQualityAvg, color: color),
        SingleRatingItem(label: "بناء القصة", rating: storyDevelopmentAvg, color: color),
        SingleRatingItem(label: "تصميم الشخصيات", rating: characterDesignAvg, color: color),
        SingleRatingItem(label: "تطور الأحداث", rating: updateStabilityAvg, color: color),
        SingleRatingItem(label: "بناء العالم", rating: worldBackgroundAvg, color: color),
        SizedBox(height: spacing),
        CardContainer(
          color: Colors.black,
          padding: padding,
          raduis: radius,
          child: Row(
            children: [
              const Text("إجمالي", style: TextStyle(fontFamily: arabicAccentFont, fontSize: 15)),
              const Spacer(),
              Text(
                overallAvg.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
