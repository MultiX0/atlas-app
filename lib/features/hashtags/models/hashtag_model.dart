import 'package:atlas_app/core/common/constants/key_names.dart';

class HashtagModel {
  final String hashtag;
  final int postCount;
  HashtagModel({required this.hashtag, required this.postCount});

  HashtagModel copyWith({String? hashtag, int? postCount}) {
    return HashtagModel(hashtag: hashtag ?? this.hashtag, postCount: postCount ?? this.postCount);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'hashtag': hashtag, 'postCount': postCount};
  }

  factory HashtagModel.fromMap(Map<String, dynamic> map) {
    return HashtagModel(
      hashtag: map[KeyNames.hashtag] ?? "",
      postCount: map[KeyNames.post_count] ?? 0,
    );
  }

  @override
  String toString() => 'HashtagModel(hashtag: $hashtag, postCount: $postCount)';

  @override
  bool operator ==(covariant HashtagModel other) {
    if (identical(this, other)) return true;

    return other.hashtag == hashtag && other.postCount == postCount;
  }

  @override
  int get hashCode => hashtag.hashCode ^ postCount.hashCode;
}
