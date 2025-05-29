// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element
import 'dart:developer';

import 'package:atlas_app/features/dashs/db/dashs_db.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final DashModel? dash;
  final bool isLoading;
  final List<DashModel> recommendations;
  final bool loadingMore;
  final bool hasReachEnd;
  final int currentPage;
  final String? error;
  _HelperClass({
    this.dash,
    required this.isLoading,
    this.error,
    this.recommendations = const [],
    this.loadingMore = false,
    this.currentPage = 1,
    this.hasReachEnd = false,
  });

  _HelperClass copyWith({
    DashModel? dash,
    bool? isLoading,
    String? error,
    List<DashModel>? recommendations,
    bool? loadingMore,
    bool? hasReachEnd,
    int? currentPage,
  }) {
    return _HelperClass(
      dash: dash ?? this.dash,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      recommendations: recommendations ?? this.recommendations,
      hasReachEnd: hasReachEnd ?? this.hasReachEnd,
      loadingMore: loadingMore ?? this.loadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class DashPageState extends StateNotifier<_HelperClass> {
  final Ref _ref;
  final String _dashId;

  DashPageState({required Ref ref, required String dashId})
    : _ref = ref,
      _dashId = dashId,
      super(_HelperClass(dash: null, isLoading: true, error: null));

  DashsDb get _db => _ref.read(dashsDBProvider);

  Future<void> fetchDash({bool refresh = false, bool loadMore = false}) async {
    try {
      if (state.isLoading && refresh) return;
      if (loadMore) return fetchRecommendations(loadingMore: loadMore);
      state = state.copyWith(dash: null, error: null, isLoading: true);
      final results = await Future.wait<dynamic>([
        _db.getDashById(_dashId),
        fetchRecommendations(loadingMore: loadMore),
      ]);
      final data = results[0];
      state = state.copyWith(dash: data, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(dash: null, error: e.toString(), isLoading: false);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> fetchRecommendations({bool loadingMore = false}) async {
    try {
      if (state.hasReachEnd) return;
      state = state.copyWith(loadingMore: loadingMore);
      const pageSize = 20;
      final me = _ref.read(userState.select((s) => s.user!));
      final recommendations = await _db.getRecommendationsBasedOnDash(
        dashId: _dashId,
        page: state.currentPage,
        userId: me.userId,
      );

      final hasReachEnd = recommendations.length < pageSize;
      state = state.copyWith(
        loadingMore: false,
        currentPage: (state.currentPage + 1),
        recommendations: [...state.recommendations, ...recommendations],
        hasReachEnd: hasReachEnd,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  void updateDash(DashModel updatedDash) {
    state = state.copyWith(dash: updatedDash);
  }
}

final dashPageStateProvider = StateNotifierProvider.family
    .autoDispose<DashPageState, _HelperClass, String>((ref, dashId) {
      return DashPageState(ref: ref, dashId: dashId);
    });
