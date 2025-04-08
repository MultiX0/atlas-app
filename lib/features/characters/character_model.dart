// ignore_for_file: public_member_api_docs, sort_constructors_first
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
      id: json['id'] ?? -1,
      fullName: json['full_name'] ?? "",
      alternativeNames: List<String>.from(json['alternative_names'] ?? []),
      gender: json['gender'] ?? "",
      age: json['age'] ?? "",
      bloodType: json['blood_type'] ?? "",
      ar_description: json["ar_description"] ?? "",
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      birth_year: json['birth_year'],
      birth_day: json['birth_day'],
      birth_month: json['birth_month'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'alternative_names': alternativeNames,
      'gender': gender,
      'age': age,
      'blood_type': bloodType,
      'description': description,
      'image': image,
      'birth_year': birth_year,
      'birth_month': birth_month,
      'birth_day': birth_day,
      'ar_description': ar_description,
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
