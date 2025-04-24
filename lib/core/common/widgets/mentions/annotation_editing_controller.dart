import 'dart:developer';

import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/imports.dart'; // Assuming this contains AppColors

/// Enhanced AnnotationEditingController with support for slash entity formatting
/// Recognizes pre-formatted /type[id]:display/ in text segments.
class EnhancedAnnotationEditingController extends TextEditingController {
  Map<String, Annotation> _mapping;
  String? _pattern;

  // Regex JUST for the pre-formatted slash command: /type[id]:display/
  // Groups: 1=type, 2=id, 3=display
  // Original hashtag regex
  // Ensure unicode flag u is supported or adjust if needed for specific Dart versions/platforms
  // static final _hashtagRegex = RegExp(r'#[\w\u0600-\u06FF]+', unicode: true);
  // Safer alternative without unicode flag if issues arise:

  EnhancedAnnotationEditingController(this._mapping)
    : _pattern =
          _mapping.keys.isNotEmpty
              ? "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})"
              : null;

  /// Get the markup text with proper formatting for each trigger
  /// NOTE: Kept original as requested.
  String get markupText {
    if (_mapping.isEmpty) return text;

    return text.splitMapJoin(
      RegExp('$_pattern'), // Uses the original pattern based ONLY on mapping keys
      onMatch: (Match match) {
        final mention = _findMention(match[0]!);

        // --- START: Original Markup Logic ---
        if (mention.trigger == '/' && !mention.disableMarkup && mention.id != null) {
          final type = mention.data?['type'] ?? "unknown";
          return '/$type[${mention.id}]:${mention.display ?? ""}/';
        }

        if (!mention.disableMarkup) {
          return mention.markupBuilder != null
              ? mention.markupBuilder!(mention.trigger, mention.id!, mention.display!)
              : '${mention.trigger}[__${mention.id}__](__${mention.display}__)${mention.trigger}';
        } else {
          return match[0]!;
        }
        // --- END: Original Markup Logic ---
      },
      onNonMatch: (String text) {
        return text;
      },
    );
  }

  /// Find the appropriate mention from the mapping - Kept Original
  Annotation _findMention(String text) {
    if (_mapping.containsKey(text)) {
      return _mapping[text]!;
    }
    try {
      final key = _mapping.keys.firstWhere(
        (element) {
          bool looksLikeRegex =
              element.contains(r'\') ||
              element.contains('[') ||
              element.contains('(') ||
              element.contains('*') ||
              element.contains('+');
          if (!looksLikeRegex) return false;
          try {
            final reg = RegExp(element);
            return reg.hasMatch(text);
          } catch (e) {
            log("Warning: Invalid regex pattern key '$element'. Skipping.");
            return false;
          }
        },
        orElse: () {
          String? trigger = text.isNotEmpty ? text[0] : null;
          if (trigger != null) {
            return _mapping.keys.firstWhere(
              (k) => _mapping[k]?.trigger == trigger,
              orElse: () => _mapping.keys.first,
            );
          }
          return _mapping.keys.first;
        },
      );
      return _mapping[key]!;
    } catch (e) {
      log("Error during _findMention fallback logic for '$text': $e");
      return Annotation(trigger: '', data: {}, display: text, style: const TextStyle());
    }
  }

  Map<String, Annotation> get mapping {
    return _mapping;
  }

  set mapping(Map<String, Annotation> mapping) {
    _mapping = mapping;
    _pattern =
        _mapping.keys.isNotEmpty
            ? "(${_mapping.keys.map((key) => RegExp.escape(key)).join('|')})"
            : null;
  }

  @override
  TextSpan buildTextSpan({BuildContext? context, TextStyle? style, bool? withComposing}) {
    var children = <InlineSpan>[];

    if (_pattern == null || _pattern == '()') {
      final slashStyle = _getSlashCommandStyle(style);
      // Process whole text if no mapping pattern exists
      children.addAll(_processUnmappedTextSegments(text, style, slashStyle));
      return TextSpan(style: style, children: children);
    }

    // --- START: Original buildTextSpan Logic Structure ---
    int lastEnd = 0;
    final TextStyle? slashCommandStyle = _getSlashCommandStyle(style);
    final matches = RegExp('$_pattern').allMatches(text).toList(); // Original Regex

    for (var match in matches) {
      final start = match.start;
      final end = match.end;

      if (start > lastEnd) {
        final beforeText = text.substring(lastEnd, start);
        // **MODIFIED:** Call the helper, passing the slash style
        children.addAll(_processUnmappedTextSegments(beforeText, style, slashCommandStyle));
      }

      // Process the match found by _pattern (Original Logic)
      try {
        final mention = _findMention(match[0]!);
        if (mention.trigger == '/' && mention.display != null) {
          children.add(
            TextSpan(text: mention.display, style: style?.merge(mention.style) ?? mention.style),
          );
        } else {
          children.add(
            TextSpan(text: match[0], style: style?.merge(mention.style) ?? mention.style),
          );
        }
      } catch (e) {
        log("Error processing mapped mention '${match[0]}': $e");
        children.add(TextSpan(text: match[0], style: style));
      }

      lastEnd = end;
    }

    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      // **MODIFIED:** Call the helper, passing the slash style
      children.addAll(_processUnmappedTextSegments(remaining, style, slashCommandStyle));
    }
    // --- END: Original buildTextSpan Logic Structure ---

    return TextSpan(style: style, children: children);
  }

  /// Helper method to find the style associated with the '/' trigger in the mapping.
  TextStyle? _getSlashCommandStyle(TextStyle? defaultStyle) {
    try {
      final slashAnnotation = _mapping.values.firstWhere((annotation) => annotation.trigger == '/');
      return defaultStyle?.merge(slashAnnotation.style) ?? slashAnnotation.style;
    } catch (e) {
      return defaultStyle;
    }
  }

  /// Helper: Processes text segments NOT matched by the main `_pattern`.
  /// Looks for BOTH pre-formatted slash commands and hashtags.
  List<TextSpan> _processUnmappedTextSegments(
    String textSegment,
    TextStyle? style,
    TextStyle? slashCommandStyle,
  ) {
    final children = <TextSpan>[];
    // Combined regex: Group 1 for Slash Command, Group 5 for Hashtag
    // Slash: \/(\w+)\[([^\]]+)\]:([^\/]+)\/  -> Groups 2(type), 3(id), 4(display)
    // Hashtag: #[\w\u0600-\u06FF]+
    final combinedRegex = RegExp(r'(\/(\w+)\[([^\]]+)\]:([^\/]+)\/)|(#[\w\u0600-\u06FF]+)');

    int lastEnd = 0;
    final matches = combinedRegex.allMatches(textSegment).toList();

    if (matches.isEmpty) {
      // If no slash commands or hashtags, return the whole segment as plain text
      if (textSegment.isNotEmpty) {
        children.add(TextSpan(text: textSegment, style: style));
      }
      return children;
    }

    for (var match in matches) {
      final start = match.start;
      final end = match.end;

      // Add any plain text before this match
      if (start > lastEnd) {
        children.add(TextSpan(text: textSegment.substring(lastEnd, start), style: style));
      }

      // Check which pattern matched
      if (match.group(1) != null) {
        // --- Matched: Pre-formatted Slash Command /type[id]:display/ --- (Working Logic)
        final displayPart = match.group(4); // Extract the display part
        if (displayPart != null) {
          children.add(
            TextSpan(
              text: displayPart, // Show ONLY the display part
              style: slashCommandStyle, // Apply the specific style for slash commands
            ),
          );
        } else {
          children.add(TextSpan(text: match[0], style: style)); // Fallback
        }
      } else if (match.group(5) != null) {
        // --- Matched: Hashtag --- (Using EXACT Original Styling Logic)
        children.add(
          TextSpan(
            text: match[0], // Show the full hashtag (using match[0] which is the full match)
            // **FIXED:** Use the exact style merging from the original _processTextWithHashtags
            style:
                style?.merge(const TextStyle(color: AppColors.primary)) ??
                const TextStyle(color: AppColors.primary),
          ),
        );
      }
      // else: Should not happen with this combined regex structure

      lastEnd = end;
    }

    // Add any remaining plain text after the last match in the segment
    if (lastEnd < textSegment.length) {
      children.add(TextSpan(text: textSegment.substring(lastEnd), style: style));
    }

    return children;
  }
}
