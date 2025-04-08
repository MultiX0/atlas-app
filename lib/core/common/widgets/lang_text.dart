import 'package:atlas_app/imports.dart';
import 'dart:ui' as ui;

class LanguageText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final String languageCode;
  final bool accent;

  const LanguageText(
    this.text, {
    super.key,
    this.style,
    this.languageCode = 'ar',
    this.accent = false,
    this.textAlign = TextAlign.end,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: style?.copyWith(fontFamily: accent ? arabicAccentFont : arabicPrimaryFont),

        textDirection: languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        textAlign: textAlign,
      ),
    );
  }
}
