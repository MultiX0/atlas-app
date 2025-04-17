import 'package:atlas_app/imports.dart';

class ReviewActions extends ConsumerWidget {
  const ReviewActions({
    super.key,
    required this.review,
    required this.userId,
    required this.onLike,
  });

  final ComicReviewModel review;
  final String userId;
  final Future<bool?> Function(bool)? onLike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        CustomLikeButton(
          likeCount: review.likes_count,
          onTap: (_) async => onLike!(true),
          isLiked: review.i_liked,
          size: 24,
        ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: () {
            ref.read(selectedReview.notifier).state = review;
            ref.read(navsProvider).goToMakePostPage(PostType.comic_review);
          },
          icon: const Icon(LucideIcons.repeat, size: 22, color: Colors.grey),
        ),
        Text(review.reviewsCount.toString()),
      ],
    );
  }
}
