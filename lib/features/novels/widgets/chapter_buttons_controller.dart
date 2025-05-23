import 'package:atlas_app/features/novels/providers/chapters_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ChapterButtonsController extends StatelessWidget {
  const ChapterButtonsController({super.key, required this.onPageChange});
  final Function(String) onPageChange;

  @override
  Widget build(BuildContext context) {
    const _style = TextStyle(
      fontFamily: arabicAccentFont,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Consumer(
        builder: (context, ref, _) {
          final id = ref.watch(currentChapterProvider.select((s) => s!.id));
          final novelId = ref.read(currentChapterProvider.select((s) => s!.novelId));
          final stateNotifier = chaptersStateProvider(novelId).notifier;

          bool isFirst = ref.read(stateNotifier).isFirst(id);
          bool isLast = ref.read(stateNotifier).isLast(id);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLast)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final next = ref.read(stateNotifier).getNext(id);

                      onPageChange(next!.id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Icon(LucideIcons.chevron_right), Text('التالي', style: _style)],
                      ),
                    ),
                  ),
                ),
              if (!isFirst)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final prev = ref.read(stateNotifier).getPrev(id);
                      onPageChange(prev!.id);
                    },

                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Text('السابق', style: _style), Icon(LucideIcons.chevron_left)],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
