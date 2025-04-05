import 'dart:developer';

import 'package:atlas_app/features/auth/db/auth_db.dart';
import 'package:atlas_app/features/profile/db/profile_db.dart';
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

class UserState extends StateNotifier<UserStateHelper?> {
  // ignore: unused_field
  final Ref _ref;

  AuthDb get _db => AuthDb();
  ProfileDb get _profileDb => ProfileDb();

  UserState({required Ref ref}) : _ref = ref, super(null);

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> initlizeUser() async {
    try {
      state = UserStateHelper(isLoading: true, hasError: false);
      if (_client.auth.currentSession == null) {
        state = null;
        return;
      }

      if (state!.isInitlized) {
        return;
      }

      final userId = _client.auth.currentSession!.user.id;
      UserModel user = await _db.getUserData(userId, withMetadata: true);
      final followsCount = await _profileDb.getFollowsCountString(userId);
      user = user.copyWith(followsCount: followsCount);
      log("user data: $user");
      state = UserStateHelper(user: user, isLoading: false, hasError: false, isInitlized: true);
    } catch (e) {
      state = UserStateHelper(isLoading: false, hasError: true, error: e.toString());
      log(e.toString());
      rethrow;
    }
  }

  void updateState(UserModel user) {
    if (state != null) {
      state = state!.copyWith(user: user);
    } else {
      state = UserStateHelper(isLoading: false, hasError: false, user: user);
    }
  }

  void clearState() {
    state = null;
  }
}

final userState = StateNotifierProvider<UserState, UserStateHelper?>((ref) {
  return UserState(ref: ref);
});
