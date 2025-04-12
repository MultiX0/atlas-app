import 'package:atlas_app/features/comics/widgets/external_links_item.dart';
import 'package:atlas_app/features/comics/widgets/reviews_card_container.dart';
import 'package:atlas_app/imports.dart';

class ExternalLinksCard extends ConsumerWidget {
  const ExternalLinksCard({super.key, required this.comic});

  final ComicModel comic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LanguageText(
            accent: true,
            "روابط خارجية وروابط العرض",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 5),
          ...comic.externalLinks!.asMap().entries.map((e) {
            return ExternalLinkItem(
              link: e.value,
              index: e.key + 1,
              color: comic.color != null ? HexColor(comic.color!) : AppColors.primary,
            );
          }),
        ],
      ),
    );
  }
}
