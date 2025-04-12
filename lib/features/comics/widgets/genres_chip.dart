import 'package:atlas_app/imports.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.genre, required this.color, required this.textColor});

  final dynamic genre; // Using dynamic to match original code type
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(
        textAlign: TextAlign.end,
        textDirection: TextDirection.rtl,
        genre.ar_name,
        style: TextStyle(
          fontFamily: arabicPrimaryFont,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
