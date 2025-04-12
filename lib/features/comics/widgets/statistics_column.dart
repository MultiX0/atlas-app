import 'package:atlas_app/imports.dart';

class StatisticsColumn extends StatelessWidget {
  const StatisticsColumn({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.mutedSilver, fontFamily: arabicAccentFont),
        ),
        const SizedBox(height: 15),
        Text(
          value,
          style: TextStyle(
            fontFamily: arabicAccentFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
      ],
    );
  }
}
