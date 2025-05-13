// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novel_preview_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<NovelPreviewModel> novels;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  final int currentPage;
  _HelperClass({
    required this.novels,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.currentPage,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<NovelPreviewModel>? novels,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    int? currentPage,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      novels: novels ?? this.novels,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NovelsExploreState extends StateNotifier<_HelperClass> {
  static _HelperClass get empty => _HelperClass(
    novels: [],
    isLoading: true,
    loadingMore: false,
    hasReachedEnd: false,
    currentPage: 1,
  );

  final Ref _ref;
  final String _userId;

  NovelsExploreState({required Ref ref, required String userId})
    : _ref = ref,
      _userId = userId,
      super(empty);

  NovelsDb get _db => _ref.watch(novelsDbProvider);

  void updateState({
    List<NovelPreviewModel>? novels,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    state = state.copyWith(
      novels: novels ?? state.novels,
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

      if (state.novels.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 20;
      final currentPage = refresh ? 1 : state.currentPage;
      final startIndex = refresh ? 0 : state.novels.length;
      final novels = await _db.getNovelExplore(
        userId: _userId,
        page: currentPage,
        startAt: startIndex,
        pageSize: _pageSize,
      );

      bool hasReachedEnd = novels.length < _pageSize;
      final updatedNovels = refresh ? novels : [...state.novels, ...novels];
      final newPageNumber = refresh ? 1 : state.currentPage + 1;

      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        currentPage: newPageNumber,
        novels: updatedNovels,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final novelExploreProvider = StateNotifierProvider.family<NovelsExploreState, _HelperClass, String>(
  (ref, userId) {
    return NovelsExploreState(ref: ref, userId: userId);
  },
);
