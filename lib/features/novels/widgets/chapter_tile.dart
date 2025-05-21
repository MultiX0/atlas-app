import 'dart:developer';

import 'package:atlas_app/core/common/utils/custom_action_sheet.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/models/chapter_model.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:uuid/uuid.dart';

class ChapterTile extends StatelessWidget {
  const ChapterTile({super.key, required this.chapter, required this.isCreator});
  final ChapterModel chapter;
  final bool isCreator;

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
                  ref.read(currentChapterProvider.notifier).state = chapter;
                  context.push("${Routes.novelReadChapter}/${chapter.id}");
                },

                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        chapter.title != null
                            ? "${chapter.number.toInt()} : ${chapter.title!}"
                            : "الفصل رقم : ${haveDecimal ? chapter.number : chapter.number.toInt()}",
                      ),
                    ),
                    Text(
                      formatNumber(chapter.views),
                      style: const TextStyle(
                        fontWeight: FontWeight.w200,
                        color: AppColors.mutedSilver,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(TablerIcons.eye, color: AppColors.mutedSilver, size: 18),
                    const SizedBox(width: 15),
                    if (isCreator)
                      GestureDetector(
                        onTap: () => buildActionList(context, ref),
                        child: const Icon(TablerIcons.dots_vertical, color: AppColors.mutedSilver),
                      ),
                  ],
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

  void buildActionList(BuildContext context, WidgetRef ref) {
    openSheet(
      context: context,
      child: CustomActionSheet(
        title: "خيارات",
        children: [
          ListTile(
            title: const Text('تعديل'),
            leading: const Icon(TablerIcons.edit, color: AppColors.mutedSilver),
            titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
            onTap: () {
              final id = const Uuid().v4();
              final now = DateTime.now();
              final me = ref.read(userState.select((s) => s.user!));
              log("the original chapter id is: ${chapter.id}");
              final draft = ChapterDraftModel(
                id: id,
                createdAt: now,
                updatedAt: now,
                novelId: chapter.novelId,
                content: chapter.content,
                userId: me.userId,
                title: chapter.title,
                number: chapter.number,
                originalChapterId: chapter.id,
              );
              ref.read(selectedDraft.notifier).state = draft;
              context.pop();
              context.push(Routes.addNovelChapterPage);
            },
          ),
          ListTile(
            title: const Text('حذف'),
            leading: const Icon(TablerIcons.trash, color: AppColors.mutedSilver),
            titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
            onTap: () {
              context.pop();
              alertDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void alertDialog(BuildContext context) {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return AlertDialog(
              backgroundColor: AppColors.primaryAccent,
              title: const Text(
                textDirection: TextDirection.rtl,
                " هل أنت متأكد من حذف هذا الفصل؟",
                style: TextStyle(fontFamily: arabicAccentFont),
              ),
              content: const Text(
                'لا يمكن التراجع عن هذا الإجراء. سيتم حذف الفصل وجميع التفاعلات المرتبطة به نهائيًا.',
                style: TextStyle(fontFamily: arabicPrimaryFont),
                textDirection: TextDirection.rtl,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(novelsControllerProvider.notifier).deleteChapter(chapter);
                    context.pop();
                  },
                  child: const Text("الااستمرار", style: btnStyle),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("عودة", style: btnStyle),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
