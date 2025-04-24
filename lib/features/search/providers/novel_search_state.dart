// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/search/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class NovelSearchStateHelper {
  final List<NovelModel> novels;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachEnd;
  final String? error;
  NovelSearchStateHelper({
    required this.novels,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachEnd,
    this.error,
  });

  NovelSearchStateHelper copyWith({
    List<NovelModel>? novels,
    bool? isLoading,
    bool? loadingMore,
    bool? hasReachEnd,
    String? error,
  }) {
    return NovelSearchStateHelper(
      novels: novels ?? this.novels,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachEnd: hasReachEnd ?? this.hasReachEnd,
      error: error ?? this.error,
    );
  }
}

class NovelSearchState extends StateNotifier<NovelSearchStateHelper> {
  // ignore: unused_field
  final Ref _ref;
  NovelSearchState({required Ref ref})
    : _ref = ref,
      super(
        NovelSearchStateHelper(
          novels: [],
          isLoading: false,
          hasReachEnd: false,
          loadingMore: false,
        ),
      );

  void updateState({
    List<NovelModel>? novels,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      novels: novels ?? state.novels,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachEnd: hasReachedEnd ?? state.hasReachEnd,
    );
  }

  void handleLoading(bool loadig) {
    state = state.copyWith(isLoading: loadig);
  }

  void reset() {
    state = state.copyWith(isLoading: false, error: null, novels: []);
  }

  void updatenovels(List<NovelModel> novels) {
    state = state.copyWith(novels: novels);
  }

  void handleError(String? error) {
    state = state.copyWith(error: error);
  }

  void search({bool refresh = false}) async {
    try {
      final query = _ref.read(searchQueryProvider);
      if (!refresh && state.hasReachEnd) {
        log("reach end of the data");
        return;
      }

      if (state.novels.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }
      const pageSize = 15;
      final startIndex = refresh ? 0 : state.novels.length;
      final novels = await _ref
          .read(novelsDbProvider)
          .searchNovels(query: query, pageSize: pageSize, startIndex: startIndex);
      final updatedNovels = refresh ? novels : [...state.novels, ...novels];
      bool hasReachEnd = pageSize > novels.length;
      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachEnd,
        error: null,
        isLoading: false,
        novels: updatedNovels,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final novelSearchStateProvider = StateNotifierProvider<NovelSearchState, NovelSearchStateHelper>((
  ref,
) {
  return NovelSearchState(ref: ref);
});
