import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

Future<void> downloadImage(String url) async {
  try {
    await _checkAccess();

    // Download to a temporary file first
    final tempPath = '${Directory.systemTemp.path}/temp_download';

    CustomToast.get(
      text: "جاري التحميل",
      icon: LucideIcons.badge_info,
      type: ToastificationType.info,
      style: ToastificationStyle.simple,
    );

    // Download the file
    await Dio().download(url, tempPath);

    // Read the first few bytes to determine MIME type
    final bytes = await File(tempPath).readAsBytes();
    final mimeType = lookupMimeType(tempPath, headerBytes: bytes);

    // Determine appropriate extension from MIME type
    String extension = 'jpg'; // Default
    if (mimeType != null) {
      switch (mimeType) {
        case 'image/jpeg':
          extension = 'jpg';
          break;
        case 'image/png':
          extension = 'png';
          break;
        case 'image/gif':
          extension = 'gif';
          break;
        case 'image/webp':
          extension = 'webp';
          break;
        case 'image/heic':
          extension = 'heic';
          break;
        case 'image/avif':
          extension = 'avif';
          break;
      }
    }

    // Create the final path with the correct extension
    const uuid = Uuid();
    final finalPath = '${Directory.systemTemp.path}/${uuid.v4()}.$extension';

    await File(tempPath).copy(finalPath);
    await File(tempPath).delete(); // Clean up temp file

    // Save to gallery
    await Gal.putImage(finalPath, album: 'Atlas');
    CustomToast.success("تم حفظ الصورة بنجاح");
  } catch (e) {
    CustomToast.error(e);
    log(e.toString());
  }
}

Future<void> _checkAccess() async {
  try {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }

    if (!hasAccess) throw 'الرجاء قبول اذن حفظ الصور في الألبوم الخاص بك';
  } catch (e) {
    log(e.toString());
  }
}
