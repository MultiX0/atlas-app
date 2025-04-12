import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';
import 'package:atlas_app/imports.dart';

class SingleRatingItem extends StatelessWidget {
  const SingleRatingItem({
    super.key,
    required this.label,
    required this.rating,
    required this.comic,
  });

  final String label;
  final double rating;
  final ComicModel comic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: arabicAccentFont,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          RatingBarDisplay(comic: comic, rating: rating),
        ],
      ),
    );
  }
}
