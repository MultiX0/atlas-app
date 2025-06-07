// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element
import 'dart:developer';

import 'package:atlas_app/features/dashs/db/dashs_db.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final List<DashModel> dashs;
  final bool isLoading;
  final bool loadingMore;
  final bool hasReachedEnd;
  final int currentPage;
  final String? error;
  _HelperClass({
    required this.dashs,
    required this.isLoading,
    required this.hasReachedEnd,
    this.error,
    required this.loadingMore,
    required this.currentPage,
  });

  _HelperClass copyWith({
    List<DashModel>? dashs,
    bool? isLoading,
    bool? hasReachedEnd,
    String? error,
    bool? loadingMore,
    int? currentPage,
  }) {
    return _HelperClass(
      dashs: dashs ?? this.dashs,
      isLoading: isLoading ?? this.isLoading,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: error ?? this.error,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class DashsState extends StateNotifier<_HelperClass> {
  // ignore: unused_field
  final String _userId;
  final Ref _ref;

  DashsState({required Ref ref, required String userId})
    : _ref = ref,
      _userId = userId,
      super(
        _HelperClass(
          dashs: [],
          isLoading: true,
          hasReachedEnd: false,
          error: null,
          loadingMore: false,
          currentPage: 1,
        ),
      );

  DashsDb get _db => _ref.read(dashsDBProvider);

  Future<void> fetchData({bool refresh = false}) async {
    try {
      state = state.copyWith(error: null);

      if ((state.hasReachedEnd && !refresh) || state.loadingMore) return;

      if (state.dashs.isEmpty || refresh) {
        state = state.copyWith(error: null, isLoading: true);
      } else {
        state = state.copyWith(error: null, loadingMore: true, isLoading: false);
      }

      const _dashsSize = 15;
      final startIndex = refresh ? 0 : state.dashs.length;

      final newDashs = await _db.getDashs(
        startAt: startIndex,
        pageSize: _dashsSize,
        currentPage: state.currentPage,
        userId: _userId,
      );

      final hasReachedEnd = newDashs.length < _dashsSize;
      final updatedDashs = refresh ? newDashs : [...state.dashs, ...newDashs];
      final currentPage = refresh ? 1 : (state.currentPage + 1);

      state = state.copyWith(
        loadingMore: false,
        hasReachedEnd: hasReachedEnd,
        error: null,
        isLoading: false,
        dashs: updatedDashs,
        currentPage: currentPage,
      );
    } catch (e) {
      log(e.toString());
      state = state.copyWith(error: e.toString(), isLoading: false, loadingMore: false);
    }
  }
}

final dashsStateProvider = StateNotifierProvider.family<DashsState, _HelperClass, String>((
  ref,
  userId,
) {
  return DashsState(ref: ref, userId: userId);
});
