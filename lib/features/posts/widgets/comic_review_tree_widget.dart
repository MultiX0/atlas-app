import 'package:atlas_app/features/posts/widgets/post_field_widget.dart';
import 'package:atlas_app/features/posts/widgets/review_card_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class ComicReviewTreeWidget extends ConsumerWidget {
  const ComicReviewTreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.mutedSilver.withValues(alpha: .35);

    return ColumnRepostTreeView(
      heigh: 120,
      lineColor: color,
      lineWidth: 1.5,
      children: [
        Consumer(
          builder: (context, ref, _) {
            final review = ref.watch(selectedReview);
            if (review == null) return const SizedBox.shrink();
            final reviewArabic = Bidi.hasAnyRtl(review.review);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReviewCardWidget(
                avatarUrl: review.user!.avatar,
                rating: review.overall,
                reviewText: review.review,
                username: review.user!.username,
                isArabic: reviewArabic,
                color: AppColors.primary,
              ),
            );
          },
        ),
        const PostFieldWidget(),
      ],
    );
  }
}
