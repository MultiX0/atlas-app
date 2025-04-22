import 'package:atlas_app/core/common/utils/custom_action_sheet.dart';
import 'package:atlas_app/core/common/utils/delta_parser.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/chapters_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/chapter_interactions.dart';
import 'package:atlas_app/features/novels/widgets/share_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:no_screenshot/no_screenshot.dart';

class ChapterReadingPage extends ConsumerStatefulWidget {
  const ChapterReadingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChapterReadingPageState();
}

class _ChapterReadingPageState extends ConsumerState<ChapterReadingPage> {
  final _noScreenshot = NoScreenshot.instance;
  late ScrollController _scrollController;

  @override
  void initState() {
    if (!kDebugMode) {
      disableScreenshot();
    }
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleView();
    });
    super.initState();
  }

  void enableScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  void disableScreenshot() async {
    await _noScreenshot.screenshotOff();
  }

  void handleView() {
    ref.read(novelsControllerProvider.notifier).handleChapterView();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onPageChange() {
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, _) {
        enableScreenshot();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final chapter = ref.watch(selectedChapterProvider)!;
                  final operations = chapter.content;
                  final lines = parseDelta(operations);
                  final segments = groupLinesIntoSegments(lines);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        segments.asMap().entries.map((entry) {
                          // int segmentIndex = entry.key;
                          List<Line> segment = entry.value;

                          // Build TextSpans for the segment
                          String segmentText = segment
                              .map((line) => line.parts.map((part) => part.$1).join())
                              .join('\n');
                          List<TextSpan> segmentSpans = [];

                          for (int j = 0; j < segment.length; j++) {
                            var line = segment[j];
                            TextStyle headerStyle = getHeaderStyle(line.blockAttributes);
                            List<TextSpan> partSpans = [];

                            for (var part in line.parts) {
                              TextStyle inlineStyle = getInlineStyle(part.$2);
                              TextStyle partStyle;

                              if (line.blockAttributes != null &&
                                  line.blockAttributes!.isNotEmpty) {
                                partStyle = TextStyle(
                                  fontSize: headerStyle.fontSize ?? inlineStyle.fontSize ?? 16,
                                  fontWeight:
                                      headerStyle.fontWeight ??
                                      inlineStyle.fontWeight ??
                                      FontWeight.normal,
                                  fontFamily:
                                      headerStyle.fontFamily ??
                                      inlineStyle.fontFamily ??
                                      arabicPrimaryFont,
                                  color:
                                      headerStyle.color ??
                                      inlineStyle.color ??
                                      AppColors.whiteColor,
                                );
                              } else {
                                partStyle = TextStyle(
                                  fontSize: inlineStyle.fontSize ?? 16,
                                  fontWeight: inlineStyle.fontWeight ?? FontWeight.normal,
                                  fontFamily: inlineStyle.fontFamily ?? arabicPrimaryFont,
                                  color: inlineStyle.color ?? AppColors.whiteColor,
                                );
                              }

                              partSpans.add(TextSpan(text: part.$1, style: partStyle));
                            }

                            segmentSpans.add(TextSpan(children: partSpans));
                            if (j < segment.length - 1) {
                              segmentSpans.add(const TextSpan(text: '\n'));
                            }
                          }

                          return GestureDetector(
                            onLongPress: () {
                              openMenu(context, segmentText);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: RichText(
                                text: TextSpan(children: segmentSpans),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
              const SizedBox(height: 15),
              const NovelChapterInteractions(),
              const SizedBox(height: 15),
              ChapterButtonsController(onPageChange: onPageChange),
            ],
          ),
        ),
      ),
    );
  }
}

class ChapterButtonsController extends StatelessWidget {
  const ChapterButtonsController({super.key, required this.onPageChange});
  final VoidCallback onPageChange;

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
          final id = ref.watch(selectedChapterProvider.select((s) => s!.id));
          final novelId = ref.read(selectedChapterProvider.select((s) => s!.novelId));
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
                      ref.read(selectedChapterProvider.notifier).state = next;
                      onPageChange();
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
                      ref.read(selectedChapterProvider.notifier).state = prev;
                      onPageChange();
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

void openMenu(BuildContext context, content) {
  openSheet(
    context: context,
    child: Builder(
      builder: (context) {
        return CustomActionSheet(
          title: "الخيارات",
          children: [
            ListTile(
              title: const Text('مشاركة'),
              leading: const Icon(TablerIcons.share_2, color: AppColors.mutedSilver),
              titleTextStyle: const TextStyle(fontFamily: arabicPrimaryFont, fontSize: 16),
              onTap: () {
                context.pop();
                share(context, content);
              },
            ),
          ],
        );
      },
    ),
  );
}

void share(BuildContext context, String part) {
  openSheet(context: context, child: ShareWidget(content: part), scrollControlled: true);
}
