import 'package:atlas_app/features/posts/widgets/post_field_widget.dart';
import 'package:atlas_app/features/posts/widgets/review_card_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:intl/intl.dart';

class ComicReviewTreeWidget extends ConsumerWidget {
  const ComicReviewTreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(selectedReview);

    if (review == null) return const SizedBox.shrink();
    final reviewArabic = Bidi.hasAnyRtl(review.review);
    final color = AppColors.mutedSilver.withValues(alpha: .35);

    return ColumnRepostTreeView(
      heigh: 120,
      lineColor: color,
      lineWidth: 1.5,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReviewCardWidget(review: review, reviewArabic: reviewArabic, color: color),
        ),
        const PostFieldWidget(),
      ],
    );
  }
}
