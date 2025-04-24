// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class MyWorkModel {
  final String title;
  final String type;
  final String poster;
  final String id;
  MyWorkModel({required this.title, required this.type, required this.poster, required this.id});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'type': type, 'poster': poster};
  }

  factory MyWorkModel.fromMap(Map<String, dynamic> map) {
    return MyWorkModel(
      title: map[KeyNames.title] ?? "",
      type: map[KeyNames.type] ?? "",
      poster: map[KeyNames.poster] ?? "",
      id: map[KeyNames.id] ?? "",
    );
  }

  MyWorkModel copyWith({String? title, String? type, String? poster, String? id}) {
    return MyWorkModel(
      title: title ?? this.title,
      type: type ?? this.type,
      poster: poster ?? this.poster,
      id: id ?? this.id,
    );
  }
}
