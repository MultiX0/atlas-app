import 'package:atlas_app/core/common/constants/fonts_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas_app/features/comics/widgets/empty_rate_widget.dart';
import 'package:atlas_app/features/comics/widgets/reviews_avg_ratings.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';

class ReviewsAverageCard extends ConsumerWidget {
  const ReviewsAverageCard({
    super.key,
    required this.reviewsCount,
    required this.color,
    required this.iAlreadyReviewedOnce,
    required this.writingQualityAvg,
    required this.storyDevelopmentAvg,
    required this.characterDesignAvg,
    required this.updateStabilityAvg,
    required this.worldBackgroundAvg,
    required this.overallAvg,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 10),
    this.cardPadding = const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  });

  final int reviewsCount;
  final Color color;
  final bool iAlreadyReviewedOnce;
  final double writingQualityAvg;
  final double storyDevelopmentAvg;
  final double characterDesignAvg;
  final double updateStabilityAvg;
  final double worldBackgroundAvg;
  final double overallAvg;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final EdgeInsets cardPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: CardContainer(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "متوسط التقييمات",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: arabicAccentFont,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (reviewsCount > 0) ...[
                ReviewsAverageRatings(
                  writingQualityAvg: writingQualityAvg,
                  storyDevelopmentAvg: storyDevelopmentAvg,
                  characterDesignAvg: characterDesignAvg,
                  updateStabilityAvg: updateStabilityAvg,
                  worldBackgroundAvg: worldBackgroundAvg,
                  overallAvg: overallAvg,
                  color: color,
                ),
              ] else ...[
                const EmptyRatingsWidget(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
