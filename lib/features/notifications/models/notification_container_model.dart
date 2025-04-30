// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class NotificationContainerModel {
  final String title;
  final String body;
  final String userId;
  final Map<String, dynamic>? data;
  NotificationContainerModel({
    required this.title,
    required this.body,
    required this.userId,
    this.data,
  });

  NotificationContainerModel copyWith({
    String? title,
    String? body,
    String? userId,
    Map<String, dynamic>? data,
  }) {
    return NotificationContainerModel(
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'body': body, 'user_id': userId, 'data': data};
  }

  factory NotificationContainerModel.fromMap(Map<String, dynamic> map) {
    return NotificationContainerModel(
      title: map['title'] as String,
      body: map['body'] as String,
      userId: map['user_id'] as String,
      data:
          map['data'] != null
              ? Map<String, dynamic>.from((map['data'] as Map<String, dynamic>))
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationContainerModel.fromJson(String source) =>
      NotificationContainerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationContainerModel(title: $title, body: $body, userId: $userId, data: $data)';
  }

  @override
  bool operator ==(covariant NotificationContainerModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.body == body &&
        other.userId == userId &&
        mapEquals(other.data, data);
  }

  @override
  int get hashCode {
    return title.hashCode ^ body.hashCode ^ userId.hashCode ^ data.hashCode;
  }
}
