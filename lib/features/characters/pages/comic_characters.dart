// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/characters/character_model.dart';

class ComicCharacterModel {
  final String id;
  final String comicId;
  final int characterId;
  final String role;
  final CharacterModel? character;

  ComicCharacterModel({
    required this.id,
    required this.comicId,
    required this.characterId,
    required this.role,
    this.character,
  });

  factory ComicCharacterModel.fromJson(Map<String, dynamic> json) {
    return ComicCharacterModel(
      id: json['id'],
      comicId: json['comic_id'],
      characterId: json['character_id'],
      role: json['role'],
      character: CharacterModel.fromJson(json['character']),
    );
  }

  factory ComicCharacterModel.fromDB(Map<String, dynamic> json) {
    return ComicCharacterModel(
      id: json['id'],
      comicId: json['comic_id'],
      characterId: json['character_id'],
      role: json['role'],
      character: CharacterModel.fromJson(json[TableNames.characters]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comic_id': comicId,
      'character_id': characterId,
      'role': role,
      'character': character?.toJson(),
    };
  }

  Map<String, dynamic> toDB() {
    return {'id': id, 'comic_id': comicId, 'character_id': characterId, 'role': role};
  }

  ComicCharacterModel copyWith({
    String? id,
    String? comicId,
    int? characterId,
    String? role,
    CharacterModel? character,
  }) {
    return ComicCharacterModel(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      characterId: characterId ?? this.characterId,
      role: role ?? this.role,
      character: character ?? this.character,
    );
  }
}
