// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/features/auth/models/user_metadata.dart';

class UserModel {
  final String fullName;
  final String username;
  final String userId;
  final String avatar;
  final UserMetadata metadata;
  UserModel({
    required this.fullName,
    required this.username,
    required this.userId,
    required this.avatar,
    required this.metadata,
  });

  UserModel copyWith({
    String? fullName,
    String? username,
    String? userId,
    String? avatar,
    UserMetadata? metadata,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'username': username,
      'userId': userId,
      'avatar': avatar,
      'metadata': metadata.toMap(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      userId: map['userId'] as String,
      avatar: map['avatar'] as String,
      metadata: UserMetadata.fromMap(map['metadata'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(fullName: $fullName, username: $username, userId: $userId, avatar: $avatar, metadata: $metadata)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.fullName == fullName &&
        other.username == username &&
        other.userId == userId &&
        other.avatar == avatar &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        username.hashCode ^
        userId.hashCode ^
        avatar.hashCode ^
        metadata.hashCode;
  }
}
