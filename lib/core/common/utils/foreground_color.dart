import 'package:atlas_app/imports.dart';

Color getFontColorForBackground(Color color) {
  return (color.computeLuminance() > 0.128) ? Colors.black : Colors.white;
}
