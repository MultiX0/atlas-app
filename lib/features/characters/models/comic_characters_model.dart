// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:atlas_app/core/common/constants/key_names.dart';
import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/characters/models/character_model.dart';

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
      id: json[KeyNames.id],
      comicId: json[KeyNames.comic_id],
      characterId: json[KeyNames.character_id],
      role: json[KeyNames.role],
      character: CharacterModel.fromJson(json[KeyNames.character]),
    );
  }

  factory ComicCharacterModel.fromDB(Map<String, dynamic> json) {
    return ComicCharacterModel(
      id: json[KeyNames.id],
      comicId: json[KeyNames.comic_id],
      characterId: json[KeyNames.character_id],
      role: json[KeyNames.role],
      character: CharacterModel.fromJson(json[TableNames.characters]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      KeyNames.id: id,
      KeyNames.comic_id: comicId,
      KeyNames.character_id: characterId,
      KeyNames.role: role,
      KeyNames.character: character?.toJson(),
    };
  }

  Map<String, dynamic> toDB() {
    return {
      KeyNames.id: id,
      KeyNames.comic_id: comicId,
      KeyNames.character_id: characterId,
      KeyNames.role: role,
    };
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
