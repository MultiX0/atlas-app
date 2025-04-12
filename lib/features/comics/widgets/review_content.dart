import 'package:atlas_app/imports.dart';

class ReviewContent extends StatelessWidget {
  const ReviewContent({super.key, required this.review, required this.reviewArabic});

  final ComicReviewModel review;
  final bool reviewArabic;

  @override
  Widget build(BuildContext context) {
    return Text(
      review.review,
      textDirection: reviewArabic ? TextDirection.rtl : TextDirection.ltr,
      textAlign: reviewArabic ? TextAlign.right : TextAlign.left,
      style: TextStyle(fontFamily: reviewArabic ? arabicPrimaryFont : primaryFont),
    );
  }
}
