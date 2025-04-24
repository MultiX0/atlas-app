import 'package:atlas_app/imports.dart';
import 'package:collection/collection.dart';

class ComicViewsState extends StateNotifier<List<ComicModel>> {
  ComicViewsState() : super([]);

  void add(ComicModel comic) {
    final indexOf = state.indexWhere((c) => c.comicId == comic.comicId);
    final newState = List<ComicModel>.from(state);
    if (indexOf == -1) {
      newState.add(comic);
      state = newState;
      return;
    }

    newState[indexOf] = comic;
    state = newState;
  }

  ComicModel? get(String id) {
    if (state.isEmpty) return null;
    return state.firstWhereOrNull((c) => c.comicId == id);
  }

  void updateComic(ComicModel comic) {
    final indexOf = state.indexWhere((c) => c.comicId == comic.comicId);
    if (indexOf == -1) return add(comic);
    final newState = List<ComicModel>.from(state);
    newState[indexOf] = comic;
    state = newState;
  }
}

final comicViewsStateProvider = StateNotifierProvider<ComicViewsState, List<ComicModel>>((ref) {
  return ComicViewsState();
});
