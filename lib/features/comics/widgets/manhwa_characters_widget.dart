import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/widgets/comic_characters_widget.dart';
import 'package:atlas_app/imports.dart';

class ManhwaCharactersWidget extends ConsumerStatefulWidget {
  const ManhwaCharactersWidget({super.key, required this.comic});

  final ComicModel comic;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ManhwaCharactersWidgetState();
}

class _ManhwaCharactersWidgetState extends ConsumerState<ManhwaCharactersWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),

        if (widget.comic.characters != null && widget.comic.characters!.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                ComicCharactersWidget(characters: widget.comic.characters ?? []),
                const SizedBox(height: 10),
                ComicCharactersWidget(
                  characters: widget.comic.characters ?? [],
                  mainCharacters: false,
                ),
              ]),
            ),
          ),
        ] else ...[
          SliverFillRemaining(hasScrollBody: false, child: Center(child: buildEmptyState())),
        ],
      ],
    );
  }
}

Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_characters.gif', height: 130),
        const SizedBox(height: 15),
        const Text(
          "نحن نعمل على اضافة الشخصيات",
          style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
        ),
      ],
    ),
  );
}
