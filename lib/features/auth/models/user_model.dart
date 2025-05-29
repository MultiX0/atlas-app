// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/features/auth/models/user_metadata.dart';

class UserModel {
  final String fullName;
  final String username;
  final String userId;
  final String avatar;
  final String banner;
  final String? bio;
  final UserMetadata? metadata;
  final int followers_count;
  final int following_count;
  final bool? is_follow_me;
  final bool? followed;
  final int postsCount;
  final bool isAdmin;
  final bool official;
  UserModel({
    required this.fullName,
    required this.username,
    required this.userId,
    required this.avatar,
    required this.banner,
    required this.postsCount,
    this.official = false,
    this.bio,
    this.metadata,
    required this.followers_count,
    required this.following_count,
    this.isAdmin = false,
    this.is_follow_me,
    this.followed,
  });

  factory UserModel.newUser(UserModel user) {
    return UserModel(
      fullName: user.fullName,
      followers_count: user.followers_count,
      following_count: user.following_count,
      bio: user.bio,
      followed: user.followed,
      postsCount: user.postsCount,
      is_follow_me: user.is_follow_me,
      metadata: user.metadata,
      username: user.username,
      userId: user.userId,
      avatar: user.avatar,
      banner: user.banner,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.fullName: fullName,
      KeyNames.username: username,
      KeyNames.id: userId,
      KeyNames.avatar: avatar,
      KeyNames.banner: banner,
      KeyNames.bio: bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map[KeyNames.fullName] ?? "",
      username: map[KeyNames.username] ?? "",
      userId: map[KeyNames.id] ?? "",
      avatar: map[KeyNames.avatar] ?? "",
      banner: map[KeyNames.banner] ?? "",
      bio: map[KeyNames.bio],
      followers_count: map[KeyNames.followers_count] ?? 0,
      following_count: map[KeyNames.following_count] ?? 0,
      followed: map[KeyNames.followed] ?? false,
      is_follow_me: map[KeyNames.is_follow_me] ?? false,
      metadata:
          map[KeyNames.metadata] == null ? null : UserMetadata.fromMap(map[KeyNames.metadata]),
      postsCount: map[KeyNames.posts_count] ?? 0,
      isAdmin: map[KeyNames.is_admin] ?? false,
      official: map[KeyNames.official] ?? false,

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

  UserModel copyWith({
    String? fullName,
    String? username,
    String? userId,
    String? avatar,
    String? banner,
    String? bio,
    UserMetadata? metadata,
    int? followers_count,
    int? following_count,
    bool? is_follow_me,
    bool? followed,
    int? postsCount,
    bool? isAdmin,
    bool? official,
  }) {
    return UserModel(
      official: official ?? this.official,
      isAdmin: isAdmin ?? this.isAdmin,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
      banner: banner ?? this.banner,
      bio: bio ?? this.bio,
      metadata: metadata ?? this.metadata,
      followers_count: followers_count ?? this.followers_count,
      following_count: following_count ?? this.following_count,
      is_follow_me: is_follow_me ?? this.is_follow_me,
      followed: followed ?? this.followed,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}
