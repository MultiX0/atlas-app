import 'dart:async';

import 'package:atlas_app/core/common/utils/custom_action_sheet.dart';
import 'package:atlas_app/core/common/utils/delta_parser.dart';
import 'package:atlas_app/core/common/widgets/error_widget.dart';
import 'package:atlas_app/core/common/widgets/reports/report_widget.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/chapter_state.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/chapter_buttons_controller.dart';
import 'package:atlas_app/features/novels/widgets/chapter_interactions.dart';
import 'package:atlas_app/features/novels/widgets/share_widget.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:no_screenshot/no_screenshot.dart';

// Provider for memoizing parsed segments
final segmentsProvider = Provider.family<List<List<Line>>, String>((ref, chapterId) {
  final chapterData = ref.watch(chapterStateProvider(chapterId));
  final chapter = chapterData.chapter;
  if (chapter == null) {
    return [];
  }
  final operations = chapter.content;
  final lines = parseDelta(operations);
  return groupLinesIntoSegments(lines);
});

class ChapterReadingPage extends HookConsumerWidget {
  const ChapterReadingPage({super.key, required this.chapterId});

  final String chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First define all state variables
    final timeSpentRef = useRef(0);
    final lastSavedTimeRef = useRef(-60);

    // Fetch chapter data
    useEffect(() {
      Future.microtask(() async {
        final chapter = await ref.read(chapterStateProvider(chapterId).notifier).fetchData();
        ref.read(currentChapterProvider.notifier).state = chapter;
      });
      return null;
    }, [chapterId]);

    // Hooks must be called in a consistent order
    // 1. Create scroll controller
    final scrollController = useScrollController();

    // 2. Initialize NoScreenshot instance
    final noScreenshot = useMemoized(() => NoScreenshot.instance);

    // 3. Define the update time callback
    final updateTimeCallback = useCallback(() {
      timeSpentRef.value += 1;

      if (timeSpentRef.value % 60 == 0 && timeSpentRef.value != lastSavedTimeRef.value) {
        lastSavedTimeRef.value = timeSpentRef.value;
        ref.read(novelsControllerProvider.notifier).handleSaveReadingTime(timeSpentRef.value);
      }
    }, []);

    // 4. Setup interval hook
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTimeCallback());
      return timer.cancel;
    }, [updateTimeCallback]);

    // 5. Setup screenshot protection effect
    useEffect(() {
      if (!kDebugMode) {
        noScreenshot.screenshotOff();
      }
      return () {
        noScreenshot.screenshotOn();
      };
    }, [noScreenshot]);

    // 6. Setup chapter view effect
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.microtask(() {
          ref.read(novelsControllerProvider.notifier).handleChapterView(chapterId);
        });
      });
      return null;
    }, []);

    // Page change callback (defined outside the hooks)
    void onPageChange(String id) {
      ref.read(novelsControllerProvider.notifier).handleSaveReadingTime(timeSpentRef.value);
      context.pushReplacement("${Routes.novelReadChapter}/$id");
    }

    // Watch loading state
    final chapterState = ref.watch(chapterStateProvider(chapterId));
    final isLoading = chapterState.isLoading;
    final error = chapterState.error != null;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {
        noScreenshot.screenshotOn();
        ref.read(novelsControllerProvider.notifier).handleSaveReadingTime(timeSpentRef.value);
      },
      child: Scaffold(
        backgroundColor: AppColors.readingBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => openReportSheet(context, ref, chapterId),
              icon: const Icon(TablerIcons.report),
            ),
          ],
        ),
        body:
            error
                ? AtlasErrorPage(message: chapterState.error!)
                : isLoading
                ? const Loader()
                : Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    itemCount: 3, // Segments + Interactions + Buttons
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildChapterContent(ref);
                      } else if (index == 1) {
                        return const Column(
                          children: [
                            SizedBox(height: 15),
                            NovelChapterInteractions(),
                            SizedBox(height: 15),
                          ],
                        );
                      } else {
                        return ChapterButtonsController(onPageChange: (id) => onPageChange(id));
                      }
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildChapterContent(WidgetRef ref) {
    // Watch segments provider (memoized)
    final segments = ref.watch(segmentsProvider(chapterId));

    if (segments.isEmpty) {
      return const Center(child: Text("No content available"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: segments.length,
      itemBuilder: (context, segmentIndex) {
        final segment = segments[segmentIndex];
        final segmentSpans = _buildSegmentSpans(segment);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onLongPress: () {
              String segmentText = segment
                  .map((line) => line.parts.map((part) => part.$1).join())
                  .join('\n');
              openMenu(context, segmentText);
            },
            child: RichText(
              text: TextSpan(children: segmentSpans),
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      },
    );
  }

  List<TextSpan> _buildSegmentSpans(List<Line> segment) {
    final segmentSpans = <TextSpan>[];

    for (int j = 0; j < segment.length; j++) {
      final line = segment[j];
      final headerStyle = getHeaderStyle(line.blockAttributes);
      final partSpans = <TextSpan>[];

      for (final part in line.parts) {
        final inlineStyle = getInlineStyle(part.$2);
        final partStyle = _computePartStyle(headerStyle, inlineStyle, line.blockAttributes);

        partSpans.add(TextSpan(text: part.$1, style: partStyle));
      }

      segmentSpans.add(TextSpan(children: partSpans));
      if (j < segment.length - 1) {
        segmentSpans.add(const TextSpan(text: '\n'));
      }
    }

    return segmentSpans;
  }

  TextStyle _computePartStyle(
    TextStyle? headerStyle,
    TextStyle inlineStyle,
    Map<String, dynamic>? blockAttributes,
  ) {
    //  final defaultStyle = TextStyle(
    //   fontSize: 16,
    //   fontWeight: FontWeight.normal,
    //   fontFamily: arabicPrimaryFont,
    //   color: AppColors.whiteColor,
    // );

    if (blockAttributes != null && blockAttributes.isNotEmpty) {
      return TextStyle(
        fontSize: headerStyle?.fontSize ?? inlineStyle.fontSize ?? 16,
        fontWeight: headerStyle?.fontWeight ?? inlineStyle.fontWeight ?? FontWeight.normal,
        fontFamily: headerStyle?.fontFamily ?? inlineStyle.fontFamily ?? arabicPrimaryFont,
        color: headerStyle?.color ?? inlineStyle.color ?? AppColors.readingTextColor,
      );
    }

    return TextStyle(
      fontSize: inlineStyle.fontSize ?? 16,
      fontWeight: inlineStyle.fontWeight ?? FontWeight.normal,
      fontFamily: inlineStyle.fontFamily ?? arabicPrimaryFont,
      color: inlineStyle.color ?? AppColors.readingTextColor,
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

void openReportSheet(BuildContext context, WidgetRef ref, String chapterId) {
  openSheet(
    context: context,
    child: ReportSheet(
      title: "الإبلاغ عن فصل رواية",
      reasons: const [
        ReportReason(
          title: "محتوى مسيء أو غير لائق",
          subtitle: "يحتوي على خطاب كراهية، مشاهد جنسية صريحة، أو محتوى غير مناسب.",
        ),
        ReportReason(
          title: "عنف مفرط أو محتوى ضار",
          subtitle: "يتضمن عنفًا غير مبرر، تعذيبًا، أو الترويج لإيذاء النفس.",
        ),
        ReportReason(
          title: "انتهاك حقوق الملكية الفكرية",
          subtitle: "يشمل سرقة أدبية أو استخدام محتوى محمي دون إذن.",
        ),
        ReportReason(
          title: "تحرش أو تنمر",
          subtitle: "يستهدف أفرادًا أو مجموعات بمضايقات أو تهديدات.",
        ),
        ReportReason(
          title: "محتوى غير قانوني",
          subtitle: "يروج لأنشطة غير قانونية أو ينتهك القوانين المعمول بها.",
        ),
        ReportReason(
          title: "تصنيف غير صحيح",
          subtitle: "يحتوي على مواضيع حساسة دون وسمه كـ +18 أو تحت فئة مناسبة.",
        ),
      ],
      onSubmit: (reason) {
        ref
            .read(novelsControllerProvider.notifier)
            .addChapterReport(report: reason, context: context, chapterId: chapterId);
      },
    ),
  );
}
