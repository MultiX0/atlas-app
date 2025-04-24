import 'package:atlas_app/imports.dart';

class ReviewContent extends StatelessWidget {
  const ReviewContent({super.key, required this.reviewText, this.isArabic = false, this.textStyle});

  final String reviewText;
  final bool isArabic;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      reviewText,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      style: textStyle ?? const TextStyle(fontFamily: arabicPrimaryFont),
    );
  }
}
