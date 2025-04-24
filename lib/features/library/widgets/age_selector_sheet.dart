import 'package:atlas_app/imports.dart';

class AgeCategorySheet extends StatelessWidget {
  final void Function(int) onSelect;

  const AgeCategorySheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final ageCategories = [18, 16, 14];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              "اختر الفئة العمرية",
              style: TextStyle(
                fontFamily: arabicAccentFont,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
              color: AppColors.scaffoldBackground,
            ),
            child: Column(
              children:
                  ageCategories.map((category) {
                    return ListTile(
                      onTap: () {
                        context.pop();
                        onSelect(category);
                      },
                      title: Text(
                        '+$category',
                        style: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
                      ),
                      leading: const Icon(LucideIcons.shield, color: AppColors.mutedSilver),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
