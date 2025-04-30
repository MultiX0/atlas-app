import 'package:atlas_app/features/characters/models/character_model.dart';
import 'package:atlas_app/features/characters/models/comic_characters_model.dart';
import 'package:atlas_app/imports.dart';

class ComicCharactersWidget extends ConsumerWidget {
  const ComicCharactersWidget({super.key, required this.characters, this.mainCharacters = true});
  final List<ComicCharacterModel> characters;
  final bool mainCharacters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _characters = [
      ...characters.where(
        (c) => mainCharacters ? c.role.toLowerCase() == 'main' : c.role.toLowerCase() != 'main',
      ),
    ];
    if (_characters.isEmpty) return const SizedBox.shrink();
    return buildCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainCharacters ? "الرئيسية" : "المساعدة",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: arabicAccentFont,
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...characters
                    .where(
                      (c) =>
                          mainCharacters
                              ? c.role.toLowerCase() == 'main'
                              : c.role.toLowerCase() != 'main',
                    )
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      // final character = entry.value;
                      final characterData = entry.value.character!;

                      final index = entry.key;
                      return buildCharacterPoster(index, characterData);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buildCharacterPoster(int index, CharacterModel characterData) {
    return SizedBox(
      height: 150,
      width: 110,
      child: Padding(
        padding: EdgeInsets.fromLTRB(index == 0 ? 0 : 10, 0, 0, 0),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(imageUrl: characterData.image ?? "", fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.blackColor.withValues(alpha: .9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.15, 0.8],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  softWrap: true,
                  characterData.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildCard({
    double raduis = Spacing.normalRaduis + 5,
    required EdgeInsets padding,
    required Widget child,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      ),
      child: child,
    );
  }
}
