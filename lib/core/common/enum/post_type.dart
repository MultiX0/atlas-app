enum PostType { normal, comic, character, novel, novel_review, comic_review, repost, edit }

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
    case 'novel_review':
      return PostType.novel_review;
    case 'comic_review':
      return PostType.comic_review;
    case 'repost':
      return PostType.repost;
    case 'edit':
      return PostType.edit;

    default:
      return PostType.normal;
  }
}
