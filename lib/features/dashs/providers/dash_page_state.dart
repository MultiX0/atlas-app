// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_element
import 'dart:developer';

import 'package:atlas_app/features/dashs/db/dashs_db.dart';
import 'package:atlas_app/features/dashs/models/dash_model.dart';
import 'package:atlas_app/imports.dart';

class _HelperClass {
  final DashModel? dash;
  final bool isLoading;
  final String? error;
  _HelperClass({this.dash, required this.isLoading, this.error});

  _HelperClass copyWith({DashModel? dash, bool? isLoading, String? error}) {
    return _HelperClass(
      dash: dash ?? this.dash,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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

  Future<void> fetchDash({bool refresh = false}) async {
    try {
      if (state.isLoading && refresh) return;
      state = state.copyWith(dash: null, error: null, isLoading: true);
      final data = await _db.getDashById(_dashId);
      state = state.copyWith(dash: data, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(dash: null, error: e.toString(), isLoading: false);
      log(e.toString());
      rethrow;
    }
  }

  void updateDash(DashModel updatedDash) {
    state = state.copyWith(dash: updatedDash);
  }
}

final dashPageStateProvider = StateNotifierProvider.family<DashPageState, _HelperClass, String>((
  ref,
  dashId,
) {
  return DashPageState(ref: ref, dashId: dashId);
});
