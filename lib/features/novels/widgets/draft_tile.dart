import 'dart:convert';

import 'package:atlas_app/core/common/utils/custom_action_sheet.dart';
import 'package:atlas_app/core/common/utils/delta_translate.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class DraftTile extends StatelessWidget {
  const DraftTile({super.key, required this.draft});

  final ChapterDraftModel draft;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Divider(height: 0.25, color: AppColors.mutedSilver.withValues(alpha: .15)),
          Consumer(
            builder: (context, ref, _) {
              return ListTile(
                onTap: () {
                  ref.read(selectedDraft.notifier).state = draft;
                  context.push(Routes.addNovelChapterPage);
                },
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        extractLastLineFromQuillDelta(jsonEncode(draft.content)).trim().isEmpty
                            ? "مسودة فارغة"
                            : extractLastLineFromQuillDelta(jsonEncode(draft.content)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => buildActionList(context, ref),
                      child: const Icon(TablerIcons.dots_vertical, color: AppColors.mutedSilver),
                    ),
                  ],
                ),
                subtitle: Text("أخر تحديث في: ${appDateTimeFormat(draft.updatedAt)}"),
                titleTextStyle: const TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
                subtitleTextStyle: const TextStyle(
                  fontFamily: arabicAccentFont,
                  fontSize: 14,
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
                " هل أنت متأكد من حذف هذه المسودة؟",
                style: TextStyle(fontFamily: arabicAccentFont),
              ),
              content: const Text(
                'لا يمكن التراجع عن هذا الإجراء. سيتم حذف المسودة وجميع التفاعلات المرتبطة بها نهائيًا.',
                style: TextStyle(fontFamily: arabicPrimaryFont),
                textDirection: TextDirection.rtl,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(novelsControllerProvider.notifier).deleteDraft(draft);
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
