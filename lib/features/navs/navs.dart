import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:atlas_app/router.dart';

final navsProvider = Provider<Navs>((ref) => Navs(ref: ref));

class Navs {
  final Ref _ref;
  Navs({required Ref ref}) : _ref = ref;
  GoRouter get router => _ref.read(routerProvider);

  void goToComicsPage(ComicModel comic) {
    _ref.read(selectedComicProvider.notifier).state = comic;
    router.push(Routes.manhwaPage);
  }

  void goToAddComicReviewPage(String update) {
    router.push("${Routes.addComicReview}/$update");
  }

  void goToMakePostPage(PostType postType) {
    _ref.read(postTypeProvider.notifier).state = postType;
    router.push("${Routes.makePostPage}/${postType.name.trim()}");
  }
}
