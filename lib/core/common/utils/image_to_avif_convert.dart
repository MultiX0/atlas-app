import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class AvifConverter {
  static const MethodChannel _channel = MethodChannel('com.example.avif_converter');

  /// Converts an image file to AVIF format with specified quality.
  ///
  /// [imageFile] is the source image file.
  /// [quality] is the AVIF encoding quality (0-100), defaults to 70.
  /// [outputPath] is an optional custom output path; if null, uses the same directory with .avif extension.
  ///
  /// Returns the converted AVIF file or null if conversion fails.
  static Future<File?> convertToAvif(File imageFile, {int quality = 90, String? outputPath}) async {
    if (!imageFile.existsSync()) {
      log('Input file does not exist: ${imageFile.path}');
      return null;
    }

    final String defaultOutputPath = path.join(
      imageFile.parent.path,
      '${path.basenameWithoutExtension(imageFile.path)}.avif',
    );
    final String finalOutputPath = outputPath ?? defaultOutputPath;

    try {
      final bool? success = await _channel.invokeMethod('convertToAvif', {
        'inputPath': imageFile.path,
        'outputPath': finalOutputPath,
        'quality': quality,
      });

      if (success == true) {
        final outputFile = File(finalOutputPath);
        return outputFile.existsSync() ? outputFile : null;
      }
      log('Conversion failed or returned false');
      return null;
    } on PlatformException catch (e) {
      log('Platform error converting to AVIF: ${e.message}');
      return null;
    } catch (e) {
      log('Unexpected error converting to AVIF: $e');
      return null;
    }
  }
}
