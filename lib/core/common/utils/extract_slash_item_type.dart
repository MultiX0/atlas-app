String extractSlashMentionType(String word) {
  switch (word) {
    case 'char':
      return "شخصية";
    case 'comic':
      return "مانهوا/مانجا";
    case 'novel':
      return "رواية";
    default:
      "غير معروف";
  }

  return 'غير معروف';
}
