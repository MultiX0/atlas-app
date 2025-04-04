// ignore_for_file: public_member_api_docs, sort_constructors_first

class FollowsCountModel {
  final String followers;
  final String following;
  FollowsCountModel({required this.followers, required this.following});

  FollowsCountModel copyWith({String? followers, String? following}) {
    return FollowsCountModel(
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  factory FollowsCountModel.fromMap(Map<String, dynamic> map) {
    return FollowsCountModel(
      followers: map['followers_count'] ?? "0",
      following: map['following_count'] ?? "0",
    );
  }

  @override
  String toString() => 'FollowsModel(followers: $followers, following: $following)';

  @override
  bool operator ==(covariant FollowsCountModel other) {
    if (identical(this, other)) return true;

    return other.followers == followers && other.following == following;
  }

  @override
  int get hashCode => followers.hashCode ^ following.hashCode;
}
