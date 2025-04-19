// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class MyWorkModel {
  final String title;
  final String type;
  final String poster;
  MyWorkModel({required this.title, required this.type, required this.poster});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'type': type, 'poster': poster};
  }

  factory MyWorkModel.fromMap(Map<String, dynamic> map) {
    return MyWorkModel(
      title: map[KeyNames.title] ?? "",
      type: map[KeyNames.type] ?? "",
      poster: map[KeyNames.poster] ?? "",
    );
  }

  MyWorkModel copyWith({String? title, String? type, String? poster}) {
    return MyWorkModel(
      title: title ?? this.title,
      type: type ?? this.type,
      poster: poster ?? this.poster,
    );
  }
}
