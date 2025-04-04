import 'package:atlas_app/imports.dart';

final selectedUserIdProvider = StateProvider<String>((ref) {
  return '';
});

final userTabsControllerProvider = StateProvider<TabController?>((ref) {
  return null;
});
