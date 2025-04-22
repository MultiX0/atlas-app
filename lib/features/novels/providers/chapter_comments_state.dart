// ignore_for_file: public_member_api_docs, sort_constructors_first, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novel_chapter_comment_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<NovelChapterCommentWithMeta> comments;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  _HelperClass({
    required this.comments,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<NovelChapterCommentWithMeta>? comments,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      comments: comments ?? this.comments,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class ChapterCommentsState extends StateNotifier<_HelperClass> {
  final Map<int, int> _commentIdToIndex = {};
  static _HelperClass empty = _HelperClass(
    comments: [],
    isLoading: false,
    loadingMore: false,
    hasReachedEnd: false,
  );
  final String _chapterId;
  final Ref _ref;

  ChapterCommentsState({required Ref ref, required String chapterId})
    : _chapterId = chapterId,
      _ref = ref,
      super(empty);

  NovelsDb get _db => _ref.watch(novelsDbProvider);
  void updateState({
    List<NovelChapterCommentWithMeta>? comments,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      comments: comments ?? state.comments,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
    if (comments != null) {
      _commentIdToIndex.clear();
      for (int i = 0; i < comments.length; i++) {
        _commentIdToIndex[comments[i].id] = i;
      }
    }
  }

  Future<void> fetchData({bool refresh = false}) async {
    try {
      if (!refresh && state.hasReachedEnd) {
        log("reach end of the data");
        return;
      }

      if (state.comments.isEmpty || refresh) {
        updateState(error: null, isLoading: true);
      } else {
        updateState(error: null, loadingMore: true, isLoading: false);
      }

      const _pageSize = 20;
      final startIndex = refresh ? 0 : state.comments.length;

      final comments = await _db.getChapterComments(
        chapterId: _chapterId,
        startIndex: startIndex,
        pageSize: _pageSize,
      );

      bool hasReachedEnd = comments.length < _pageSize;
      final updatedComments = refresh ? comments : [...state.comments, ...comments];
      updateState(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        comments: updatedComments,
      );
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      updateState(isLoading: false, error: e.toString(), loadingMore: false);
      rethrow;
    }
  }

  void updateComment(NovelChapterCommentWithMeta comment) {
    int? indexOf = _commentIdToIndex[comment.id];
    if (indexOf == null) {
      indexOf = state.comments.indexWhere((c) => c.id == comment.id);
      if (indexOf == -1) return;
    }

    List<NovelChapterCommentWithMeta> updatedState = List.from(state.comments);
    updatedState[indexOf] = comment;
    updateState(comments: updatedState);
  }

  void addComment(NovelChapterCommentWithMeta comment) {
    List<NovelChapterCommentWithMeta> updatedState = List.from(state.comments);
    updatedState.insert(0, comment);
    updateState(comments: updatedState);
  }

  void deleteComment(NovelChapterCommentWithMeta comment) {
    updateState(comments: state.comments.where((c) => c.id != comment.id).toList());
  }
}

final novelChapterCommentsStateProvider = StateNotifierProvider.family
    .autoDispose<ChapterCommentsState, _HelperClass, String>((ref, chapterId) {
      return ChapterCommentsState(ref: ref, chapterId: chapterId);
    });
