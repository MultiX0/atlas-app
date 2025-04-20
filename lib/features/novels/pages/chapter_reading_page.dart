import 'dart:developer';

import 'package:atlas_app/core/common/utils/delta_parser.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/imports.dart';

class ChapterReadingPage extends ConsumerStatefulWidget {
  const ChapterReadingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChapterReadingPageState();
}

class _ChapterReadingPageState extends ConsumerState<ChapterReadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("قراءة")),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final chapter = ref.read(selectedChapterProvider)!;
                final operations = chapter.content;
                final lines = parseDelta(operations);
                final segments = groupLinesIntoSegments(lines);
                final textSpans = segmentsToTextSpans(segments, (text) {
                  log('Tapped on: $text');
                });
                return buildRichText(chapter.content, (_) {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
