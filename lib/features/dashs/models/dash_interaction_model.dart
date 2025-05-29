import 'dart:convert';

import 'package:atlas_app/core/common/constants/key_names.dart';

class DashInteractionModel {
  final String dashId;
  final String user_id;
  final int time_spent;
  final bool liked;
  DashInteractionModel({
    required this.dashId,
    required this.user_id,
    required this.time_spent,
    required this.liked,
  });

  DashInteractionModel copyWith({String? dashId, String? user_id, int? time_spent, bool? liked}) {
    return DashInteractionModel(
      dashId: dashId ?? this.dashId,
      user_id: user_id ?? this.user_id,
      time_spent: time_spent ?? this.time_spent,
      liked: liked ?? this.liked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.dash_id: dashId,
      KeyNames.userId: user_id,
      KeyNames.time_spent: time_spent,
      KeyNames.liked: liked,
    };
  }

  factory DashInteractionModel.fromMap(Map<String, dynamic> map) {
    return DashInteractionModel(
      dashId: map[KeyNames.dash_id] ?? "",
      user_id: map[KeyNames.userId] ?? "",
      time_spent: map[KeyNames.time_spent] ?? 0,
      liked: map[KeyNames.liked] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory DashInteractionModel.fromJson(String source) =>
      DashInteractionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
