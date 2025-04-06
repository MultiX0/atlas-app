import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/navs/navs.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsWidget extends ConsumerStatefulWidget {
  const ReviewsWidget({super.key, required this.reviews, required this.comic});
  final List<ComicReviewModel> reviews;
  final ComicModel comic;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends ConsumerState<ReviewsWidget> {
  List<ComicReviewModel> reviews = [];
  double avgScore = 0;

  @override
  void initState() {
    handleReviews();
    super.initState();
  }

  void handleReviews() {
    if (widget.reviews.isNotEmpty) {
      for (final review in widget.reviews) {
        avgScore += review.overall;
      }
      setState(() {
        avgScore /= widget.reviews.length;
      });
    }

    if (widget.reviews.length > 3) {
      reviews = widget.reviews.sublist(0, 3);
    } else {
      reviews = widget.reviews;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                const LanguageText(
                  accent: true,

                  "المراجعات",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: arabicAccentFont,
                  ),
                ),
                const Spacer(),
                if (reviews.isNotEmpty)
                  GestureDetector(
                    child: const Row(
                      children: [
                        Text("عرض الكل", style: TextStyle(fontFamily: arabicAccentFont)),
                        SizedBox(width: 5),
                        Icon(LucideIcons.chevron_right),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (reviews.isNotEmpty) ...[
            FlutterCarousel.builder(
              itemCount: reviews.length,
              itemBuilder: (context, i, i2) {
                return buildReviewCard(reviews[i]);
              },
              options: FlutterCarouselOptions(
                viewportFraction: 1,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
              ),
            ),
          ] else ...[
            buildEmptyRatings(),
          ],

          const SizedBox(height: 10),
          buildRatingBar(widget.comic),
        ],
      ),
    );
  }

  Widget buildEmptyRatings() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.scaffoldBackground,
        border: Border.all(color: AppColors.blackColor, width: 3),
      ),
      child: const LanguageText("لاتوجد أي تقييمات حاليا لهذا العمل, كن أول من يقيمه!"),
    );
  }

  Widget buildRatingBar(ComicModel comic) {
    final starColor = comic.color != null ? HexColor(comic.color!) : AppColors.primary;

    return Center(
      child: GestureDetector(
        onTap: () => ref.read(navsProvider).goToAddComicReviewPage(),
        child: RatingBarIndicator(
          itemPadding: const EdgeInsets.symmetric(horizontal: 8),
          rating: avgScore,
          itemBuilder: (context, index) => Icon(Icons.star, color: starColor),
          itemCount: 5,
          itemSize: 40.0,
          direction: Axis.horizontal,
        ),
      ),
    );
  }

  Container buildReviewCard(ComicReviewModel review) {
    final starColor =
        widget.comic.color != null ? HexColor(widget.comic.color!) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.scaffoldBackground,
        border: Border.all(color: AppColors.blackColor, width: 3),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: CachedNetworkAvifImageProvider(review.user!.avatar)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("@${review.user?.username}"),
                  const SizedBox(height: 5),
                  RatingBarIndicator(
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                    rating: review.overall,
                    itemBuilder: (context, index) => Icon(Icons.star, color: starColor),
                    itemCount: 5,
                    itemSize: 10.0,
                    direction: Axis.horizontal,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.review, maxLines: 4, style: const TextStyle(color: AppColors.mutedSilver)),
        ],
      ),
    );
  }
}

Container buildCard({
  double raduis = Spacing.normalRaduis + 5,
  required EdgeInsets padding,
  required Widget child,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.primaryAccent,
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
    ),
    child: child,
  );
}
