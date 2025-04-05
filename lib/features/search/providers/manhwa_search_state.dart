// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/features/comics/controller/comics_controller.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ManhwaSearchHelper {
  final List<ComicModel> comics;
  final bool isLoading;
  final String? error;
  ManhwaSearchHelper({required this.comics, required this.isLoading, this.error});

  ManhwaSearchHelper copyWith({List<ComicModel>? comics, bool? isLoading, String? error}) {
    return ManhwaSearchHelper(
      comics: comics ?? this.comics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ManhwaSearchState extends StateNotifier<ManhwaSearchHelper> {
  // ignore: unused_field
  final Ref _ref;
  ManhwaSearchState({required Ref ref})
    : _ref = ref,
      super(ManhwaSearchHelper(comics: [], isLoading: false));

  void handleLoading(bool loadig) {
    state = state.copyWith(isLoading: loadig);
  }

  void reset() {
    state = state.copyWith(isLoading: false, error: null, comics: []);
  }

  void updateComics(List<ComicModel> comics) {
    state = state.copyWith(comics: comics);
  }

  void handleError(String? error) {
    state = state.copyWith(error: error);
  }

  void search({int limit = 25}) async {
    final more = _ref.read(searchGlobalProvider);
    final query = _ref.read(searchQueryProvider);
    await _ref
        .read(comicsControllerProvider.notifier)
        .searchComics(query, more: more, limit: limit);
  }

  void updateSpecificComic(ComicModel comicModel) {
    if (state.comics.isEmpty) return;

    final updatedList = List<ComicModel>.from(
      state.comics.where((c) => c.aniId != comicModel.aniId),
    )..add(comicModel);

    updatedList.sort((a, b) => b.englishTitle.compareTo(a.englishTitle));

    state = state.copyWith(comics: updatedList);
  }
}

final manhwaSearchStateProvider = StateNotifierProvider<ManhwaSearchState, ManhwaSearchHelper>((
  ref,
) {
  return ManhwaSearchState(ref: ref);
});
