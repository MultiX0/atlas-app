import 'package:atlas_app/features/comics/widgets/empty_rate_widget.dart';
import 'package:atlas_app/features/comics/widgets/reviews_avg_ratings.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/imports.dart';

class ReviewsAverageCard extends ConsumerWidget {
  const ReviewsAverageCard({
    super.key,
    required this.reviews,
    required this.comic,
    required this.iAlreadyReviewdOnce,
    required this.avgReviews,
  });

  final List<ComicReviewModel> reviews;
  final ComicModel comic;
  final bool iAlreadyReviewdOnce;
  final AvgReviewsModel avgReviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(onTap: () => _onTap(ref), child: _buildAvgCard(avgReviews));
  }

  void _onTap(WidgetRef ref) {
    if (reviews.isEmpty || !iAlreadyReviewdOnce) {
      ref.read(navsProvider).goToAddComicReviewPage('f');
    } else {
      ref.read(navsProvider).goToMakePostPage(PostType.comic_review);
    }
  }

  Widget _buildAvgCard(AvgReviewsModel avg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
      child: CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: LanguageText(
                accent: true,
                "متوسط التقييمات",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: arabicAccentFont,
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (reviews.isNotEmpty) ...[
              ReviewsAverageRatings(avg: avg, comic: comic),
            ] else ...[
              const EmptyRatingsWidget(),
            ],
          ],
        ),
      ),
    );
  }
}
