import 'dart:developer';

import 'package:atlas_app/features/characters/models/character_model.dart';
import 'package:atlas_app/features/translate/translate_service.dart';
import 'package:atlas_app/imports.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

final characterDbProvider = Provider<CharactersDb>((ref) {
  return CharactersDb();
});

class CharactersDb {
  TranslationService get _translationService => TranslationService();

  final uuid = const Uuid();

  // This method prepares character data for API but doesn't insert it directly
  Future<Map<String, dynamic>?> prepareCharacterData(
    ComicModel comic,
    List<Map<String, dynamic>> charactersMap,
  ) async {
    try {
      if (charactersMap.isEmpty) return null;

      // Find the relevant character data for this comic
      final charactersComicData = charactersMap.firstWhere(
        (map) => map["comic_ani_id"] == comic.aniId,
        orElse: () => {"comic_ani_id": comic.aniId, "characters": []},
      );

      // Log for debugging
      if (charactersComicData.containsKey("characters")) {
        final charCount = (charactersComicData["characters"] as List).length;
        log("Found $charCount characters for comic ${comic.englishTitle} (${comic.comicId})");
      } else {
        log("No characters found for comic ${comic.englishTitle} (${comic.comicId})");
        return charactersComicData; // Return early with empty characters
      }

      // Extract character models from the data
      final characters = <CharacterModel>[];

      for (final char in charactersComicData["characters"]) {
        if (char is Map && char.containsKey("character")) {
          try {
            characters.add(CharacterModel.fromDB(char["character"]));
          } catch (e) {
            log("Error parsing character: $e");
          }
        }
      }

      // If we found valid characters, translate their descriptions
      if (characters.isNotEmpty) {
        final translatedChars = await translateCharacterDescription(characters);

        // Update the characters in charactersComicData with translated descriptions
        for (int i = 0; i < translatedChars.length; i++) {
          if (i < (charactersComicData["characters"] as List).length) {
            final char = translatedChars[i];
            charactersComicData["characters"][i]["character"]["ar_description"] =
                char.ar_description;
          }
        }
      }

      return charactersComicData;
    } catch (e) {
      log("Error preparing character data for comic ${comic.comicId}: ${e.toString()}");
      return null;
    }
  }

  // Legacy method kept for backward compatibility
  Future<void> handleInsertCharacters(
    ComicModel comic,
    List<Map<String, dynamic>> charactersMap,
  ) async {
    try {
      log("handleInsertCharacters called - this is now handled in prepareCharacterData");
      await prepareCharacterData(comic, charactersMap);
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
