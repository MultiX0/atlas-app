enum ReviewsEnum { novel, comic, webtoon }

extension ReviewsEnumExtension on ReviewsEnum {
  String toStringValue() {
    switch (this) {
      case ReviewsEnum.novel:
        return 'novel';
      case ReviewsEnum.comic:
        return 'comic';
      case ReviewsEnum.webtoon:
        return 'webtoon';
    }
  }

  static ReviewsEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'novel':
        return ReviewsEnum.novel;
      case 'comic':
        return ReviewsEnum.comic;
      case 'webtoon':
        return ReviewsEnum.webtoon;
      default:
        throw ArgumentError('Invalid ReviewsEnum value: $value');
    }
  }
}

ReviewsEnum reviewsEnumFromString(String value) {
  switch (value.toLowerCase()) {
    case 'novel':
      return ReviewsEnum.novel;
    case 'comic':
      return ReviewsEnum.comic;
    case 'webtoon':
      return ReviewsEnum.webtoon;
    default:
      throw ArgumentError('Invalid ReviewsEnum value: $value');
  }
}
