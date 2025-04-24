// ignore_for_file: public_member_api_docs, sort_constructors_first, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _HelperClass {
  final List<ChapterModel> chapters;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  _HelperClass({
    required this.chapters,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<ChapterModel>? chapters,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      chapters: chapters ?? this.chapters,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class ChaptersState extends StateNotifier<_HelperClass> {
  final Map<String, int> _chapterIdToIndex = {};
  static _HelperClass empty = _HelperClass(
    chapters: [],
    isLoading: false,
    loadingMore: false,
    hasReachedEnd: false,
  );
  final String _novelId;
  final Ref _ref;

  ChaptersState({required String novelId, required Ref ref})
    : _novelId = novelId,
      _ref = ref,
      super(empty);
  NovelsDb get _db => _ref.watch(novelsDbProvider);

  void updateState({
    List<ChapterModel>? chapters,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      chapters: chapters ?? state.chapters,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
    if (chapters != null) {
      _chapterIdToIndex.clear();
      for (int i = 0; i < chapters.length; i++) {
        _chapterIdToIndex[chapters[i].id] = i;
      }
    }
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (!refresh && state.hasReachedEnd) {
        log("reach end of the data");
        return;
      }

      if (state.chapters.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 100;
      final startIndex = refresh ? 0 : state.chapters.length;
      final chapters = await _db.getChapters(
        novelId: _novelId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      bool hasReachedEnd = chapters.length < _pageSize;
      final updatedChapters = refresh ? chapters : [...state.chapters, ...chapters];
      updatedChapters.sort((a, b) => b.number.compareTo(a.number));

      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        chapters: updatedChapters,
      );
    } catch (e) {
      updateState(isLoading: false, loadingMore: false, error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  void deleteChapter(String id) {
    updateState(chapters: state.chapters.where((c) => c.id != id).toList());
  }

  void addChapter(ChapterModel chapter) {
    final updatedState = List<ChapterModel>.from(state.chapters);
    updatedState.add(chapter);
    updatedState.sort((a, b) => b.number.compareTo(a.number));
    updateState(chapters: updatedState);
  }

  void updateChapter(ChapterModel chapter) {
    final indexOf = state.chapters.indexWhere((c) => c.id == chapter.id);
    if (indexOf == -1) {
      addChapter(chapter);
      return;
    }
    List<ChapterModel> updatedChapters = List.from(state.chapters);
    updatedChapters[indexOf] = chapter;
    updateState(chapters: updatedChapters);
  }

  bool isLast(String id) {
    if (state.chapters.isEmpty) return false;
    final index = _chapterIdToIndex[id];
    if (index == null) return false;
    return index == 0;
  }

  bool isFirst(String id) {
    if (state.chapters.isEmpty) return false;
    final index = _chapterIdToIndex[id];
    if (index == null) return false;
    return index == state.chapters.length - 1;
  }

  ChapterModel? getNext(String id) {
    if (isLast(id)) return null;
    final index = _chapterIdToIndex[id] ?? 1;
    final nextIndex = index - 1;
    return state.chapters[nextIndex];
  }

  ChapterModel? getPrev(String id) {
    if (isFirst(id)) return null;
    final index = _chapterIdToIndex[id] ?? 0;
    final prevIndex = index + 1;
    return state.chapters[prevIndex];
  }
}

final chaptersStateProvider = StateNotifierProvider.family<ChaptersState, _HelperClass, String>((
  ref,
  novelId,
) {
  return ChaptersState(novelId: novelId, ref: ref);
});
