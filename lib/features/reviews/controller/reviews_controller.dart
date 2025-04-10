// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/image_to_avif_convert.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/features/comics/providers/manhwa_reviews_state.dart';
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
      final me = _ref.read(userState);
      state = true;
      context.loaderOverlay.show();
      final _images = await uploadImages(images, comicId: comicId, userId: userId);
      final now = DateTime.now();
      final review = ComicReviewModel(
        review: reviewText,
        comicId: comicId,
        createdAt: now,
        updatedAt: now,
        images: _images,
        user: me.user,
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
      _ref.read(manhwaReviewsStateProvider(comicId).notifier).addReview(review);
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

  Future<void> updateComicReview(ComicReviewModel review, BuildContext context) async {
    try {
      state = true;
      context.loaderOverlay.show();
      await db.updateComicReview(review);
      _ref.read(manhwaReviewsStateProvider(review.comicId).notifier).updateReviewByUserId(review);
      state = false;
      context.loaderOverlay.hide();
      CustomToast.success("تم تحديث المراجعة بنجاح");
      context.pop();
    } catch (e) {
      context.loaderOverlay.hide();
      state = false;
      CustomToast.error("حدث خطأ الرجاء المحاولة مرة أخرى لاحقا");
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteComicReview(ComicReviewModel review, BuildContext context) async {
    state = true;
    context.loaderOverlay.show();
    try {
      await db.deleteComicReview(review);
      _ref.read(manhwaReviewsStateProvider(review.comicId).notifier).deleteReview(review);
      context.pop(); // close sheet

      CustomToast.success("تم حذف المراجعة بنجاح");
    } catch (e) {
      CustomToast.error("حدث خطأ الرجاء المحاولة مرة أخرى لاحقا");
      log(e.toString());
    }
    context.loaderOverlay.hide();
    state = false;
  }

  Future<int> getManhwaReviewsCount(String comicId) async {
    try {
      state = true;
      final count = await db.getManhwaReviewsCount(comicId);
      state = false;
      return count;
    } catch (e) {
      state = false;
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
