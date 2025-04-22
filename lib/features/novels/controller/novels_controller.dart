// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/upload_storage.dart';
import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/features/library/providers/my_work_state.dart';
import 'package:atlas_app/features/novels/db/novels_db.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/features/novels/models/novels_genre_model.dart';
import 'package:atlas_app/features/novels/providers/chapters_state.dart';
import 'package:atlas_app/features/novels/providers/drafts_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/providers/views_state.dart';
import 'package:atlas_app/imports.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uuid/uuid.dart';

final novelsControllerProvider = StateNotifierProvider<NovelsController, bool>(
  (ref) => NovelsController(ref: ref),
);

class NovelsController extends StateNotifier<bool> {
  final Ref _ref;
  NovelsController({required Ref ref}) : _ref = ref, super(false);

  NovelsDb get db => _ref.watch(novelsDbProvider);
  final uuid = const Uuid();

  Future<NovelModel?> getNovel(String id) async {
    try {
      state = true;
      final data = await db.getNovel(id);
      state = false;
      return data;
    } catch (e) {
      state = false;
      log(e.toString());
      rethrow;
    }
  }

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
      _addToState(poster: posterLink, title: title, userId: userId, novelId: id);
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

  Future<String> newDraft({
    required List<Map<String, dynamic>> jsonContent,
    required String title,
    String? originalChapterId,
    double? number,
  }) async {
    try {
      final id = uuid.v4();
      final novelId = _ref.read(selectedNovelProvider)!.id;
      final nextChapterNumber = await db.getNextChapterNumber(novelId);
      final user = _ref.read(userState).user!;
      final draft = ChapterDraftModel(
        id: id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        novelId: novelId,
        number: number ?? nextChapterNumber.toDouble(),
        title: title.isEmpty ? null : title,
        content: jsonContent,
        userId: user.userId,
        originalChapterId: originalChapterId,
      );

      await db.insertNewDraft(draft);
      _ref.read(novelChapterDraftsProvider(novelId).notifier).addDraft(draft);
      _ref.read(selectedDraft.notifier).state = draft;
      return id;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateDraft({
    required List<Map<String, dynamic>> jsonContent,
    required String title,
    required String draftId,
  }) async {
    try {
      final novelId = _ref.read(selectedNovelProvider)!.id;
      final _title = title.isEmpty ? null : title;

      final draftState = _ref.read(novelChapterDraftsProvider(novelId).notifier).exists(draftId);
      if (!draftState) {
        final _number = _ref.read(selectedChapterProvider.select((s) => s!.number));
        await newDraft(jsonContent: jsonContent, title: title, number: _number);
        return;
      }

      await db.updateDraft(content: jsonContent, title: _title, id: draftId);
      ChapterDraftModel draft = _ref.read(selectedDraft)!;
      final _newDraft = draft.copyWith(
        title: _title,
        content: jsonContent,
        updatedAt: DateTime.now(),
      );
      _ref
          .read(novelChapterDraftsProvider(novelId).notifier)
          .updateDraft(_newDraft.copyWith(title: _title));
      _ref.read(selectedDraft.notifier).state = _newDraft;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> publishChapter(ChapterDraftModel draft, BuildContext context) async {
    try {
      context.loaderOverlay.show();
      final id = uuid.v4();
      final novel = _ref.read(selectedNovelProvider)!;
      final nextChapterNumber = await db.getNextChapterNumber(draft.novelId);
      final chapter = ChapterModel(
        id: id,
        created_at: DateTime.now(),
        number: nextChapterNumber.toDouble(),
        novelId: draft.novelId,
        content: draft.content,
        title: draft.title,
        commentsCount: 0,
        isLiked: false,
        likeCount: 0,
        has_viewed_recently: false,
        views: 0,
      );
      await db.publishChapter(novel, draft, chapter);
      if (draft.originalChapterId != null && draft.originalChapterId!.isNotEmpty) {
        _ref
            .read(chaptersStateProvider(draft.novelId).notifier)
            .updateChapter(chapter.copyWith(id: draft.originalChapterId, number: draft.number));
        CustomToast.success("تم تحديث الفصل بنجاح");
      } else {
        _ref.read(chaptersStateProvider(draft.novelId).notifier).addChapter(chapter);
        CustomToast.success("تم نشر الفصل $nextChapterNumber بنجاح");
      }
      _ref.read(novelChapterDraftsProvider(draft.novelId).notifier).removeDraft(draft);
      context.loaderOverlay.hide();
      context.pop();
      context.pop();
    } catch (e) {
      context.loaderOverlay.hide();
      log(e.toString());
      CustomToast.error(e);
      rethrow;
    }
  }

  Future<void> handleChapterView() async {
    try {
      final chapter = _ref.read(selectedChapterProvider)!;
      if (chapter.has_viewed_recently) return;
      await db.handleChapterView(chapter.id);
      _ref
          .read(chaptersStateProvider(chapter.novelId).notifier)
          .updateChapter(chapter.copyWith(has_viewed_recently: true, views: chapter.views + 1));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleChapterLike(ChapterModel chapter) async {
    try {
      final newChapter = chapter.copyWith(
        isLiked: !chapter.isLiked,
        likeCount: chapter.isLiked ? chapter.likeCount - 1 : chapter.likeCount + 1,
      );
      _ref.read(selectedChapterProvider.notifier).state = newChapter;
      _ref.read(chaptersStateProvider(chapter.novelId).notifier).updateChapter(newChapter);
      await db.handleChapterLike(chapter);
    } catch (e) {
      _ref.read(selectedChapterProvider.notifier).state = chapter;
      _ref.read(chaptersStateProvider(chapter.novelId).notifier).updateChapter(chapter);
      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleNovelView() async {
    try {
      final novel = _ref.read(selectedNovelProvider)!;
      if (novel.isViewed) return;
      final _newNovel = novel.copyWith(viewsCount: novel.viewsCount + 1, isViewed: true);
      await db.handleNovelView(novel.id);
      _ref.read(novelViewsStateProvider.notifier).updateNovel(_newNovel);
      _ref.read(selectedNovelProvider.notifier).state = _newNovel;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleFavorite(NovelModel novel) async {
    try {
      final newNovel = novel.copyWith(
        isFavorite: !novel.isFavorite,
        favoriteCount: novel.isFavorite ? novel.favoriteCount - 1 : novel.favoriteCount + 1,
      );
      _ref.read(novelViewsStateProvider.notifier).updateNovel(newNovel);
      _ref.read(selectedNovelProvider.notifier).state = newNovel;
      await db.handleFavorite(novel);
      CustomToast.success(
        "تمت ${novel.isFavorite ? "ازالة" : "اضافة"} الرواية ${novel.isFavorite ? "من" : "الى"} المفضلة بنجاح",
      );
    } catch (e) {
      CustomToast.error(errorMsg);
      _ref.read(novelViewsStateProvider.notifier).updateNovel(novel);
      _ref.read(selectedNovelProvider.notifier).state = novel;

      log(e.toString());
      rethrow;
    }
  }

  Future<void> deleteChapter(BuildContext context, ChapterModel chapter) async {
    try {
      context.loaderOverlay.show();
      await db.deleteChapter(chapter.id);
      context.loaderOverlay.hide();
      _ref.read(chaptersStateProvider(chapter.novelId).notifier).deleteChapter(chapter.id);
      CustomToast.success("تم حذف الفصل بنجاح");
    } catch (e) {
      context.loaderOverlay.hide();
      CustomToast.error(e);
      log(e.toString());
      rethrow;
    }
  }

  void _addToState({
    required String title,
    required String poster,
    required String userId,
    required String novelId,
  }) {
    final work = MyWorkModel(title: title, type: 'novel', poster: poster, id: novelId);
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
