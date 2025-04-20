// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<ChapterDraftModel> drafts;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  _HelperClass({
    required this.drafts,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<ChapterDraftModel>? drafts,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      drafts: drafts ?? this.drafts,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class NovelChapterDrafts extends StateNotifier<_HelperClass> {
  static _HelperClass get empty =>
      _HelperClass(drafts: [], isLoading: false, loadingMore: false, hasReachedEnd: false);

  final String _novelId;
  final Ref _ref;
  NovelChapterDrafts({required Ref ref, required String novelId})
    : _novelId = novelId,
      _ref = ref,
      super(empty);

  NovelsDb get _db => _ref.watch(novelsDbProvider);

  void updateState({
    List<ChapterDraftModel>? drafts,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      drafts: drafts ?? state.drafts,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (!refresh && state.hasReachedEnd) {
        log("reach end of the data");
        return;
      }

      if (state.drafts.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 20;
      final startIndex = refresh ? 0 : state.drafts.length;
      final drafts = await _db.getDrafts(
        novelId: _novelId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      bool hasReachedEnd = drafts.length < _pageSize;
      final updatedDrafts = refresh ? drafts : [...state.drafts, ...drafts];

      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        drafts: updatedDrafts,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void addDraft(ChapterDraftModel draft) {
    updateState(drafts: [draft, ...state.drafts]);
  }

  void removeDraft(ChapterDraftModel draft) {
    List<ChapterDraftModel> updatedDrafts = List.from(state.drafts);
    updatedDrafts.removeWhere((d) => d.id == draft.id);
    updateState(drafts: updatedDrafts);
  }

  void updateDraft(ChapterDraftModel draft) {
    final indexOf = state.drafts.indexWhere((d) => d.id == draft.id);
    if (indexOf == -1) {
      addDraft(draft);
      return;
    }
    List<ChapterDraftModel> updatedDrafts = List.from(state.drafts);
    updatedDrafts[indexOf] = draft;
    updateState(drafts: updatedDrafts);
  }
}

final novelChapterDraftsProvider =
    StateNotifierProvider.family<NovelChapterDrafts, _HelperClass, String>((ref, novelId) {
      return NovelChapterDrafts(ref: ref, novelId: novelId);
    });
