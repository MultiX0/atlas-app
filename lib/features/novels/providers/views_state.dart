import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:collection/collection.dart';

class NovelViewsState extends StateNotifier<List<NovelModel>> {
  NovelViewsState() : super([]);

  void add(NovelModel novel) {
    final indexOf = state.indexWhere((n) => n.id == novel.id);
    final newState = List<NovelModel>.from(state);
    if (indexOf == -1) {
      newState.add(novel);
      state = newState;
      return;
    }

    newState[indexOf] = novel;
    state = newState;
  }

  NovelModel? get(String id) {
    if (state.isEmpty) return null;
    return state.firstWhereOrNull((n) => n.id == id);
  }

  void updateNovel(NovelModel novel) {
    final indexOf = state.indexWhere((n) => n.id == novel.id);
    if (indexOf == -1) return;
    final newState = List<NovelModel>.from(state);
    newState[indexOf] = novel;
    state = newState;
  }
}

final novelViewsStateProvider = StateNotifierProvider<NovelViewsState, List<NovelModel>>((ref) {
  return NovelViewsState();
});
