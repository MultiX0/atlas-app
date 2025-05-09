import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/constants/view_names.dart';
import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/encrypt.dart';
import 'package:atlas_app/core/common/utils/hashing.dart';
import 'package:atlas_app/core/services/secure_storage_service.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) => event);
});

class IsLoggedState extends StateNotifier<bool> {
  IsLoggedState() : super(Supabase.instance.client.auth.currentSession != null);

  void updateState(bool isLogged) {
    state = isLogged;
  }
}

final isLoggedProvider = StateNotifierProvider<IsLoggedState, bool>((ref) {
  return IsLoggedState();
});

class AuthDb {
  final client = Supabase.instance.client;
  SupabaseQueryBuilder get _usersTable => client.from(TableNames.users);
  SupabaseQueryBuilder get _usersView => client.from(ViewNames.user_profiles_view);
  SupabaseQueryBuilder get _usersMetadataTable => client.from(TableNames.users_metadata);
  static Dio get _dio => Dio();

  Future<UserModel?> login({required String email, required String password}) async {
    try {
      final credintial = await client.auth.signInWithPassword(password: password, email: email);
      if (credintial.session == null) return null;
      return getUserData(credintial.session!.user.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final data = await client.rpc(
        FunctionNames.check_email_exists,
        params: {'user_email': email},
      );

      return data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    //TODO in the future make usernames queue in the backend so never will be multiple users take the same username during the registration
    try {
      final data = await client.rpc(
        FunctionNames.check_username_exists,
        params: {'user_username': username},
      );

      return data;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signUp(UserModel user) async {
    try {
      final credentials = await client.auth.signUp(
        password: user.metadata!.password,
        email: user.metadata!.email,
      );

      final salt = PasswordHash().generateSalt();
      final hashedPassword = PasswordHash().hashPassword(user.metadata!.password, salt);

      final user0 = user.copyWith(
        userId: credentials.user!.id,
        metadata: user.metadata?.copyWith(
          password: hashedPassword,
          salt: salt,
          userId: credentials.user!.id,
        ),
      );

      await _usersTable.insert(user0.toMap());
      await _usersMetadataTable.insert(user0.metadata!.toMap());
      final _user = await getUserData(user0.userId);

      return _user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String userId) async {
    try {
      var query = _usersView.select("*");
      if (userId.length == 36) {
        query = query.eq(KeyNames.id, userId);
      } else {
        query = query.eq(KeyNames.username, userId);
      }

      var data = await query.maybeSingle();

      if (data != null) {
        return UserModel.fromMap(data);
      }

      throw Exception("the user is not found");
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final secureStorage = SecureLocalStorage();
      final session = await secureStorage.getSession();
      await client.auth.signOut();
      if (session != null) {
        await secureStorage.delete(session);
        await secureStorage.removePersistedSession();
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> sendOTP({required String email, required String name}) async {
    try {
      final authHeaders = await generateAuthHeaders();
      final _options = Options(headers: authHeaders);
      final res = await _dio.post('${appAPI}send-otp?email=$email&name=$name', options: _options);
      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        log("success");
        CustomToast.success("تم ارسال رمز التحقق الى بريدك الألكتروني بنجاح");
        return;
      }
      throw Exception();
    } catch (e) {
      CustomToast.error(errorMsg);

      log(e.toString());
      rethrow;
    }
  }

  Future<void> verificationCheck({
    required String email,
    required String password,
    required String verificationCode,
  }) async {
    try {
      log(verificationCode);
      final authHeaders = await generateAuthHeaders();
      final _options = Options(headers: authHeaders);
      final encryptedPassword = encryptMessage(password);
      log(encryptedPassword);
      final res = await _dio.post(
        '${appAPI}change-password',
        options: _options,
        data: {
          "email": email.toLowerCase().trim(),
          "verification_code": verificationCode,
          "password": encryptedPassword,
        },
      );

      if (res.statusCode! >= 200 && res.statusCode! <= 299) {
        CustomToast.success("تمت العملية بنجاح");
        return;
      }
      throw Exception();
    } catch (e) {
      CustomToast.error("الكود اللذي أدخلته غير صحيح");
      log(e.toString());
      rethrow;
    }
  }
}
