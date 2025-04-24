import 'dart:developer';

import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

class GenreSelectionSheet extends StatefulWidget {
  final List<NovelsGenreModel> genres;
  final List<NovelsGenreModel> selectedGenreses;
  final void Function(NovelsGenreModel selectedGenre) onSelect;

  const GenreSelectionSheet({
    super.key,
    required this.genres,
    required this.onSelect,
    required this.selectedGenreses,
  });

  @override
  State<GenreSelectionSheet> createState() => _GenreSelectionSheetState();
}

class _GenreSelectionSheetState extends State<GenreSelectionSheet> {
  List<NovelsGenreModel> selectedGenreses = [];
  @override
  void initState() {
    setState(() {
      selectedGenreses = List.from(widget.selectedGenreses);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              "اختر التصنيف",
              style: TextStyle(
                fontFamily: arabicAccentFont,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: buildGenreList(context)),
        ],
      ),
    );
  }

  Widget buildGenreList(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Material(
      color: Colors.transparent,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.genres.length,
        itemBuilder: (context, index) {
          final genre = widget.genres[index];
          return ListTile(
            title: Row(
              children: [
                Text(genre.name, style: const TextStyle(fontFamily: arabicPrimaryFont)),
                if (selectedGenreses.any((g) => g.name == genre.name)) ...[
                  const Spacer(),
                  const Icon(LucideIcons.check),
                ],
              ],
            ),
            subtitle: Text(
              genre.description,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedSilver),
            ),
            leading: const Icon(LucideIcons.book_open_text, color: AppColors.mutedSilver),
            onTap: () {
              widget.onSelect(genre);

              setState(() {
                log("state updated");
                if (selectedGenreses.any((g) => g.name == genre.name)) {
                  selectedGenreses.remove(genre);
                } else {
                  if (selectedGenreses.length >= 3) {
                    return;
                  }
                  selectedGenreses.add(genre);
                }
              });
            },
          );
        },
      ),
    ),
  );
}
