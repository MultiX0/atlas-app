import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/imports.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:uuid/uuid.dart';

Future<void> downloadImage(String url) async {
  try {
    await _checkAccess();
    const uuid = Uuid();

    // Download to a temporary file first
    final tempPath = '${Directory.systemTemp.path}/${uuid.v4()}';

    CustomToast.get(
      text: "جاري التحميل",
      icon: LucideIcons.badge_info,
      type: ToastificationType.info,
      style: ToastificationStyle.simple,
    );

    // Download the file
    await Dio().download(url, tempPath);

    // Determine appropriate extension from MIME type
    String extension = 'jpg'; // Default
    final ex = url.substring(0, url.indexOf('?alt'));
    final ex_type = ex.split('.').last.toLowerCase().trim();
    log(ex_type);
    if (!(ex_type.isEmpty || (ex_type.length < 3 || ex_type.length > 4))) {
      extension = ex_type;
    }

    // Create the final path with the correct extension
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
