// ignore_for_file: public_member_api_docs, sort_constructors_first, library_private_types_in_public_api
import 'dart:developer';

import 'package:atlas_app/features/library/db/library_db.dart';
import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<MyWorkModel> works;
  final String? error;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  _HelperClass({
    required this.works,
    this.error,
    required this.isLoading,
    required this.loadingMore,
    required this.hasReachedEnd,
  });

  _HelperClass copyWith({
    List<MyWorkModel>? works,
    String? error,
    bool? isLoading,
    bool? loadingMore,
    bool? hasReachedEnd,
  }) {
    return _HelperClass(
      works: works ?? this.works,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class MyWorkState extends StateNotifier<_HelperClass> {
  final Ref _ref;
  final String _userId;
  static _HelperClass get empty =>
      _HelperClass(works: [], isLoading: false, loadingMore: false, hasReachedEnd: false);
  MyWorkState({required Ref ref, required String userId})
    : _userId = userId,
      _ref = ref,
      super(empty);
  LibraryDb get _db => _ref.watch(libraryDbProvider);

  void updateState({
    List<MyWorkModel>? works,
    bool? isLoading,
    bool? loadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    state = state.copyWith(
      works: works ?? state.works,
      isLoading: isLoading ?? state.isLoading,
      loadingMore: loadingMore ?? state.loadingMore,
      error: error ?? state.error,
      hasReachedEnd: hasReachedEnd ?? state.hasReachedEnd,
    );
  }

  Future fetchData({bool refresh = false}) async {
    if (!refresh && state.hasReachedEnd) {
      log("reach end of the data");
      return;
    }

    if (state.works.isEmpty || refresh) {
      updateState(error: null, isLoading: true);
    } else {
      updateState(error: null, loadingMore: true, isLoading: false);
    }

    const _pageSize = 15;
    final startIndex = refresh ? 0 : state.works.length;
    final works = await _db.getMyWork(userId: _userId, startAt: startIndex, pageSize: _pageSize);
    final hasReachedEnd = works.length < _pageSize;
    final updatedWorks = refresh ? works : [...state.works, ...works];

    updateState(
      loadingMore: false,
      hasReachedEnd: hasReachedEnd,
      error: null,
      isLoading: false,
      works: updatedWorks,
    );
  }

  void addWork(MyWorkModel work) {
    final isAny = state.works.any((w) => w.title == work.title);
    if (isAny) {
      return;
    }
    final updatedWorks = List<MyWorkModel>.from(state.works);
    updatedWorks.insert(0, work);
    updateState(works: updatedWorks);
  }
}

final myWorksStateProvider = StateNotifierProvider.family<MyWorkState, _HelperClass, String>((
  ref,
  userId,
) {
  return MyWorkState(ref: ref, userId: userId);
});
