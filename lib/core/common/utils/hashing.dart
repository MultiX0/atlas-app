import 'dart:convert';
import 'dart:math' show Random;
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordHashProvider = StateNotifierProvider<PasswordHash, bool>((ref) => PasswordHash());

class PasswordHash extends StateNotifier<bool> {
  PasswordHash() : super(false);

  // Function to generate a random salt
  String generateSalt([int length = 16]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // Function to hash the password with the salt
  String hashPassword(String password, String salt) {
    final saltedPassword = '$password$salt';
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
