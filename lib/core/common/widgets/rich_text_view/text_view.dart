import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  RichTextView({
    Key? key,
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
  }) : super(key: key);

  @override
  State<RichTextView> createState() => _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  late bool _expanded;
  late int? _maxLines;
  late TextStyle linkStyle;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.truncate;
    _maxLines = widget.truncate ? (widget.maxLines ?? 2) : widget.maxLines;
    linkStyle = widget.linkStyle;
  }

  @override
  Widget build(BuildContext context) {
    var _style = widget.style ?? Theme.of(context).textTheme.bodyMedium;
    var link =
        _expanded && widget.viewLessText == null
            ? TextSpan()
            : TextSpan(
              children: [
                TextSpan(text: ' \u2026'),
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

    List<InlineSpan> parseText(String txt) {
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

      // Build the spans
      for (var match in processedMatches) {
        int start = match['start'];
        int end = match['end'];
        String matchText = match['text'];
        ParserType parser = match['parser'];

        // Add text before the match
        if (currentIndex < start) {
          spans.add(TextSpan(text: txt.substring(currentIndex, start), style: _style));
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
      if (currentIndex < txt.length) {
        spans.add(TextSpan(text: txt.substring(currentIndex), style: _style));
      }

      return spans;
    }

    final content = TextSpan(children: parseText(widget.text), style: _style);

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

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

        var textSpan;
        if (textPainter.didExceedMaxLines) {
          final pos = textPainter.getPositionForOffset(
            Offset(textSize.width - linkSize.width, textSize.height),
          );
          final endIndex = textPainter.getOffsetBefore(pos.offset);
          var _text = TextSpan(
            children:
                _expanded
                    ? parseText(widget.text)
                    : parseText(widget.text.substring(0, max(endIndex!, 0))),
            style: widget.style,
          );
          textSpan = TextSpan(children: [_text, link]);
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
          textScaleFactor: widget.textScaleFactor,
          text: textSpan,
          textWidthBasis: widget.textWidthBasis,
        );
      },
    );

    return result;
  }
}
