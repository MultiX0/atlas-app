import 'package:atlas_app/features/comics/widgets/reviews_avg_card.dart';
import 'package:atlas_app/features/comics/widgets/user_review_card.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/models/novel_review_model.dart';
import 'package:atlas_app/features/novels/providers/novel_reviews_state.dart';
import 'package:atlas_app/imports.dart';

class NovelReviewsWidget extends ConsumerStatefulWidget {
  const NovelReviewsWidget({
    super.key,
    required this.reviews,
    required this.novel,
    required this.iAlreadyReviewdOnce,
  });
  final List<NovelReviewModel> reviews;
  final NovelModel novel;
  final bool iAlreadyReviewdOnce;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends ConsumerState<NovelReviewsWidget> {
  @override
  Widget build(BuildContext context) {
    final moreLoading = ref.watch(
      novelReviewsState(widget.novel.id).select((state) => state.moreLoading),
    );
    final avgReviews = ref.watch(
      novelReviewsState(widget.novel.id).select((state) => state.avgReviews),
    );

    final color = widget.novel.color;
    return SliverList.builder(
      addRepaintBoundaries: true,
      itemCount: widget.reviews.length + (moreLoading ? 2 : 1),
      itemBuilder: (context, i) {
        if (i == 0) {
          return RepaintBoundary(
            child: ReviewsAverageCard(
              characterDesignAvg: avgReviews.character_design_avg,
              overallAvg: avgReviews.overall_avg,
              iAlreadyReviewedOnce: widget.iAlreadyReviewdOnce,
              onTap: () {},
              reviewsCount: widget.reviews.length,
              color: color,
              storyDevelopmentAvg: avgReviews.story_development_avg,
              updateStabilityAvg: avgReviews.update_stability_avg,
              worldBackgroundAvg: avgReviews.world_background_avg,
              writingQualityAvg: avgReviews.writing_quality_avg,

              // reviews: widget.reviews,
              // comic: widget.comic,
              // iAlreadyReviewdOnce: widget.iAlreadyReviewdOnce,
              // avgReviews: avgReviews,
            ),
          );
        }
        if (i == widget.reviews.length + 1) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Loader()));
        }

        if (moreLoading && i == widget.reviews.length) {
          return const Loader();
        }

        final review = widget.reviews[i - 1];
        final me = ref.read(userState.select((s) => s.user!));
        final isMe = review.userId == me.userId;
        return UserReviewCard(
          key: ValueKey(review.id),
          avatarUrl: review.user!.avatar,
          color: color,
          rating: review.overall,
          reviewText: review.review,
          reviewsCount: review.reviewsCount,
          userId: review.userId,
          username: review.user!.username,
          createdAt: review.createdAt,
          images: review.images.map((s) => s.toString()).toList(),
          isLiked: review.i_liked,
          likeCount: review.likes_count,
          onMenuPressed:
              () => openSheet(
                context: context,
                child: ReviewOptionsSheet(isCreator: isMe, review: review),
              ),

          onLike: (id, i, isLiked) async {
            ref
                .read(reviewsControllerProvider.notifier)
                .handleNovelReviewLike(review.copyWith(i_liked: !isLiked), id, i);
            return true;
          },
          onRepost: () {
            ref.read(selectedReview.notifier).state = review;
            ref.read(navsProvider).goToMakePostPage(PostType.novel_review);
          },
          index: i - 1,
        );
      },
    );
  }
}
