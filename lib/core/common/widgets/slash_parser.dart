import 'dart:developer';

import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart' show Matched, ParserType;
import 'package:petitparser/petitparser.dart';

import '../../../imports.dart' show TextStyle;

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
  SlashEntityParser({Function(Matched)? onTap, TextStyle? style})
    : super(
        // Use the same regex as checkResult
        pattern: r"/(comic|char|novel)\[[^\]]+\]:[^/]+/",
        onTap: onTap,
        style: style,
      ) {
    renderText = ({String? str}) {
      log('Matched string: $str'); // Debug: Log the matched string
      final parser = buildSlashEntityParser();
      final result = parser.parse(str!);
      if (result.isSuccess) {
        final entity = result.value as SlashEntity;
        log('Parsed entity: $entity'); // Debug: Log the parsed entity
        log(entity.title.toString());
        return Matched(display: entity.title, value: '${entity.type}:${entity.id}:${entity.title}');
      } else {
        log('Parse failed for "$str": ${result.message}'); // Debug: Log parse failures
        return Matched(display: str, value: str);
      }
    };
  }
}

// For completeness, include checkResult to compare
void checkResult() {
  final input = '''
#AI
Artificial intelligence is evolving rapidly and is impacting every sector imaginable.

#OpenSource
Some of the best projects are open-source. I'm a huge fan of /comic[8fc5260e-625d-49b2-b543-08a40caec228]:Solo Leveling/, which just got a new chapter.  
Also, /char[db030486-8862-4903-87b4-7e553579ccff]:Luffy Monkey/ is trending from /comic[07ac9079-0896-4c21-b7e2-baeab309d056]:ONE PIECE: Loguetown-hen/.

#anime
Recommendations for the weekend:
1. /novel[12345678-abcd-efgh-ijkl-987654321000]:The Beginning After The End/
2. /comic[87654321-dcba-hgfe-lkji-001122334455]:Attack on Titan/
3. /char[11223344-aabb-ccdd-eeff-667788990000]:Eren Yeager/

#deepThoughts
Ever wondered what /char[55667788-9900-aabb-ccdd-eeff11223344]:Gojo Satoru/ would do if he met /char[99887766-5544-3322-1100-aabbccddeeff]:Sung Jinwoo/?  
The possibilities are endless.

#trending
Check out /comic[aa11bb22-cc33-dd44-ee55-ff6677889900]:Demon Slayer/ if you haven't already!

/char[12121212-3434-5656-7878-909090909090]:Ichigo Kurosaki/ deserves more love too.

See you all in the next post! 🚀
''';

  final regex = RegExp(r"/(comic|char|novel)\[[^\]]+\]:[^/]+/");
  final matches = regex.allMatches(input);

  final parser = buildSlashEntityParser();
  for (var match in matches) {
    final entityText = match.group(0)!;
    final result = parser.parse(entityText);
    if (result.isSuccess) {
      final entity = result.value as SlashEntity;
      log('Parsed: $entity');
      log('Name: ${entity.title}');
    } else {
      log('Parse error for "$entityText": ${result.message}');
    }
  }
}
