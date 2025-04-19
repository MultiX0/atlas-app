import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

class Genreses extends StatelessWidget {
  const Genreses({super.key, required this.selectedGenres});

  final List<NovelsGenreModel> selectedGenres;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textFieldFillColor,
        borderRadius: BorderRadius.circular(Spacing.normalRaduis),
      ),
      child:
          selectedGenres.isEmpty
              ? Text(
                "أنقر لاضافة تصنيفات الرواية",
                style: TextStyle(
                  color: AppColors.mutedSilver.withValues(alpha: .65),
                  fontFamily: arabicPrimaryFont,
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              )
              : Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      selectedGenres.map((gen) {
                        return Material(
                          color: Colors.transparent,
                          child: Text(
                            ",${gen.name}",
                            style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 15),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
