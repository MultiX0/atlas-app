import 'package:atlas_app/imports.dart';

class RatingBarDisplay extends StatelessWidget {
  const RatingBarDisplay({super.key, required this.rating, this.comic, this.itemSize = 18});

  final double rating;
  final ComicModel? comic;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    final starColor = comic?.color != null ? HexColor(comic!.color!) : AppColors.primary;
    return RatingBarIndicator(
      direction: Axis.horizontal,
      itemCount: 5,
      rating: rating,
      itemSize: itemSize,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(Icons.star, color: starColor),
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
