import 'package:atlas_app/imports.dart';

class ReviewTimeInfo extends StatelessWidget {
  const ReviewTimeInfo({super.key, required this.review});

  final ComicReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Text(
      review.updatedAt == null
          ? appDateTimeFormat(review.createdAt)
          : "${appDateTimeFormat(review.createdAt)} (محدث)",
      style: const TextStyle(fontSize: 12),
    );
  }
}
