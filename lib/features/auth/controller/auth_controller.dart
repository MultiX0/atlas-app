import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/auth/db/auth_db.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/imports.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref: ref);
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  AuthController({required Ref ref}) : _ref = ref, super(false);

  AuthDb get _db => AuthDb();

  Future<void> login({required String email, required String password}) async {
    try {
      state = true;
      await _db.login(email: email, password: password);
      _ref.read(userState.notifier).initlizeUser();
      state = false;
    } catch (e) {
      state = false;
      log(e.toString());
      if (e.toString().toLowerCase().contains(("Invalid login credentials").toLowerCase())) {
        CustomToast.error("email or password is incorrect");
      } else {
        CustomToast.error(e);
      }
      rethrow;
    }
  }

  Future<void> signUp() async {
    try {
      state = true;
      final localUser = _ref.read(localUserModel);
      final user = await _db.signUp(localUser!);
      CustomToast.success("Welcome to Atlas! Your journey starts now.");
      _ref.read(userState.notifier).updateState(user);
      state = false;
    } catch (e) {
      state = false;
      log(e.toString());
      CustomToast.error(e);
      rethrow;
    }
  }

  Future<bool> isEmailTaken(String email) async {
    try {
      state = true;
      final isTaken = await _db.isEmailAlreadyRegistered(email);
      state = false;
      return isTaken;
    } catch (e) {
      state = false;
      log(e.toString());
      CustomToast.error(e);
      throw Exception(e);
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    try {
      state = true;
      final isTaken = await _db.isUsernameTaken(username);
      state = false;
      return isTaken;
    } catch (e) {
      state = false;
      log(e.toString());
      CustomToast.error(e);
      throw Exception(e);
    }
  }
}
