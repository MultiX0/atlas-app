import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:atlas_app/features/theme/app_theme.dart';
import 'package:image_cropper/image_cropper.dart' as c;
import 'package:image_picker/image_picker.dart';

Future<List<File>> imagePicker(bool single) async {
  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(limit: 4, imageQuality: 70);
    List<File> selectedImages = [];

    for (final image in images) {
      selectedImages = [...selectedImages, File(image.path)];
    }

    return selectedImages;
  } catch (e) {
    log(e.toString());
    throw Exception(e);
  }
}

Future<File?> profilePhotoPicker({bool isAvatar = true, required Size size}) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedImage = await imageCropper(File(image.path), isAvatar, size);
      if (croppedImage != null) {
        return croppedImage;
      }
    }
    return null;
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

Future<File?> imageCropper(File imageFile, bool isAvatar, Size size) async {
  c.CroppedFile? croppedFile = await c.ImageCropper().cropImage(
    aspectRatio: c.CropAspectRatio(ratioX: size.height, ratioY: size.width),
    compressFormat: c.ImageCompressFormat.png,
    compressQuality: 70,
    sourcePath: imageFile.path,
    uiSettings: [
      c.AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: AppColors.primary,
        toolbarWidgetColor: AppColors.scaffoldBackground,
        aspectRatioPresets: [
          if (isAvatar) ...[
            c.CropAspectRatioPreset.square,
          ] else ...[
            c.CropAspectRatioPreset.ratio5x3,
          ],
        ],
      ),
    ],
  );
  if (croppedFile != null) {
    return File(croppedFile.path);
  }
  return null;
}
