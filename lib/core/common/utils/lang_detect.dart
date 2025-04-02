import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

bool isEnglish(String text) {
  final language = langdetect.detect(text);
  return language == 'en';
}

bool isArabic(String text) {
  final language = langdetect.detect(text);
  return language == 'ar';
}
