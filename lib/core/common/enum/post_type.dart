enum PostType { normal, comic, character, novel, comic_review }

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
    case 'comic_review':
      return PostType.comic_review;

    default:
      return PostType.normal;
  }
}
