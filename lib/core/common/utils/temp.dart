import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<File> createTempFileFromAsset(String assetPath) async {
  try {
    // Load the asset as bytes
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;

    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a temporary file with a unique name
    final tempFile = File(
      '${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    // Write the asset bytes to the temporary file
    await tempFile.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return tempFile;
  } catch (e) {
    throw Exception('Failed to create temp file: $e');
  }
}
