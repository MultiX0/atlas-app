import 'package:atlas_app/imports.dart';

String colorToStirng(Color color) {
  // ignore: deprecated_member_use
  return color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
}
