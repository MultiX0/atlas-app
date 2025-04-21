import 'package:atlas_app/core/common/utils/custom_toast.dart';
import 'package:atlas_app/core/common/utils/delta_translate.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';

class ChapterSaveSheet extends StatelessWidget {
  const ChapterSaveSheet({super.key, required this.title, required this.jsonContent});
  final List<Map<String, dynamic>> jsonContent;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "الخيارات",
          style: TextStyle(fontFamily: arabicAccentFont, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        buildActionList(context),
      ],
    );
  }

  Widget buildActionList(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Spacing.normalRaduis + 5),
      color: AppColors.scaffoldBackground,
    ),
    child: Material(
      color: Colors.transparent,
      child: Consumer(
        builder: (context, ref, _) {
          final draft = ref.read(selectedDraft);
          return Column(
            children: [
              buildTile(
                "حفظ المسودة",
                onTap: () {
                  context.pop();
                  if (draft == null) {
                    CustomToast.error("المسودة الحالية فارغة, الرجاء المحاولة لاحقا");
                    context.pop();
                    return;
                  }
                  ref
                      .read(novelsControllerProvider.notifier)
                      .updateDraft(jsonContent: jsonContent, title: title, draftId: draft.id);
                  CustomToast.success("تم حفظ المسودة بنجاح");
                  context.pop();
                },
                icons: LucideIcons.save,
              ),
              Builder(
                builder: (context) {
                  return buildTile(
                    "نشر الفصل",
                    onTap: () {
                      final count = countDeltaCharacters(jsonContent);
                      if (count < 1000 && !kDebugMode) {
                        CustomToast.error(
                          "على الفصل أن يحتوي على 1000 حرف على الأقل و 5000 حرف كحد أقصى",
                        );
                        context.pop();
                        return;
                      }
                      if (draft == null) {
                        CustomToast.error("المسودة الحالية فارغة, الرجاء المحاولة لاحقا");
                        context.pop();
                        return;
                      }
                      ref
                          .read(novelsControllerProvider.notifier)
                          .publishChapter(draft.copyWith(content: jsonContent), context);
                    },
                    icons: TablerIcons.checks,
                  );
                },
              ),
            ],
          );
        },
      ),
    ),
  );

  Widget buildTile(String text, {required Function() onTap, required IconData icons}) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icons, color: AppColors.mutedSilver),
            title: Row(children: [Text(text)]),

            titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
          ),
        );
      },
    );
  }
}
