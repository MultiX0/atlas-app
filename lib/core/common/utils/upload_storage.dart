import 'dart:developer';
import 'dart:io';
import './file_compressor.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadStorage {
  static Future<String> uploadImages({
    required File image,
    required String path,
    bool? isAdmin,
    int? quiality,
  }) async {
    try {
      final file = await compressFile(image, (isAdmin != null && isAdmin) ? 80 : quiality ?? 50);
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      log('Failed to upload ${image.path}: $e');
      rethrow;
    }
  }
}
