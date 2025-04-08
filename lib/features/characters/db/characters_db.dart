import 'dart:developer';

import 'package:atlas_app/core/common/constants/table_names.dart';
import 'package:atlas_app/features/characters/character_model.dart';
import 'package:atlas_app/features/characters/pages/comic_characters.dart';
import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/translate/translate_service.dart';
import 'package:atlas_app/imports.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

final characterDbProvider = Provider<CharactersDb>((ref) {
  return CharactersDb();
});

class CharactersDb {
  SupabaseClient get _client => Supabase.instance.client;
  SupabaseQueryBuilder get _charactersTable => _client.from(TableNames.characters);
  SupabaseQueryBuilder get _comicCharactersTable => _client.from(TableNames.comic_characters);

  TranslationService get _translationService => TranslationService();

  final uuid = const Uuid();

  Future<void> insertCharacters(List<CharacterModel> characters) async {
    try {
      final uniqueCharactersMap = {for (var c in characters) c.id: c.toJson()}.values.toList();
      await _charactersTable.upsert(
        uniqueCharactersMap,
        onConflict: KeyNames.id,
        ignoreDuplicates: false,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleInsertCharacters(
    ComicModel comic,
    List<Map<String, dynamic>> charactersMap,
  ) async {
    try {
      if (charactersMap.isEmpty) return;

      final charactersComicData = charactersMap.firstWhere(
        (map) => map["comic_ani_id"] == comic.aniId,
      );

      final characters = List<CharacterModel>.from(
        (charactersComicData['characters'] as List<Map<String, dynamic>>)
            .map((char) => CharacterModel.fromJson(char["character"]))
            .toList(),
      );

      log("THERE IS ${characters.length} FOR THR COMIC (${comic.comicId})");
      log("CHARACTERS FOR ${comic.englishTitle}:");
      for (final char in characters) {
        log(char.fullName);
      }

      final _translatedChars = await translateCharacterDescription(characters);

      List<ComicCharacterModel> _comicCharacters = [];

      for (int i = 0; i < _translatedChars.length; i++) {
        final char = _translatedChars[i];

        _comicCharacters.add(
          ComicCharacterModel(
            id: uuid.v4(),
            comicId: comic.comicId,
            characterId: char.id,
            role: charactersComicData["characters"][i]["role"],
            character: char,
          ),
        );
      }

      await insertCharacters(_translatedChars);
      await insertComicsCharacters(_comicCharacters);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertComicsCharacters(List<ComicCharacterModel> _comicCharacters) async {
    try {
      await _comicCharactersTable.upsert(_comicCharacters.map((char) => char.toDB()).toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<CharacterModel>> translateCharacterDescription(
    List<CharacterModel> characters,
  ) async {
    final List<Future<CharacterModel>> translationTasks =
        characters.map((char) async {
          try {
            if (char.ar_description.trim().isNotEmpty) return char;
            if (char.description == null || (char.description ?? "").isEmpty) {
              return char;
            }

            final ogDescriptionLang = langdetect.detect(char.description!);
            final arDescription = await _translationService.translate(
              ogDescriptionLang,
              'ar',
              char.description!,
            );

            if (arDescription.trim().toLowerCase().contains("translation failed")) {
              return char;
            }

            return char.copyWith(ar_description: arDescription);
          } catch (e) {
            log(e.toString());
            return char;
          }
        }).toList();

    return await Future.wait(translationTasks);
  }
}
