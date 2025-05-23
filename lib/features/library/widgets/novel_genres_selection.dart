import 'dart:developer';

import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';

// 1. First, let's modify the GenreSelectionSheet class to properly handle selection and deselection

class GenreSelectionSheet extends StatefulWidget {
  final List<NovelsGenreModel> genres;
  final List<NovelsGenreModel> selectedGenres;
  final void Function(List<NovelsGenreModel> updatedGenres) onUpdate;

  const GenreSelectionSheet({
    super.key,
    required this.genres,
    required this.onUpdate,
    required this.selectedGenres,
  });

  @override
  State<GenreSelectionSheet> createState() => _GenreSelectionSheetState();
}

class _GenreSelectionSheetState extends State<GenreSelectionSheet> {
  late List<NovelsGenreModel> selectedGenres;

  @override
  void initState() {
    // Create a deep copy of the selected genres list
    selectedGenres = List.from(widget.selectedGenres);
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
          final isSelected = selectedGenres.any((g) => g.name == genre.name);

          return ListTile(
            title: Row(
              children: [
                Text(genre.name, style: const TextStyle(fontFamily: arabicPrimaryFont)),
                if (isSelected) ...[const Spacer(), const Icon(LucideIcons.check)],
              ],
            ),
            subtitle: Text(
              genre.description,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedSilver),
            ),
            leading: const Icon(LucideIcons.book_open_text, color: AppColors.mutedSilver),
            onTap: () {
              setState(() {
                log("state updated");
                if (isSelected) {
                  // Remove genre if already selected
                  selectedGenres.removeWhere((g) => g.name == genre.name);
                } else {
                  // Add genre if not already selected and less than 3 genres selected
                  if (selectedGenres.length >= 5) {
                    return;
                  }
                  selectedGenres.add(genre);
                }

                // Notify parent with the updated list
                widget.onUpdate(selectedGenres);
              });
            },
          );
        },
      ),
    ),
  );
}
