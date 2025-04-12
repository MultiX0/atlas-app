import 'package:atlas_app/imports.dart';

class ReviewActions extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomLikeButton(
          likeCount: review.likes_count,
          onTap: (_) async => onLike!(true),
          isLiked: review.i_liked,
          size: 24,
        ),
      ],
    );
  }
}
