import 'package:atlas_app/core/common/utils/see_more_text.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/imports.dart';

class SynopsisCard extends StatelessWidget {
  const SynopsisCard({super.key, required this.comic});

  final ComicModel comic;

  @override
  Widget build(BuildContext context) {
    final seeMoreTextColor =
        comic.color == null ? AppColors.primary.withValues(alpha: .7) : HexColor(comic.color!);

    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LanguageText(
            accent: true,
            "ملخص",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 5),
          SeeMoreWidget(
            textDirection: TextDirection.rtl,
            comic.ar_synopsis.trim().isEmpty
                ? "لايوجد ملخص لهذا العمل, نحن نعمل على اضافته حاليا"
                : comic.ar_synopsis.trim(),
            textStyle: const TextStyle(
              color: AppColors.mutedSilver,
              fontFamily: arabicPrimaryFont,
              fontSize: 14,
            ),
            seeMoreStyle: TextStyle(
              color: seeMoreTextColor,
              fontWeight: FontWeight.bold,
              fontFamily: accentFont,
            ),
            seeLessStyle: TextStyle(
              color: seeMoreTextColor,
              fontWeight: FontWeight.bold,
              fontFamily: accentFont,
            ),
            seeMoreText: "  عرض المزيد",
            seeLessText: "  عرض أقل",
          ),
        ],
      ),
    );
  }
}
