// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class UserMetadata {
  final String password;
  final DateTime birthDate;
  final String userId;
  final String email;
  final String salt;

  UserMetadata({
    required this.email,
    required this.password,
    required this.birthDate,
    required this.userId,
    required this.salt,
  });

  UserMetadata copyWith({
    String? password,
    DateTime? birthDate,
    String? userId,
    String? email,
    String? salt,
  }) {
    return UserMetadata(
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      salt: salt ?? this.salt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      KeyNames.userId: userId,
      KeyNames.password: password,
      KeyNames.birthDate: birthDate.toIso8601String(),
      KeyNames.email: email,
      KeyNames.salt: salt,
    };
  }

  factory UserMetadata.fromMap(Map<String, dynamic> map) {
    return UserMetadata(
      email: map[KeyNames.email] ?? "",
      password: map[KeyNames.password] ?? "",
      birthDate: DateTime.parse(map[KeyNames.birthDate]),
      userId: map[KeyNames.userId] ?? "",
      salt: map[KeyNames.salt] ?? "",
    );
  }

  @override
  String toString() {
    return 'UserMetadata(password: $password, birthDate: $birthDate, userId: $userId, email: $email, salt: $salt)';
  }
}
