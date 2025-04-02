import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class AvifConverter {
  static const MethodChannel _channel = MethodChannel('com.example.avif_converter');

  /// Converts an image file to AVIF format with specified quality
  ///
  /// [imageFile] is the source image file
  /// [quality] is the AVIF encoding quality (0-100), defaults to 70
  /// [outputPath] optional custom output path, if not provided will use same directory with .avif extension
  ///
  /// Returns the converted AVIF file or null if conversion failed
  static Future<File?> convertToAvif(File imageFile, {int quality = 70, String? outputPath}) async {
    try {
      final String outputFilePath =
          outputPath ??
          path.join(imageFile.parent.path, '${path.basenameWithoutExtension(imageFile.path)}.avif');

      final bool success = await _channel.invokeMethod('convertToAvif', {
        'inputPath': imageFile.path,
        'outputPath': outputFilePath,
        'quality': quality,
      });

      if (success) {
        return File(outputFilePath);
      }
      return null;
    } catch (e) {
      log('Error converting image to AVIF: $e');
      return null;
    }
  }
}
