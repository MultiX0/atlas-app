import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/features/comics/db/comics_db.dart';
import 'package:atlas_app/imports.dart';

final comicsControllerProvider = StateNotifierProvider<ComicsController, bool>(
  (ref) => ComicsController(ref: ref),
);

final searchComicsProvider = FutureProvider.family.autoDispose<List<ComicModel>, String>((
  ref,
  query,
) async {
  final controller = ref.watch(comicsControllerProvider.notifier);
  return controller.searchComics(query);
});

class ComicsController extends StateNotifier<bool> {
  final Ref _ref;
  ComicsController({required Ref ref}) : _ref = ref, super(false);
  ComicsDb get db => _ref.watch(comicsDBProvider);

  Future<List<ComicModel>> searchComics(String query, {int limit = 20, bool more = false}) async {
    try {
      log('here');
      return await db.searchComics(query, limit: limit, more: more);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> viewComic({required String userId, required String comicId}) async {
    try {
      await db.viewComic(userId: userId, comicId: comicId);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> handleComicUpdate(ComicModel comic) async {
    try {
      await db.handleUpdateComic(comic);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
