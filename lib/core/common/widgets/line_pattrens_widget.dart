import 'package:atlas_app/imports.dart';

class LinesPattren extends StatelessWidget {
  const LinesPattren({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.white.withValues(alpha: .06), BlendMode.srcATop),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/pattren.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
