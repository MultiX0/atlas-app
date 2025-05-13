import 'package:atlas_app/core/common/enum/post_like_enum.dart';
import 'package:atlas_app/imports.dart';

final selectedUserIdProvider = StateProvider<String>((ref) {
  return '';
});

final selectedUserProvider = StateProvider<UserModel?>((ref) {
  return null;
});

final userTabsControllerProvider = StateProvider<TabController?>((ref) {
  return null;
});

final selectedPostLikeTypeProvider = StateProvider<PostLikeEnum>((ref) {
  return PostLikeEnum.GENERAL;
});
