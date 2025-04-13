import 'dart:developer';

import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart' show Matched, ParserType;
import 'package:petitparser/petitparser.dart';

class SlashEntity {
  final String type;
  final String id;
  final String title;

  SlashEntity(this.type, this.id, this.title);

  @override
  String toString() => '/$type[$id]:$title/';
}

Parser buildSlashEntityParser() {
  final slash = char('/');
  final openBracket = char('[');
  final closeBracket = char(']');
  final colon = char(':');
  final endSlash = char('/');

  final type = (string('comic') | string('char') | string('novel')).flatten();
  final uuid = noneOf(']').plus().flatten(); // Matches everything until ]
  final title = noneOf('/').plus().flatten(); // Matches everything until /

  final parser = slash & type & openBracket & uuid & closeBracket & colon & title & endSlash;

  return parser.map((values) {
    return SlashEntity(
      values[1], // type
      values[3], // id
      values[6], // title
    );
  });
}

// Updated SlashEntityParser with debug logging
class SlashEntityParser extends ParserType {
  SlashEntityParser({Function(Matched)? super.onTap, super.style})
    : super(
        // Use the same regex as checkResult
        pattern: r"/(comic|char|novel)\[[^\]]+\]:[^/]+/",
      ) {
    renderText = ({String? str}) {
      // log('Matched string: $str'); // Debug: Log the matched string
      final parser = buildSlashEntityParser();
      final result = parser.parse(str!);
      // ignore: deprecated_member_use
      if (result.isSuccess) {
        final entity = result.value as SlashEntity;
        // log('Parsed entity: $entity'); // Debug: Log the parsed entity
        // log(entity.title.toString());
        return Matched(display: entity.title, value: '${entity.type}:${entity.id}:${entity.title}');
      } else {
        log('Parse failed for "$str": ${result.message}'); // Debug: Log parse failures
        return Matched(display: str, value: str);
      }
    };
  }
}
