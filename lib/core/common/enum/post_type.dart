enum PostType { normal, comic, character, novel }

PostType stringToPostType(String type) {
  switch (type) {
    case 'normal':
      return PostType.normal;
    case 'comic':
      return PostType.comic;
    case 'character':
      return PostType.character;
    case 'novel':
      return PostType.novel;

    default:
      return PostType.normal;
  }
}
