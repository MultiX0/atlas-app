import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/features/comics/widgets/single_rating_item.dart';
import 'package:atlas_app/imports.dart';

class ReviewsAverageRatings extends StatelessWidget {
  const ReviewsAverageRatings({super.key, required this.avg, required this.comic});

  final AvgReviewsModel avg;
  final ComicModel comic;

  @override
  Widget build(BuildContext context) {
    final overAllColor = comic.color != null ? HexColor(comic.color!) : AppColors.whiteColor;

    return Column(
      children: [
        SingleRatingItem(label: "جودة الكتابة", rating: avg.writing_quality_avg, comic: comic),
        SingleRatingItem(label: "بناء القصة", rating: avg.story_development_avg, comic: comic),
        SingleRatingItem(label: "تصميم الشخصيات", rating: avg.character_design_avg, comic: comic),
        SingleRatingItem(label: "تطور الأحداث", rating: avg.update_stability_avg, comic: comic),
        SingleRatingItem(label: "بناء العالم", rating: avg.world_background_avg, comic: comic),
        const SizedBox(height: 10),
        CardContainer(
          color: AppColors.blackColor,
          padding: const EdgeInsets.all(16.0),
          raduis: 15,
          child: Row(
            children: [
              const Text("إجمالي", style: TextStyle(fontFamily: arabicAccentFont, fontSize: 15)),
              const Spacer(),
              Text(
                avg.overall_avg.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: overAllColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
