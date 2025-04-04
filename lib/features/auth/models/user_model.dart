// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/features/auth/models/user_metadata.dart';
import 'package:atlas_app/features/profile/models/follows_model.dart';

class UserModel {
  final String fullName;
  final String username;
  final String userId;
  final String avatar;
  final String banner;
  final FollowsCountModel? followsCount;
  final UserMetadata? metadata;
  UserModel({
    required this.fullName,
    required this.username,
    required this.userId,
    required this.avatar,
    required this.banner,
    this.metadata,
    this.followsCount,
  });

  UserModel copyWith({
    String? fullName,
    String? username,
    String? userId,
    String? avatar,
    UserMetadata? metadata,
    FollowsCountModel? followsCount,
    String? banner,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
      metadata: metadata ?? this.metadata,
      banner: banner ?? this.banner,
      followsCount: followsCount ?? this.followsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.fullName: fullName,
      KeyNames.username: username,
      KeyNames.id: userId,
      KeyNames.avatar: avatar,
      KeyNames.banner: banner,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map[KeyNames.fullName] ?? "",
      username: map[KeyNames.username] ?? "",
      userId: map[KeyNames.id] ?? "",
      avatar: map[KeyNames.avatar] ?? "",
      banner: map[KeyNames.banner] ?? "",
      // metadata: UserMetadata.fromMap(map['metadata'] as Map<String, dynamic>),
    );
  }

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
