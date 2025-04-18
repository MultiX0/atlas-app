import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/imports.dart';

/// Enhanced AnnotationEditingController with support for slash entity formatting
class EnhancedAnnotationEditingController extends TextEditingController {
  Map<String, Annotation> _mapping;
  String? _pattern;

  EnhancedAnnotationEditingController(this._mapping)
    : _pattern =
          _mapping.keys.isNotEmpty
              ? "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})"
              : null;

  /// Get the markup text with proper formatting for each trigger
  String get markupText {
    if (_mapping.isEmpty) return text;

    return text.splitMapJoin(
      RegExp('$_pattern'),
      onMatch: (Match match) {
        final mention = _findMention(match[0]!);

        // Handle slash commands with special format
        if (mention.trigger == '/' && !mention.disableMarkup && mention.id != null) {
          // Find the suggestion data with this ID
          final type = mention.data?['type'] ?? "";

          // Format as /type[id]:display
          return '/$type[${mention.id}]:${mention.display}/';
        }

        // Default markup format for mentions
        if (!mention.disableMarkup) {
          return mention.markupBuilder != null
              ? mention.markupBuilder!(mention.trigger, mention.id!, mention.display!)
              : '${mention.trigger}[__${mention.id}__](__${mention.display}__)${mention.trigger}';
        } else {
          return match[0]!;
        }
      },
      onNonMatch: (String text) {
        return text;
      },
    );
  }

  /// Find the appropriate mention from the mapping
  Annotation _findMention(String text) {
    if (_mapping.containsKey(text)) {
      return _mapping[text]!;
    }

    // Find by regex pattern
    final key = _mapping.keys.firstWhere((element) {
      final reg = RegExp(element);
      return reg.hasMatch(text);
    }, orElse: () => _mapping.keys.first);

    return _mapping[key]!;
  }

  Map<String, Annotation> get mapping {
    return _mapping;
  }

  set mapping(Map<String, Annotation> mapping) {
    _mapping = mapping;
    _pattern = "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})";
  }

  @override
  TextSpan buildTextSpan({BuildContext? context, TextStyle? style, bool? withComposing}) {
    var children = <InlineSpan>[];

    // If there's no pattern, render the text as-is
    if (_pattern == null || _pattern == '()') {
      children.add(TextSpan(text: text, style: style));
      return TextSpan(style: style, children: children);
    }

    // First, process mentions and slash commands that are in the mapping
    int lastEnd = 0;

    // Find all matches for the existing pattern (mentions, slash commands, and known hashtags)
    final matches = RegExp('$_pattern').allMatches(text).toList();
    for (var match in matches) {
      final start = match.start;
      final end = match.end;

      // Add any text before the match (which might contain hashtags)
      if (start > lastEnd) {
        final beforeText = text.substring(lastEnd, start);
        children.addAll(_processTextWithHashtags(beforeText, style));
      }

      // Process the match (mention, slash command, or known hashtag)
      if (_mapping.isNotEmpty) {
        final mention = _findMention(match[0]!);
        if (mention.trigger == '/' && mention.display != null) {
          // Slash commands: show only the display text
          children.add(TextSpan(text: mention.display, style: style!.merge(mention.style)));
        } else {
          // Mentions and known hashtags: show the full text with style
          children.add(TextSpan(text: match[0], style: style!.merge(mention.style)));
        }
      }

      lastEnd = end;
    }

    // Add any remaining text after the last match (which might contain hashtags)
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      children.addAll(_processTextWithHashtags(remaining, style));
    }

    return TextSpan(style: style, children: children);
  }

  /// Helper method to process text and style hashtags that aren't in the mapping
  List<TextSpan> _processTextWithHashtags(String text, TextStyle? style) {
    final children = <TextSpan>[];
    final hashtagRegex = RegExp(r'#[\w\u0600-\u06FF]+');

    int lastEnd = 0;
    final matches = hashtagRegex.allMatches(text).toList();

    for (var match in matches) {
      final start = match.start;
      final end = match.end;

      // Add any text before the hashtag
      if (start > lastEnd) {
        children.add(TextSpan(text: text.substring(lastEnd, start), style: style));
      }

      // Add the hashtag with the specified style
      children.add(
        TextSpan(text: match[0], style: style!.merge(const TextStyle(color: AppColors.primary))),
      );

      lastEnd = end;
    }

    // Add any remaining text after the last hashtag
    if (lastEnd < text.length) {
      children.add(TextSpan(text: text.substring(lastEnd), style: style));
    }

    return children;
  }
}
