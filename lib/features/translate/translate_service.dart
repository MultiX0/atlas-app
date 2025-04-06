import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  String emojiRegex = r'(\p{Emoji})';
  bool isTranslating = false;
  String originalLanguage = "English";
  String destinationLanguage = "Arabic";
  String output = "";

  // Translate text from one language to another
  Future<String> translate(String src, String des, String input) async {
    isTranslating = true;

    final emojiMatches = RegExp(emojiRegex).allMatches(input);
    final emojis = emojiMatches.map((match) => match.group(0)).toList();

    String cleanedInput = input.replaceAll(RegExp(emojiRegex), '');

    try {
      Translation translation = await _translator.translate(cleanedInput, from: src, to: des);

      String translatedText = translation.text;

      for (var emoji in emojis) {
        translatedText = '$emoji $translatedText';
      }

      output = translatedText.trim();
    } catch (e) {
      output = "Translation failed: $e";
    }

    isTranslating = false;
    return output;
  }
}
