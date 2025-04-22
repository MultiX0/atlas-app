import 'package:atlas_app/imports.dart';

class CharactersPage extends ConsumerWidget {
  const CharactersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_characters.gif', height: 130),
          const SizedBox(height: 15),
          const Text(
            "يتوفر قريبا...",
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
