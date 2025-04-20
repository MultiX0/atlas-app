import 'package:atlas_app/imports.dart';

class EmptyChapters extends StatelessWidget {
  const EmptyChapters({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_data_cry_.gif', height: 130),
          const SizedBox(height: 15),
          const Text(
            "لايوجد أي فصول حاليا",
            style: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
