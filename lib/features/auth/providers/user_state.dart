import 'dart:developer';

import 'package:atlas_app/features/auth/db/auth_db.dart';
// import 'package:atlas_app/features/profile/db/profile_db.dart';
import 'package:atlas_app/imports.dart';

class UserStateHelper {
  final UserModel? user;
  final bool isLoading;
  final bool hasError;
  final bool isInitlized;
  final String? error;
  UserStateHelper({
    this.user,
    required this.isLoading,
    required this.hasError,
    this.error,
    this.isInitlized = false,
  });

  UserStateHelper copyWith({
    UserModel? user,
    bool? isLoading,
    bool? hasError,
    String? error,
    bool? isInitlized,
  }) {
    return UserStateHelper(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isInitlized: isInitlized ?? this.isInitlized,
      error: error ?? this.error,
    );
  }
}

class UserState extends StateNotifier<UserStateHelper> {
  // ignore: unused_field
  final Ref _ref;

  AuthDb get _db => AuthDb();
  // ProfileDb get _profileDb => ProfileDb();

  UserState({required Ref ref})
    : _ref = ref,
      super(UserStateHelper(isLoading: true, hasError: false));

  SupabaseClient get _client => Supabase.instance.client;

  Future<UserModel?> initlizeUser() async {
    try {
      state = UserStateHelper(isLoading: true, hasError: false);
      if (_client.auth.currentSession == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        state = state.copyWith(isLoading: false);
        return null;
      }
      if (state.isInitlized) {
        await Future.delayed(const Duration(milliseconds: 100));
        state = UserStateHelper(isLoading: false, hasError: false);
        return state.user;
      }
      final userId = _client.auth.currentSession!.user.id;
      UserModel user = await _db.getUserData(userId, withMetadata: true);
      log("user data: $user");
      await Future.delayed(const Duration(milliseconds: 100));
      state = UserStateHelper(user: user, isLoading: false, hasError: false, isInitlized: true);
      return user;
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 100));
      state = UserStateHelper(isLoading: false, hasError: true, error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  void updateState(UserModel? user) {
    state = UserStateHelper(isLoading: false, hasError: false, user: user);
  }

  void clearState() {
    state = UserStateHelper(isLoading: false, hasError: false, user: null);
  }
}

final userState = StateNotifierProvider<UserState, UserStateHelper>((ref) {
  return UserState(ref: ref);
});
