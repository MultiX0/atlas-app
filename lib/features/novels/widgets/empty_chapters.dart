import 'package:atlas_app/imports.dart';

class EmptyChapters extends StatelessWidget {
  const EmptyChapters({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_data_cry_.gif', height: 130),
          const SizedBox(height: 15),
          Text(text, style: const TextStyle(fontFamily: arabicAccentFont, fontSize: 18)),
        ],
      ),
    );
  }
}
