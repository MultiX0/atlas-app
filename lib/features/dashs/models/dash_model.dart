// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/features/auth/models/user_model.dart';
import 'package:atlas_app/features/dashs/models/dash_interaction_model.dart';

class DashModel {
  final String id;
  final String? content;
  final String userId;
  final UserModel? user;
  final String image;
  final DashInteractionModel? interaction;
  final DateTime createdAt;
  final bool liked;
  DashModel({
    required this.id,
    this.content,
    required this.userId,
    this.user,
    required this.image,
    this.interaction,
    required this.liked,
    required this.createdAt,
  });

  DashModel copyWith({
    String? id,
    String? content,
    String? userId,
    UserModel? user,
    String? image,
    bool? liked,
    DateTime? createdAt,
    DashInteractionModel? interaction,
  }) {
    return DashModel(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      interaction: interaction ?? this.interaction,
      image: image ?? this.image,
      liked: liked ?? this.liked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DashModel(id: $id, content: $content, userId: $userId, user: $user, image: $image)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.content: content,
      KeyNames.userId: userId,
      // KeyNames.user: user?.toMap(),
      KeyNames.image: image,
      KeyNames.liked: liked,
    };
  }

  factory DashModel.fromMap(Map<String, dynamic> map) {
    return DashModel(
      id: map[KeyNames.id] ?? "",
      content: map[KeyNames.content] != null ? map[KeyNames.content] ?? "" : null,
      userId: map[KeyNames.userId] ?? "",
      user: map[KeyNames.user] != null ? UserModel.fromMap(map[KeyNames.user]) : null,
      image: map[KeyNames.image] ?? "",
      interaction:
          map[KeyNames.interaction] != null
              ? DashInteractionModel.fromMap(map[KeyNames.interaction])
              : null,

      liked: map[KeyNames.liked] ?? false,
      createdAt: DateTime.parse(map[KeyNames.created_at]),
    );
  }

  String toJson() => json.encode(toMap());

  factory DashModel.fromJson(String source) =>
      DashModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
