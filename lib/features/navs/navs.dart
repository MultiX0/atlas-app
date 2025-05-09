import 'package:atlas_app/features/hashtags/providers/providers.dart';
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

  void goToAddReviewPage(String update, ReviewsEnum reviewType) {
    router.push("${Routes.addComicReview}/$update/${reviewType.toStringValue()}");
  }

  void goToMakePostPage(PostType postType) {
    _ref.read(postTypeProvider.notifier).state = postType;
    router.push("${Routes.makePostPage}/${postType.name.trim()}");
  }

  void goToHashtagPage(String hashtag) {
    _ref.read(selectedHashtagProvider.notifier).state = hashtag;
    router.push("${Routes.hashtagsPage}/$hashtag");
  }
}
