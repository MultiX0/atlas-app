import 'dart:developer';

import 'package:atlas_app/core/common/constants/function_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/core/common/utils/hashing.dart';
import 'package:atlas_app/features/auth/models/user_metadata.dart';
import 'package:atlas_app/imports.dart';

class AuthDb {
  final client = Supabase.instance.client;
  SupabaseQueryBuilder get _usersTable => client.from(TableNames.users);
  SupabaseQueryBuilder get _usersMetadataTable => client.from(TableNames.users_metadata);

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

      return user0;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String userId, {bool withMetadata = false}) async {
    try {
      if (withMetadata) {
        final data =
            await _usersMetadataTable
                .select("*,${TableNames.users}(*)")
                .eq(KeyNames.userId, userId)
                .maybeSingle();

        if (data != null) {
          final metaData = UserMetadata.fromMap(data);
          final user = UserModel.fromMap(data[TableNames.users]).copyWith(metadata: metaData);
          return user;
        }

        throw Exception("the user metadata is null");
      }

      final data = await _usersTable.select("*").eq(KeyNames.userId, userId).maybeSingle();
      if (data != null) {
        return UserModel.fromMap(data);
      }

      throw Exception("the user is not found");
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
