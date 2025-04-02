import 'dart:io';
import 'dart:developer';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> writeToFile(List<int> image, String filePath) {
  return File(filePath).writeAsBytes(image, flush: true);
}

Future<File> compressFile(File file, int? quality) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: quality ?? 80,
  );
  log((file.lengthSync()).toString());
  log(result!.length.toString());
  return writeToFile(result.toList(), file.absolute.path);
}
