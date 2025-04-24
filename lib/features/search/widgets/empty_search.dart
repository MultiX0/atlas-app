import 'package:atlas_app/imports.dart';

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_data_cry_.gif', height: 130),
          const SizedBox(height: 15),
          const Text(
            "سجل البحث فارغ",
            style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
