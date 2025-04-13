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
          return '/$type[${mention.id}]:${mention.display}';
        }

        // Default markup format for mentions
        if (!mention.disableMarkup) {
          return mention.markupBuilder != null
              ? mention.markupBuilder!(mention.trigger, mention.id!, mention.display!)
              : '${mention.trigger}[__${mention.id}__](__${mention.display}__)';
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

    if (_pattern == null || _pattern == '()') {
      children.add(TextSpan(text: text, style: style));
    } else {
      text.splitMapJoin(
        RegExp('$_pattern'),
        onMatch: (Match match) {
          if (_mapping.isNotEmpty) {
            final mention = _findMention(match[0]!);

            // For slash commands, only show the display part (title)
            if (mention.trigger == '/' && mention.display != null) {
              // Just show the display text for slash commands
              children.add(TextSpan(text: mention.display, style: style!.merge(mention.style)));
            } else {
              // For other mentions, show the full text
              children.add(TextSpan(text: match[0], style: style!.merge(mention.style)));
            }
          }
          return '';
        },
        onNonMatch: (String text) {
          children.add(TextSpan(text: text, style: style));
          return '';
        },
      );
    }

    return TextSpan(style: style, children: children);
  }
}
