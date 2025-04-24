import 'package:atlas_app/imports.dart';

class ChaptersDraftTile extends StatelessWidget {
  const ChaptersDraftTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        tileColor: AppColors.primaryAccent,
        onTap: () => context.push(Routes.novelChapterDrafts),
        leading: Icon(LucideIcons.book_key, color: AppColors.whiteColor),
        title: const Text("المسودة"),
        subtitle: const Text("هنا يمكنك التعديل على محتويات الفصول واسترجاع أي نسخ سابقة"),
        titleTextStyle: const TextStyle(fontFamily: arabicAccentFont, fontSize: 16),
        subtitleTextStyle: const TextStyle(
          fontFamily: arabicAccentFont,
          fontSize: 13,
          color: AppColors.mutedSilver,
        ),
      ),
    );
  }
}
