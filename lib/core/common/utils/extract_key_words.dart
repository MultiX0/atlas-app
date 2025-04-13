// Utility functions to extract different trigger queries

/// Extract mention query - gets the text after @ symbol being typed
String? extractMentionKeyword(String text) {
  // Find the last @ symbol followed by word characters
  final match = RegExp(r'@(\w+)$').firstMatch(text);
  if (match != null && match.group(1) != null) {
    return match.group(1);
  }
  return null;
}

/// Extract hashtag query - gets the text after # symbol being typed
String? extractHashtagKeyword(String text) {
  // Find the last # symbol followed by word characters
  final match = RegExp(r'#(\w+)$').firstMatch(text);
  if (match != null && match.group(1) != null) {
    return match.group(1);
  }
  return null;
}

/// Extract slash command query - gets the text after / symbol being typed
String? extractSlashKeyword(String text) {
  // Find the last / symbol followed by word characters
  final match = RegExp(r'/(\w+)$').firstMatch(text);
  if (match != null && match.group(1) != null) {
    return match.group(1);
  }
  return null;
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
