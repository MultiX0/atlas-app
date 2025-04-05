import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/comics/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';

final navsProvider = Provider<Navs>((ref) => Navs(ref: ref));

class Navs {
  final Ref _ref;
  Navs({required Ref ref}) : _ref = ref;

  void goToComicsPage(ComicModel comic) {
    _ref.read(selectedComicProvider.notifier).state = comic;
    _ref.read(routerProvider).push(Routes.manhwaPage);
  }
}
