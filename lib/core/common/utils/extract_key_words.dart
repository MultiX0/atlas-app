// Utility functions to extract different trigger queries

import 'package:atlas_app/core/common/widgets/rich_text_view/util.dart';
import 'package:atlas_app/core/common/widgets/slash_parser.dart';

/// Extract mention query - gets the text after @ symbol being typed
String? extractMentionKeyword(String text) {
  // Find the last @ symbol followed by word characters
  final match = RegExp(r'@(\w+)$').firstMatch(text);
  if (match != null && match.group(1) != null) {
    return match.group(1);
  }
  return null;
}

/// Extracts all mention keywords (text after each @) from the input
List<String> extractMentionKeywords(String text) {
  final matches = RegExp(r'@(\w+)').allMatches(text);
  return matches.map((m) => m.group(1)!.toLowerCase().trim()).toList();
}

/// Extract hashtag query - gets the text after # symbol being typed
List<String> extractHashtagKeyword(String text) {
  final match = RegExp(RTUtils.hashPattern).allMatches(text);
  if (match.isNotEmpty && match.first.group(0) != null) {
    return match.map((hash) => hash.group(0)!.replaceAll("#", "").trim()).toList();
  }
  return [];
}

List<SlashEntity> extractSlashKeywords(String text) {
  final match = RegExp(r"/(comic|char|novel)\[[^\]]+\]:[^/]+/").allMatches(text);

  if (match.isNotEmpty && match.first.group(0) != null) {
    List<SlashEntity> entities = [];
    for (final m in match) {
      final parser = buildSlashEntityParser();
      final result = parser.parse(m.group(0)!);
      // ignore: deprecated_member_use
      if (result.isSuccess) {
        final entity = result.value as SlashEntity;
        entities.add(entity);
      }
    }
    return entities;
  }
  return [];
}

/// Get currently active trigger character at cursor position
String? getActiveTriggerAtCursor(String text, int cursorPosition) {
  if (cursorPosition <= 0 || cursorPosition > text.length) return null;

  // Look for the word containing the cursor
  String textBeforeCursor = text.substring(0, cursorPosition);

  // Check for last occurrence of trigger characters
  final mentionMatch = RegExp(r'@\w+$').firstMatch(textBeforeCursor);
  final hashtagMatch = RegExp(r'#\w+$').firstMatch(textBeforeCursor);
  final slashMatch = RegExp(r'/\w+$').firstMatch(textBeforeCursor);

  // Find which one is closest to the cursor
  if (mentionMatch != null) return '@';
  if (hashtagMatch != null) return '#';
  if (slashMatch != null) return '/';

  return null;
}
