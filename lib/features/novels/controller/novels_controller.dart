// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/features/library/providers/my_work_state.dart';
import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

final novelsControllerProvider = StateNotifierProvider<NovelsController, bool>(
  (ref) => NovelsController(ref: ref),
);

class NovelsController extends StateNotifier<bool> {
  final Ref _ref;
  NovelsController({required Ref ref}) : _ref = ref, super(false);

  NovelsDb get db => _ref.watch(novelDbProvider);
  final uuid = const Uuid();

  Future<void> handleInsertNewNovel({
    required String title,
    required String story,
    required String src_lang,
    required int age_rating,
    required String userId,
    required File poster,
    required List<NovelsGenreModel> genres,
    File? banner,
    required BuildContext context,
  }) async {
    try {
      state = true;
      context.loaderOverlay.show();
      final id = uuid.v4();
      final data = await Future.wait<dynamic>([
        uploadImage(poster, userId, true, novelId: id),
        if (banner != null) uploadImage(banner, userId, true, novelId: id),
      ]);

      String posterLink = data[0];
      String? bannerLink;
      if (data.length > 1) {
        bannerLink = data[1];
      }

      await db.handleInsertNewNovel(
        id: id,
        title: title,
        story: story,
        src_lang: src_lang,
        age_rating: age_rating,
        userId: userId,
        poster: posterLink,
        genres: genres,
        banner: bannerLink,
      );
      _addToState(poster: posterLink, title: title, userId: userId);
      context.loaderOverlay.hide();
      state = false;
      context.pop();
      CustomToast.success("تم انشاء رواية جديدة بنجاح");
    } catch (e) {
      context.loaderOverlay.hide();
      state = false;
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  void _addToState({required String title, required String poster, required String userId}) {
    final work = MyWorkModel(title: title, type: 'novel', poster: poster);
    _ref.read(myWorksStateProvider(userId).notifier).addWork(work);
  }

  Future<String> uploadImage(
    File image,
    String userId,
    bool poster, {
    required String novelId,
  }) async {
    try {
      final link = await UploadStorage.uploadImages(
        image: image,
        path:
            '/novels/$userId/$novelId/${poster ? 'poster-${uuid.v4()}.jpg' : 'banner-${uuid.v4()}.jpg'}',
        quiality: 80,
      );
      return link;
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      rethrow;
    }
  }
}
