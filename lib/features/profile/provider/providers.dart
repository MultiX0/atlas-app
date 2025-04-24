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
