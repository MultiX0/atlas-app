// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_to_avif_convert.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/reviews/db/reviews_db.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

final reviewsControllerProvider = StateNotifierProvider<ReviewsController, bool>((ref) {
  return ReviewsController(ref: ref);
});

class ReviewsController extends StateNotifier<bool> {
  final Ref _ref;
  ReviewsController({required Ref ref}) : _ref = ref, super(false);
  ReviewsDb get db => _ref.watch(reviewsDBProvider);

  Future<void> insertComicReview({
    required String comicId,
    required List<File> images,
    required String userId,
    required double writingQuality,
    required double storyDevelopment,
    required double characterDesign,
    required double updateStability,
    required double worldBackground,
    required String reviewText,
    required double overall,
    required bool spoilers,
    required BuildContext context,
  }) async {
    try {
      state = true;
      context.loaderOverlay.show();
      final _images = await uploadImages(images, comicId: comicId, userId: userId);

      final review = ComicReviewModel(
        review: reviewText,
        comicId: comicId,
        images: _images,
        userId: userId,
        writingQuality: writingQuality,
        storyDevelopment: storyDevelopment,
        characterDesign: characterDesign,
        updateStability: updateStability,
        worldBackground: worldBackground,
        overall: overall,
        spoilers: spoilers,
      );

      await db.insertComicReview(review);
      context.loaderOverlay.hide();
      CustomToast.success("تم نشر مراجعتك بنجاح");
      context.pop();
      state = false;
    } catch (e) {
      state = false;
      context.loaderOverlay.hide();

      log(e.toString());
      rethrow;
    }
  }

  Future<List<String>> uploadImages(
    List<File> images, {
    required String comicId,
    required String userId,
  }) async {
    try {
      const uuid = Uuid();
      List<String> _links = [];
      for (final image in images) {
        // Convert image to AVIF first
        final avifImage = await AvifConverter.convertToAvif(image);
        log("avifImage: ${avifImage?.absolute.path}");

        // Check if conversion was successful before proceeding
        if (avifImage != null) {
          final link = await UploadStorage.uploadImages(
            image: avifImage,
            path: 'comics/$comicId/reviews/$userId-${uuid.v4()}',
          );
          log("avif image uploaded: $link");
          _links.add(link);
        } else {
          // If AVIF conversion fails, use the original image as fallback
          log('AVIF conversion failed for image. Using original format.');
          final link = await UploadStorage.uploadImages(
            image: image,
            path: 'comics/$comicId/reviews/$userId-${uuid.v4()}',
          );
          _links.add(link);
        }
      }
      return _links;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
