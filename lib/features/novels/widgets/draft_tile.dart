import 'dart:convert';

import 'package:atlas_app/core/common/utils/delta_translate.dart';
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
                title: Text(
                  extractLastLineFromQuillDelta(jsonEncode(draft.content)).trim().isEmpty
                      ? "مسودة فارغة"
                      : extractLastLineFromQuillDelta(jsonEncode(draft.content)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}
