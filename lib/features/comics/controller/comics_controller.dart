import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/features/comics/db/comics_db.dart';
import 'package:atlas_app/features/comics/models/comic_interacion_model.dart';
import 'package:atlas_app/features/interactions/db/interactions_db.dart';
import 'package:atlas_app/features/library/models/my_work_model.dart';
import 'package:atlas_app/features/library/providers/my_favorite_state.dart';
import 'package:atlas_app/features/novels/providers/comic_views.dart';
import 'package:atlas_app/imports.dart';
import 'package:uuid/uuid.dart';

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
  InteractionsDb get _interactionsDb => InteractionsDb();

  Uuid uuid = const Uuid();

  Future<List<ComicModel>> searchComics(String query, {int limit = 20, bool more = false}) async {
    try {
      log('here');
      return await db.searchComics(query, limit: limit, more: more);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> viewComic() async {
    try {
      final comic = _ref.read(selectedComicProvider)!;
      if (!comic.is_viewed) {
        final me = _ref.read(userState).user!;
        await db.viewComic(userId: me.userId, comicId: comic.comicId);
      } else {
        log("i already view this manhwa");
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<ComicInteracionModel> handleInteracion() async {
    try {
      final comic = _ref.read(selectedComicProvider)!;
      final me = _ref.read(userState.select((s) => s.user!));
      if (comic.interaction == null) {
        log("new interacion inserting...");
        final interacion = await newComicInteraction(comic: comic, user: me);
        log(interacion.toString());
        _ref.read(selectedComicProvider.notifier).state = comic.copyWith(interaction: interacion);
        await _interactionsDb.upsertComicInteraction(interacion);
        return interacion;
      }
      return comic.interaction!;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<ComicInteracionModel> newComicInteraction({
    required ComicModel comic,
    required UserModel user,
    bool upsert = false,
  }) async {
    final interaction =
        (comic.interaction == null || upsert)
            ? ComicInteracionModel(
              id: uuid.v4(),
              userId: user.userId,
              comicId: comic.comicId,
              favorite: comic.user_favorite,
              shared: false,
              liked: comic.user_favorite,
            )
            : comic.interaction!;
    return interaction;
  }

  Future<void> handleComicUpdate(ComicModel comic, bool fromSearch) async {
    try {
      log("from search: $fromSearch");
      final updatedComic = await db.handleUpdateComic(comic, fromSearch);
      if (updatedComic != null) {
        _ref.read(comicViewsStateProvider.notifier).updateComic(updatedComic);
        _ref.read(selectedComicProvider.notifier).state = updatedComic;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> toggleFavorite() async {
    final comic = _ref.read(selectedComicProvider)!;
    final me = _ref.read(userState.select((s) => s.user!));
    try {
      final updatedComic = comic.copyWith(user_favorite: !comic.user_favorite);
      _ref.read(selectedComicProvider.notifier).state = updatedComic;
      _ref.read(comicViewsStateProvider.notifier).updateComic(updatedComic);
      if (comic.user_favorite) {
        _ref.read(userFavoriteState(me.userId).notifier).deleteWork(comic.comicId);
      } else {
        _ref
            .read(userFavoriteState(me.userId).notifier)
            .addWork(
              MyWorkModel(
                title: comic.englishTitle,
                type: 'comic',
                poster: comic.image,
                id: comic.comicId,
              ),
            );
      }

      ComicInteracionModel interacionModel;
      if (comic.interaction == null) {
        interacionModel = await handleInteracion();
      } else {
        interacionModel = comic.interaction!;
      }
      await Future.wait([
        db.toggleFavoriteComic(comic.comicId),
        _interactionsDb.upsertComicInteraction(
          interacionModel.copyWith(favorite: !comic.user_favorite, liked: !comic.user_favorite),
        ),
      ]);
      CustomToast.success(
        "تمت ${comic.user_favorite ? "ازالة" : "اضافة"} العمل ${comic.user_favorite ? "من" : "الى"} المفضلة بنجاح",
      );
    } catch (e) {
      final originalComic = comic.copyWith(user_favorite: comic.user_favorite);
      _ref.read(selectedComicProvider.notifier).state = originalComic;
      _ref.read(userFavoriteState(me.userId).notifier).deleteWork(comic.comicId);
      _ref.read(selectedComicProvider.notifier).state = originalComic;
      _ref.read(comicViewsStateProvider.notifier).updateComic(originalComic);

      CustomToast.error(errorMsg);
      log(e.toString());
      rethrow;
    }
  }
}
