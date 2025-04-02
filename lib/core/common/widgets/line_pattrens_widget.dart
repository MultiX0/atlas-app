import 'package:atlas_app/imports.dart';

class LinesPattren extends StatelessWidget {
  const LinesPattren({super.key});
  static final cachedPattern = AvifImage.asset('assets/images/pattren.avif', fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: cachedPattern);
  }
}
