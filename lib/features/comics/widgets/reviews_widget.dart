import 'package:atlas_app/features/comics/widgets/reviews_avg_card.dart';
import 'package:atlas_app/features/comics/widgets/user_review_card.dart';
import 'package:atlas_app/imports.dart';

class ReviewsWidget extends ConsumerStatefulWidget {
  const ReviewsWidget({
    super.key,
    required this.reviews,
    required this.comic,
    required this.scrollController,
    required this.iAlreadyReviewdOnce,
  });
  final List<ComicReviewModel> reviews;
  final ComicModel comic;
  final ScrollController scrollController;
  final bool iAlreadyReviewdOnce;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends ConsumerState<ReviewsWidget> {
  @override
  Widget build(BuildContext context) {
    final moreLoading = ref.watch(
      manhwaReviewsStateProvider(widget.comic.comicId).select((state) => state.moreLoading),
    );
    final avgReviews = ref.watch(
      manhwaReviewsStateProvider(widget.comic.comicId).select((state) => state.avgReviews),
    );

    return SliverList.builder(
      addRepaintBoundaries: true,
      itemCount: widget.reviews.length + (moreLoading ? 2 : 1),
      itemBuilder: (context, i) {
        if (i == 0) {
          return RepaintBoundary(
            child: ReviewsAverageCard(
              reviews: widget.reviews,
              comic: widget.comic,
              iAlreadyReviewdOnce: widget.iAlreadyReviewdOnce,
              avgReviews: avgReviews,
            ),
          );
        }
        if (i == widget.reviews.length + 1) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Loader()));
        }
        final review = widget.reviews[i - 1];
        return UserReviewCard(
          key: ValueKey(review.id),
          review: review,
          index: i - 1,
          comic: widget.comic,
        );
      },
    );
  }
}
