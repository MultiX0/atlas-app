import 'package:atlas_app/core/common/constants/key_names.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class PostReportModel {
  final String postId;
  final String userId;
  final String content;
  PostReportModel({required this.postId, required this.userId, required this.content});

  PostReportModel copyWith({String? postId, String? userId, String? content}) {
    return PostReportModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.post_id: postId,
      KeyNames.userId: userId,
      KeyNames.reason: content,
    };
  }

  factory PostReportModel.fromMap(Map<String, dynamic> map) {
    return PostReportModel(
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
    );
  }
}
