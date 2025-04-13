import 'package:atlas_app/core/common/widgets/rich_text_view/models.dart';

class SlashEntityParser extends ParserType {
  SlashEntityParser({Function(Matched)? super.onTap, super.style})
    : super(
        // Match /type[id]:title (title can have spaces, symbols, etc.)
        pattern: r"\/(comic|char|novel)\[([^\]]+)\]:([a-zA-Z0-9\s\-\'&:]+)",
      ) {
    renderText = ({String? str}) {
      final match = RegExp(pattern!).firstMatch(str!);
      final type = match?.group(1); // comic / char / novel
      final id = match?.group(2); // the internal id
      final title = match?.group(3)?.trim(); // title with spacing

      // For display, only show the title
      return Matched(
        // Only display the title to the user
        display: title,
        // Store the full reference for database storing
        value: '$type:$id:$title',
      );
    };
  }
}
