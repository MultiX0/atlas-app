String? extractMentionKeyword(String text) {
  final regex = RegExp(r'@([\w]*)$', multiLine: false);
  final words = text.split(RegExp(r'\s+'));
  for (final word in words.reversed) {
    final match = regex.firstMatch(word);
    if (match != null) {
      return match.group(1);
    }
  }
  return null;
}
