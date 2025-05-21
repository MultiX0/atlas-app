// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element
import 'dart:developer';

import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/providers/chapters_state.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final ChapterModel? chapter;
  final bool isLoading;
  final String? error;
  _HelperClass({required this.chapter, required this.isLoading, this.error});

  _HelperClass copyWith({ChapterModel? chapter, bool? isLoading, String? error}) {
    return _HelperClass(
      chapter: chapter ?? this.chapter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChapterState extends StateNotifier<_HelperClass> {
  final String _chapterId;
  final Ref _ref;

  ChapterState({required Ref ref, required String chapterId})
    : _chapterId = chapterId,
      _ref = ref,
      super(_HelperClass(chapter: null, isLoading: true));

  NovelsDb get _novelDb => _ref.read(novelsDbProvider);

  Future<ChapterModel> fetchData() async {
    try {
      state = state.copyWith(isLoading: true);
      final chapterData = await _novelDb.getChapterById(chapterId: _chapterId);
      final allChapters = _ref.read(chaptersStateProvider(chapterData.novelId));
      if (allChapters.chapters.isEmpty) {
        await _ref
            .read(chaptersStateProvider(chapterData.novelId).notifier)
            .fetchData(refresh: true);
      }
      state = state.copyWith(isLoading: false, chapter: chapterData, error: null);

      return chapterData;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  void updateChapter(ChapterModel newChapter) {
    state = state.copyWith(chapter: newChapter);
  }
}

final chapterStateProvider = StateNotifierProvider.family<ChapterState, _HelperClass, String>((
  ref,
  chapterId,
) {
  return ChapterState(ref: ref, chapterId: chapterId);
});
