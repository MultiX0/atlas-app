import 'package:atlas_app/imports.dart';

final postInputProvider = StateProvider<String>((ref) {
  return "";
});

final postTypeProvider = StateProvider<PostType>((ref) {
  return PostType.normal;
});

final selectedPostProvider = StateProvider<PostModel?>((ref) {
  return null;
});
