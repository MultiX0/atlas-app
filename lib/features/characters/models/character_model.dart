// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/imports.dart';

class CharacterModel {
  final int id;
  final String fullName;
  final List<String> alternativeNames;
  final String? gender;
  final String? age;
  final String? bloodType;
  final String? description;
  final String? image;
  final String ar_description;

  final int? birth_year;
  final int? birth_month;
  final int? birth_day;

  CharacterModel({
    required this.id,
    required this.fullName,
    required this.alternativeNames,
    this.gender,
    this.age,
    this.bloodType,
    this.description,
    this.image,
    required this.ar_description,
    this.birth_day,
    this.birth_month,
    this.birth_year,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json[KeyNames.id] ?? -1,
      fullName: json[KeyNames.fullName] ?? "",
      alternativeNames: List<String>.from(json[KeyNames.alternative_names] ?? []),
      gender: json[KeyNames.gender] ?? "",
      age: json[KeyNames.age] ?? "",
      bloodType: json[KeyNames.blood_type] ?? "",
      ar_description: json[KeyNames.ar_description] ?? "",
      description: json[KeyNames.description] ?? "",
      image: json[KeyNames.image] ?? "",
      birth_year: json[KeyNames.birth_year],
      birth_day: json[KeyNames.birth_day],
      birth_month: json[KeyNames.birth_month],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      KeyNames.id: id,
      KeyNames.fullName: fullName,
      KeyNames.alternative_names: alternativeNames,
      KeyNames.gender: gender,
      KeyNames.age: age,
      KeyNames.blood_type: bloodType,
      KeyNames.description: description,
      KeyNames.image: image,
      KeyNames.birth_year: birth_year,
      KeyNames.birth_month: birth_month,
      KeyNames.birth_day: birth_day,
      KeyNames.ar_description: ar_description,
    };
  }

  CharacterModel copyWith({
    int? id,
    String? fullName,
    List<String>? alternativeNames,
    String? gender,
    String? age,
    String? bloodType,
    String? description,
    String? image,
    DateTime? birthDate,
    String? ar_description,
    int? birth_year,
    int? birth_month,
    int? birth_day,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bloodType: bloodType ?? this.bloodType,
      description: description ?? this.description,
      image: image ?? this.image,
      ar_description: ar_description ?? this.ar_description,
      birth_day: birth_day ?? this.birth_day,
      birth_month: birth_month ?? this.birth_month,
      birth_year: birth_year ?? this.birth_year,
    );
  }

  @override
  String toString() {
    return 'CharacterModel(id: $id, fullName: $fullName, alternativeNames: $alternativeNames, gender: $gender, age: $age, bloodType: $bloodType, description: $description, image: $image, ar_description: $ar_description)';
  }
}
