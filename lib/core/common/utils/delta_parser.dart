import 'dart:convert';

String extractLastLineFromQuillDelta(String deltaJson) {
  // Parse the JSON string into a List<dynamic>
  final List<dynamic> operations = jsonDecode(deltaJson);

  // Collect all inserted text
  StringBuffer fullText = StringBuffer();
  for (var op in operations) {
    if (op is Map && op.containsKey('insert') && op['insert'] is String) {
      fullText.write(op['insert']);
    }
  }

  // Split by newlines and filter out empty lines
  List<String> lines =
      fullText.toString().split('\n').where((line) => line.trim().isNotEmpty).toList();

  // Return the last non-empty line, or empty string if none
  return lines.isNotEmpty ? lines.last : '';
}
