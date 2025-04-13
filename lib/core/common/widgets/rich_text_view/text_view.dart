import 'dart:math';
import 'package:atlas_app/imports.dart';
import 'package:flutter/gestures.dart';

// Assuming this file contains ParserType, Matched, and RegexOptions
import 'models.dart';

class RichTextView extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle linkStyle;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final bool selectable;
  final GestureTapCallback? onTap;
  final Function()? onMore;
  final bool truncate;
  final String viewMoreText;
  final TextStyle? viewMoreLessStyle;
  final String? viewLessText;
  final List<ParserType> supportedTypes;
  final RegexOptions regexOptions;
  final TextAlign textAlign;
  final bool toggleTruncate;

  const RichTextView({
    super.key,
    required this.text,
    required this.supportedTypes,
    required this.truncate,
    required this.linkStyle,
    this.style,
    this.toggleTruncate = false,
    this.regexOptions = const RegexOptions(),
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.maxLines,
    this.onTap,
    this.onMore,
    this.viewMoreText = 'more',
    this.viewLessText,
    this.viewMoreLessStyle,
    this.selectable = false,
  });

  @override
  State<RichTextView> createState() => _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  late bool _expanded;
  late int? _maxLines;
  late TextStyle linkStyle;
  TextSpan? _cachedFullContent; // Cache for full text (more mode)
  TextSpan? _cachedTruncatedContent; // Cache for truncated text (less mode)
  int? _cachedEndIndex; // Store the endIndex for truncated content
  String? _lastText; // Track last text for cache invalidation
  List<ParserType>? _lastSupportedTypes; // Track last supportedTypes for cache invalidation

  @override
  void initState() {
    super.initState();
    _expanded = !widget.truncate;
    _maxLines = widget.truncate ? (widget.maxLines ?? 2) : widget.maxLines;
    linkStyle = widget.linkStyle;
  }

  @override
  void didUpdateWidget(RichTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Invalidate cache if text or supportedTypes change
    if (widget.text != oldWidget.text || widget.supportedTypes != oldWidget.supportedTypes) {
      _cachedFullContent = null;
      _cachedTruncatedContent = null;
      _cachedEndIndex = null;
      _lastText = null;
      _lastSupportedTypes = null;
    }
  }

  List<InlineSpan> parseText(String txt, {bool truncate = false, int? endIndex}) {
    List<InlineSpan> spans = [];
    String remainingText = txt;
    int currentIndex = 0;

    // Collect all matches from all parsers
    List<Map<String, dynamic>> allMatches = [];
    for (var parser in widget.supportedTypes) {
      RegExp regExp = RegExp(
        parser.pattern!,
        multiLine: widget.regexOptions.multiLine,
        caseSensitive: widget.regexOptions.caseSensitive,
        dotAll: widget.regexOptions.dotAll,
        unicode: widget.regexOptions.unicode,
      );
      var matches = regExp.allMatches(txt);
      for (var match in matches) {
        allMatches.add({
          'start': match.start,
          'end': match.end,
          'text': match.group(0)!,
          'parser': parser,
        });
      }
    }

    // Sort matches by start position, and by length (longer matches first) if start positions are equal
    allMatches.sort((a, b) {
      int startCompare = a['start'].compareTo(b['start']);
      if (startCompare != 0) return startCompare;
      return (b['end'] - b['start']).compareTo(a['end'] - a['start']);
    });

    // Process matches, ensuring no overlaps
    List<Map<String, dynamic>> processedMatches = [];
    for (var match in allMatches) {
      bool overlaps = false;
      for (var processed in processedMatches) {
        if (match['start'] < processed['end'] && match['end'] > processed['start']) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        processedMatches.add(match);
      }
    }

    // Sort processed matches by start position
    processedMatches.sort((a, b) => a['start'].compareTo(b['start']));

    // If truncate and endIndex are provided, adjust the matches
    if (truncate && endIndex != null) {
      // Find the last match that starts before or at endIndex
      int lastValidIndex = -1;
      for (int i = 0; i < processedMatches.length; i++) {
        var match = processedMatches[i];
        if (match['start'] <= endIndex) {
          lastValidIndex = i;
        } else {
          break;
        }
      }

      // If we found a match that starts before endIndex, include it fully
      if (lastValidIndex >= 0) {
        var lastMatch = processedMatches[lastValidIndex];
        remainingText = txt.substring(0, lastMatch['end']);
        processedMatches = processedMatches.sublist(0, lastValidIndex + 1);
      } else {
        // If no matches start before endIndex, truncate at endIndex
        remainingText = txt.substring(0, endIndex);
        processedMatches = [];
      }
    }

    // Build the spans
    for (var match in processedMatches) {
      int start = match['start'];
      int end = match['end'];
      String matchText = match['text'];
      ParserType parser = match['parser'];

      // Add text before the match
      if (currentIndex < start) {
        spans.add(
          TextSpan(text: remainingText.substring(currentIndex, start), style: widget.style),
        );
      }

      // Process the match
      InlineSpan span;
      if (parser.renderText != null) {
        var result = parser.renderText!(str: matchText);
        result.start = start;
        result.end = end;
        span = TextSpan(
          text: result.display,
          style: parser.style ?? linkStyle,
          recognizer:
              parser.onTap == null
                  ? null
                  : (TapGestureRecognizer()..onTap = () => parser.onTap!(result)),
        );
      } else {
        var matched = Matched(display: matchText, value: matchText, start: start, end: end);
        span = TextSpan(
          text: matchText,
          style: parser.style ?? linkStyle,
          recognizer:
              parser.onTap == null
                  ? null
                  : (TapGestureRecognizer()..onTap = () => parser.onTap!(matched)),
        );
      }
      spans.add(span);
      currentIndex = end;
    }

    // Add remaining text after the last match
    if (currentIndex < remainingText.length) {
      spans.add(TextSpan(text: remainingText.substring(currentIndex), style: widget.style));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    var _style =
        widget.style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.whiteColor);
    var link =
        _expanded && widget.viewLessText == null
            ? const TextSpan()
            : TextSpan(
              children: [
                const TextSpan(text: ' \u2026'),
                TextSpan(
                  text: _expanded ? widget.viewLessText : widget.viewMoreText,
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                ),
              ],
              style: widget.viewMoreLessStyle ?? linkStyle,
            );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

        // Check if we need to re-parse
        if (_lastText != widget.text || _lastSupportedTypes != widget.supportedTypes) {
          _cachedFullContent = null;
          _cachedTruncatedContent = null;
          _cachedEndIndex = null;
        }

        // Parse the full text if not cached
        if (_cachedFullContent == null) {
          _cachedFullContent = TextSpan(children: parseText(widget.text), style: _style);
          _lastText = widget.text;
          _lastSupportedTypes = widget.supportedTypes;
        }

        final content = _cachedFullContent!;

        // Calculate the total number of-lines in the full text
        var fullTextPainter = TextPainter(
          text: content,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
        );
        fullTextPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final totalLines = fullTextPainter.computeLineMetrics().length;

        // If the total number of lines is less than or equal to maxLines, show the full text
        if (_maxLines != null && totalLines <= _maxLines!) {
          if (widget.selectable) {
            return SelectableText.rich(
              content,
              strutStyle: widget.strutStyle,
              textWidthBasis: widget.textWidthBasis,
              textAlign: widget.textAlign,
              textDirection: widget.textDirection,
              onTap: widget.onTap,
            );
          }
          return RichText(
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            text: content,
            textWidthBasis: widget.textWidthBasis,
            textScaler: TextScaler.linear(widget.textScaleFactor),
          );
        }

        // If we need to truncate, calculate the truncation point
        var textPainter = TextPainter(
          text: link,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          maxLines: _maxLines,
        );

        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        textPainter.text = content;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        TextSpan textSpan;
        if (textPainter.didExceedMaxLines) {
          // Adjust endIndex to ensure we fill maxLines
          final lineMetrics = textPainter.computeLineMetrics();
          int adjustedEndIndex = 0;
          if (_maxLines != null && lineMetrics.length >= _maxLines!) {
            // Find the end of the maxLines-th line
            final maxLineIndex = _maxLines! - 1;
            final maxLineEndOffset = lineMetrics[maxLineIndex].baseline.toInt();
            final pos = textPainter.getPositionForOffset(
              Offset(textSize.width - linkSize.width, maxLineEndOffset.toDouble()),
            );
            adjustedEndIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
          } else {
            // If fewer lines than maxLines, use the last position
            final pos = textPainter.getPositionForOffset(
              Offset(textSize.width - linkSize.width, textSize.height),
            );
            adjustedEndIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
          }

          // Parse the truncated text if not cached or if endIndex changed
          if (_cachedTruncatedContent == null || _cachedEndIndex != adjustedEndIndex) {
            final truncatedSpans = parseText(
              widget.text,
              truncate: true,
              endIndex: max(adjustedEndIndex, 0),
            );
            _cachedTruncatedContent = TextSpan(children: truncatedSpans, style: widget.style);
            _cachedEndIndex = adjustedEndIndex;
          }

          textSpan = TextSpan(children: [_expanded ? content : _cachedTruncatedContent!, link]);
        } else {
          textSpan = content;
        }

        if (widget.selectable) {
          return SelectableText.rich(
            textSpan,
            strutStyle: widget.strutStyle,
            textWidthBasis: widget.textWidthBasis,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            onTap: widget.onTap,
          );
        }

        return RichText(
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          text: textSpan,
          textWidthBasis: widget.textWidthBasis,
          textScaler: TextScaler.linear(widget.textScaleFactor),
        );
      },
    );

    return result;
  }
}
