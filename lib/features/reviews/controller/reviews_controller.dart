// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/novels/models/novel_review_model.dart';
import 'package:atlas_app/features/novels/providers/novel_reviews_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/reviews/db/reviews_db.dart';
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
  final uuid = const Uuid();

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
      final _images = await uploadImages(images, dir: '/comics/$comicId', userId: userId);
      final now = DateTime.now();
      final review = ComicReviewModel(
        comic_title: "",
        id: uuid.v4(),
        likes_count: 0,
        i_liked: false,
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
        reviewsCount: 0,
      );

      await db.insertComicReview(review, me.user!);
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

  Future<void> insertNovelReview({
    required String novelId,
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
      final novel = _ref.read(selectedNovelProvider)!;
      state = true;
      context.loaderOverlay.show();
      final _images = await uploadImages(images, dir: '/novels/$novelId', userId: userId);
      final now = DateTime.now();
      final review = NovelReviewModel(
        novelTitle: "",
        id: uuid.v4(),
        likes_count: 0,
        i_liked: false,
        review: reviewText,
        novelId: novelId,
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
        reviewsCount: 0,
      );

      await db.insertNovelReview(review, me.user!, novel.userId);
      _ref.read(novelReviewsState(novelId).notifier).addReview(review);
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

  Future<void> handleComicReviewLike(ComicReviewModel review, String userId, int index) async {
    try {
      _ref
          .read(manhwaReviewsStateProvider(review.comicId).notifier)
          .handleLocalLike(review.copyWith(i_liked: !review.i_liked), index);

      await db.handleComicReviewLike(review, userId);
    } catch (e) {
      _ref
          .read(manhwaReviewsStateProvider(review.comicId).notifier)
          .handleLocalLike(review.copyWith(i_liked: !review.i_liked), index);
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleNovelReviewLike(NovelReviewModel review, int index) async {
    try {
      final me = _ref.read(userState.select((s) => s.user!));
      _ref
          .read(novelReviewsState(review.novelId).notifier)
          .handleLocalLike(review.copyWith(i_liked: !review.i_liked), index);

      await db.handleNovelReviewLike(review, me);
    } catch (e) {
      _ref
          .read(novelReviewsState(review.novelId).notifier)
          .handleLocalLike(review.copyWith(i_liked: !review.i_liked), index);
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateNovelReview(NovelReviewModel review, BuildContext context) async {
    try {
      state = true;
      context.loaderOverlay.show();
      await db.updateNovelReview(review);
      _ref.read(novelReviewsState(review.novelId).notifier).updateReviewByUserId(review);
      state = false;
      context.loaderOverlay.hide();
      CustomToast.success("تم تحديث المراجعة بنجاح");
      context.pop();
    } catch (e) {
      context.loaderOverlay.hide();
      state = false;
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteNovelReview(NovelReviewModel review, BuildContext context) async {
    state = true;
    context.loaderOverlay.show();
    try {
      await db.deleteNovelReview(review);
      _ref.read(novelReviewsState(review.novelId).notifier).deleteReview(review);
      context.pop(); // close sheet

      CustomToast.success("تم حذف المراجعة بنجاح");
    } catch (e) {
      CustomToast.error(errorMsg);
      log(e.toString());
    }
    context.loaderOverlay.hide();
    state = false;
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
      CustomToast.error(errorMsg);
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
      CustomToast.error(errorMsg);
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

  Future<int> getNovelReviewsCount(String novelId) async {
    try {
      state = true;
      final count = await db.getNovelReviewsCount(novelId);
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
    required String dir,
    required String userId,
  }) async {
    try {
      const uuid = Uuid();
      List<String> _links = [];
      for (final image in images) {
        final link = await UploadStorage.uploadImages(
          image: image,
          quiality: 60,
          path: '$dir/reviews/$userId-${uuid.v4()}',
        );
        _links.add(link);
      }
      return _links;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
