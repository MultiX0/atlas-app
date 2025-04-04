import 'package:atlas_app/imports.dart';

final searchQueryProvider = StateProvider<String>((ref) {
  return "";
});

final searchGlobalProvider = StateProvider<bool>((ref) {
  return false;
});
