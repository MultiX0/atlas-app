import 'package:atlas_app/core/common/utils/foreground_color.dart';
import 'package:atlas_app/features/comics/widgets/genres_chip.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/imports.dart';

class GenresCard extends StatelessWidget {
  const GenresCard({super.key, required this.comic});

  final ComicModel comic;

  @override
  Widget build(BuildContext context) {
    final color = comic.color != null ? HexColor(comic.color!) : AppColors.blackColor;
    final textColor = getFontColorForBackground(color);

    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LanguageText(
            'التصنيفات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 15),
          if (comic.genres.isEmpty) ...[
            const Center(
              child: Text(
                "سيتم اضافة تصنيفات هذا العمل في أقرب فترة",
                style: TextStyle(color: AppColors.mutedSilver, fontFamily: arabicAccentFont),
                textDirection: TextDirection.rtl,
              ),
            ),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                runSpacing: 5,
                children:
                    comic.genres
                        .map((genre) => GenreChip(genre: genre, color: color, textColor: textColor))
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
