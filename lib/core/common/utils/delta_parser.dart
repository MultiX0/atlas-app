import 'package:atlas_app/imports.dart';
import 'package:flutter/gestures.dart';

// Assuming Line class is defined as before:
class Line {
  List<(String, Map<String, dynamic>?)> parts;
  Map<String, dynamic>? blockAttributes;

  Line(this.parts, this.blockAttributes);

  bool get isEmpty =>
      parts.isEmpty ||
      (parts.length == 1 &&
          parts.first.$1.isEmpty &&
          parts.first.$2 == null); // Refined isEmpty check

  @override
  String toString() {
    String partsStr = parts.map((p) => "'${p.$1}'(${p.$2})").join(', ');
    return 'Line(parts: [$partsStr], blockAttributes: $blockAttributes)';
  }
}

// Parse Delta operations into a list of Lines - completely revised for Quill format
List<Line> parseDelta(List<dynamic> operations) {
  List<Line> lines = [];
  // Stores the text and inline attributes for the line currently being built.
  List<(String, Map<String, dynamic>?)> currentLineParts = [];

  for (int i = 0; i < operations.length; i++) {
    var op = operations[i];

    if (op['insert'] is String) {
      String text = op['insert'];
      Map<String, dynamic>? attributes = op['attributes']; // Could be inline or block

      if (text == '\n') {
        // --- Newline-only operation ---
        // This operation defines the block format for the preceding text.
        // Finalize the line built so far using these BLOCK attributes.
        lines.add(Line(List.from(currentLineParts), attributes));
        currentLineParts.clear(); // Start fresh for the next line
      } else {
        // --- Text insertion operation (may contain embedded newlines) ---
        // Attributes here are INLINE attributes.
        List<String> textParts = text.split('\n');

        // Add the first part (before any potential '\n') to the current line
        if (textParts[0].isNotEmpty) {
          currentLineParts.add((textParts[0], attributes)); // Apply INLINE attributes
        }

        // Handle embedded newlines (if any)
        // Each embedded newline signifies the end of a line, but without block attributes.
        for (int j = 1; j < textParts.length; j++) {
          // An embedded newline was found. Finalize the line BEFORE the newline.
          // It gets NO block attributes because the newline was embedded.
          lines.add(Line(List.from(currentLineParts), null));
          currentLineParts.clear(); // Start fresh for the text *after* the embedded newline

          // Add the text part *after* the embedded newline to the *new* current line
          if (textParts[j].isNotEmpty) {
            currentLineParts.add((textParts[j], attributes)); // Apply INLINE attributes
          }
        }
      }
    }
    // else: Handle other op types like 'delete' or 'retain' if needed.
  }

  // Add any remaining parts if the delta didn't end with a newline operation
  if (currentLineParts.isNotEmpty) {
    lines.add(Line(List.from(currentLineParts), null));
  }

  for (int i = 0; i < lines.length; i++) {}
  return lines;
}

// Get TextStyle for headers (block attributes)
TextStyle getHeaderStyle(Map<String, dynamic>? blockAttributes) {
  if (blockAttributes == null) return const TextStyle(color: AppColors.mutedSilver);

  if (blockAttributes['header'] == 3) {
    return const TextStyle(
      fontSize: 28, // Increased for visibility
      fontWeight: FontWeight.bold,
      fontFamily: arabicAccentFont,
      color: AppColors.mutedSilver, // Added for debugging visibility
    );
  } else if (blockAttributes['header'] == 4) {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: arabicAccentFont,
      color: AppColors.mutedSilver, // Added for debugging visibility
    );
  }

  return const TextStyle();
}

TextStyle getInlineStyle(Map<String, dynamic>? attributes) {
  TextStyle style = const TextStyle();
  if (attributes == null) return style;

  if (attributes['bold'] == true) {
    style = style.copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: arabicPrimaryFont,
      color: AppColors.whiteColor,
    );
  }
  if (attributes['size'] != null) {
    String size = attributes['size'];
    if (size == 'small') {
      style = style.copyWith(fontSize: 14, color: AppColors.whiteColor);
    } else if (size == 'large') {
      style = style.copyWith(fontSize: 18, color: AppColors.whiteColor);
    } else if (size == 'huge') {
      style = style.copyWith(fontSize: 24, color: AppColors.whiteColor);
    } else if (size == 'clear(0)') {
      style = style.copyWith(fontSize: 16, color: AppColors.whiteColor);
    }
  }
  return style;
}

// Restructure segmentsToTextSpans to make each segment clickable as a whole block
List<TextSpan> segmentsToTextSpans(List<List<Line>> segments, void Function(String) onTap) {
  List<TextSpan> allSpans = [];

  for (int i = 0; i < segments.length; i++) {
    var segment = segments[i];
    String segmentText = segment.map((line) => line.parts.map((part) => part.$1).join()).join('\n');

    // Create spans for each line in the segment, preserving styling
    List<TextSpan> segmentContentSpans = [];

    for (int j = 0; j < segment.length; j++) {
      var line = segment[j];
      TextStyle headerStyle = getHeaderStyle(line.blockAttributes);

      // Create spans for each part in the line
      List<TextSpan> partSpans = [];
      for (var part in line.parts) {
        TextStyle inlineStyle = getInlineStyle(part.$2);

        // Blend styles as before
        TextStyle partStyle;
        if (line.blockAttributes != null && line.blockAttributes!.isNotEmpty) {
          partStyle = TextStyle(
            fontSize: headerStyle.fontSize ?? inlineStyle.fontSize ?? 16,
            fontWeight: headerStyle.fontWeight ?? inlineStyle.fontWeight ?? FontWeight.normal,
            fontFamily: headerStyle.fontFamily ?? inlineStyle.fontFamily ?? arabicPrimaryFont,
            color: headerStyle.color ?? inlineStyle.color ?? AppColors.whiteColor,
          );
        } else {
          partStyle = TextStyle(
            fontSize: inlineStyle.fontSize ?? 16,
            fontWeight: inlineStyle.fontWeight ?? FontWeight.normal,
            fontFamily: inlineStyle.fontFamily ?? arabicPrimaryFont,
            color: inlineStyle.color ?? AppColors.whiteColor,
          );
        }

        partSpans.add(TextSpan(text: part.$1, style: partStyle));
      }

      // Add this line's parts
      segmentContentSpans.add(TextSpan(children: partSpans));

      // Add newline between lines (but not after the last line)
      if (j < segment.length - 1) {
        segmentContentSpans.add(const TextSpan(text: '\n'));
      }
    }

    // Create a single TextSpan for the entire segment with one recognizer
    allSpans.add(
      TextSpan(
        children: segmentContentSpans,
        recognizer: TapGestureRecognizer()..onTap = () => onTap(segmentText),
      ),
    );

    // Add paragraph spacing between segments
    if (i < segments.length - 1) {
      allSpans.add(const TextSpan(text: '\n\n'));
    }
  }

  return allSpans;
}

// Group lines into segments separated by blank lines (2 or more consecutive blank lines)
List<List<Line>> groupLinesIntoSegments(List<Line> lines) {
  List<List<Line>> segments = [];
  List<Line> currentSegment = [];
  int consecutiveEmptyLines = 0;

  for (var line in lines) {
    if (line.isEmpty) {
      consecutiveEmptyLines++;
      if (consecutiveEmptyLines >= 2 && currentSegment.isNotEmpty) {
        segments.add(List.from(currentSegment));
        currentSegment = [];
      }
    } else {
      consecutiveEmptyLines = 0;
      currentSegment.add(line);
    }
  }

  if (currentSegment.isNotEmpty) {
    segments.add(currentSegment);
  }

  return segments;
}

// Usage example
Widget buildRichText(List<dynamic> deltaOperations, void Function(String) onTap) {
  // Uncomment to debug

  List<Line> lines = parseDelta(deltaOperations);
  List<List<Line>> segments = groupLinesIntoSegments(lines);
  List<InlineSpan> spans = segmentsToTextSpans(segments, onTap);

  return RichText(
    text: TextSpan(
      children: spans,
      // style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: arabicPrimaryFont),
    ),
  );
}

// Usage example with additional debugging
