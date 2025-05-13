// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/comics/db/comics_db.dart';
import 'package:atlas_app/features/comics/models/comic_preview_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:retry/retry.dart';

class _HelperClass {
  final List<ComicPreviewModel> comics;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  final int currentPage;
  _HelperClass({
    required this.comics,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.currentPage,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<ComicPreviewModel>? comics,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    int? currentPage,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      comics: comics ?? this.comics,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ComicsExploreState extends StateNotifier<_HelperClass> {
  static _HelperClass get empty => _HelperClass(
    comics: [],
    isLoading: true,
    loadingMore: false,
    hasReachedEnd: false,
    currentPage: 1,
  );

  final Ref _ref;

  ComicsExploreState({required Ref ref}) : _ref = ref, super(empty);

  ComicsDb get _db => _ref.watch(comicsDBProvider);

  void updateState({
    List<ComicPreviewModel>? comics,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    state = state.copyWith(
      comics: comics ?? state.comics,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
      currentPage: currentPage ?? state.currentPage,
    );
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (state.loadingMore) return;

      if (!refresh && state.hasReachedEnd) {
        log("reach end of the data");
        return;
      }

      if (state.comics.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      await retry(
        maxAttempts: 3,
        delayFactor: const Duration(milliseconds: 400),
        maxDelay: const Duration(milliseconds: 800),
        () async {
          final user = _ref.read(userState.select((s) => s.user!));
          const _pageSize = 20;
          final currentPage = refresh ? 1 : state.currentPage;
          final startIndex = refresh ? 0 : state.comics.length;

          final comics = await _db.getExploreComics(
            pageSize: _pageSize,
            userId: user.userId,
            startAt: startIndex,
            page: currentPage,
          );

          bool hasReachedEnd = comics.length < _pageSize;
          final updatedComics = refresh ? comics : [...state.comics, ...comics];
          final newPageNumber = refresh ? 1 : state.currentPage + 1;

          updateState(
            loadingMore: false,
            hasReachedEnd: hasReachedEnd,
            error: null,
            isLoading: false,
            currentPage: newPageNumber,
            comics: updatedComics,
          );
        },
        retryIf: (e) => e.toString().isNotEmpty,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final comicsExploreProvider = StateNotifierProvider<ComicsExploreState, _HelperClass>((ref) {
  return ComicsExploreState(ref: ref);
});
