import 'package:atlas_app/imports.dart';

class EmptyRatingsWidget extends StatelessWidget {
  const EmptyRatingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.scaffoldBackground,
        border: Border.all(color: AppColors.blackColor, width: 3),
      ),
      child: const LanguageText(
        "لاتوجد أي تقييمات حاليا لهذا العمل, كن أول من يقيمه!",
        style: TextStyle(color: AppColors.mutedSilver),
      ),
    );
  }
}
