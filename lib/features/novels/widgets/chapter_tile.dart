import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ChapterTile extends StatelessWidget {
  const ChapterTile({super.key, required this.chapter});
  final ChapterModel chapter;

  @override
  Widget build(BuildContext context) {
    final bool haveDecimal = chapter.number != chapter.number.toInt();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .15)),
          Consumer(
            builder: (context, ref, _) {
              return ListTile(
                onTap: () {
                  ref.read(selectedChapterProvider.notifier).state = chapter;
                  context.push(Routes.novelReadChapter);
                },
                leading:
                    chapter.title == null
                        ? null
                        : Text(
                          '${haveDecimal ? chapter.number : chapter.number.toInt()} - ',
                          style: const TextStyle(fontSize: 16, color: AppColors.mutedSilver),
                        ),
                title:
                    chapter.title != null
                        ? Text(chapter.title!)
                        : Text(
                          "الفصل رقم : ${haveDecimal ? chapter.number : chapter.number.toInt()}",
                        ),
                titleTextStyle: const TextStyle(fontFamily: arabicAccentFont, fontSize: 20),
                subtitle: Text('تاريخ النشر: ${appDateTimeFormat(chapter.created_at)}'),
                subtitleTextStyle: const TextStyle(
                  fontFamily: arabicAccentFont,
                  fontSize: 12,
                  color: AppColors.mutedSilver,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
