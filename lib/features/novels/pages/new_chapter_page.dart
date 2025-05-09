import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/delta_translate.dart';
import 'package:atlas_app/core/common/widgets/overlay_boundry.dart';
import 'package:atlas_app/features/novels/controller/novels_controller.dart';
import 'package:atlas_app/features/novels/providers/providers.dart';
import 'package:atlas_app/features/novels/widgets/save_sheet.dart';
import 'package:atlas_app/features/novels/widgets/writing_instructions.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AddChapterPage extends ConsumerStatefulWidget {
  const AddChapterPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddChapterState();
}

class _AddChapterState extends ConsumerState<AddChapterPage> {
  final text_title_controller = TextEditingController();
  bool title_has_arabic = false;
  bool body_has_arabic = false;
  late QuillController _controller;
  final _editorScrollController = ScrollController();
  final _editorFocusNode = FocusNode();
  late Timer _timer;
  int count = 0;
  bool showTitleField = true;

  @override
  void initState() {
    _controller = QuillController.basic();
    _controller.addListener(_trackCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackCount();
      loadPrevious();
      handleSave();
      _controller.addListener(_trackTyping);
    });
    super.initState();
  }

  @override
  void dispose() {
    text_title_controller.dispose();
    _controller.removeListener(_trackCount);
    _controller.removeListener(_trackTyping);
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _trackTyping() {
    if (showTitleField) {
      setState(() {
        showTitleField = false;
      });
    }
  }

  void _trackCount() {
    setState(() {
      count = countDeltaCharacters(_controller.document.toDelta().toJson());
    });
  }

  List<Map<String, dynamic>>? lastSave;
  String? draftId;
  String lastTitleSave = '';

  void loadPrevious() {
    final draft = ref.read(selectedDraft);
    if (draft != null) {
      draftId = draft.id;
      lastSave = draft.content;
      lastTitleSave = draft.title ?? text_title_controller.text.trim();
      setState(() {
        _controller.document = Document.fromJson(draft.content);
        text_title_controller.text = lastTitleSave;
      });
    } else {
      ref
          .read(novelsControllerProvider.notifier)
          .newDraft(
            jsonContent: _controller.document.toDelta().toJson(),
            title: text_title_controller.text.trim(),
          );
    }
  }

  void handleSave() async {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final json = _controller.document.toDelta().toJson();

      if (lastSave == null) {
        lastSave = json;

        final id = await ref
            .read(novelsControllerProvider.notifier)
            .newDraft(jsonContent: json, title: text_title_controller.text.trim());
        draftId = id;
      }

      if (jsonEncode(json).trim() == jsonEncode(lastSave).trim() &&
          text_title_controller.text.trim() == lastTitleSave.trim()) {
        log("no changes");
      } else {
        log("there's a change");
        await ref
            .read(novelsControllerProvider.notifier)
            .updateDraft(
              jsonContent: json,
              title: text_title_controller.text.trim(),
              draftId: draftId!,
            );
      }

      lastSave = json;
      lastTitleSave = text_title_controller.text.trim();
    });
  }

  void save() async {
    log(text_title_controller.text.trim());
    final json = _controller.document.toDelta().toJson();
    await ref
        .read(novelsControllerProvider.notifier)
        .updateDraft(
          jsonContent: json,
          title: text_title_controller.text.trim(),
          draftId: draftId!,
        );
  }

  Future<bool> showExitConfirmationDialog(BuildContext context) async {
    const btnStyle = TextStyle(fontFamily: arabicAccentFont, color: AppColors.primary);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryAccent,
          title: const Text(
            "تحذير: مغادرة الصفحة",
            style: TextStyle(fontFamily: arabicAccentFont),
            textDirection: TextDirection.rtl,
          ),
          content: const Text(
            'اذا كنت تريد المغادرة الأن سيتم حفظ جميع تقدمك الى الأن في المسودة و تستطيع العودة لاحقا في أي وقت واكمال الكتابة',
            style: TextStyle(fontFamily: arabicPrimaryFont),
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                save();
              },
              child: const Text("استمرار", style: btnStyle),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("الغاء", style: btnStyle),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        bool value = await showExitConfirmationDialog(context);
        if (!mounted) return;
        if (value) {
          // ignore: use_build_context_synchronously
          context.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("مسودة"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: arabicAccentFont,
                  fontSize: 16,
                ),
              ),
              onPressed: () => showWritingInstructionsSheet(context),
              child: const Text("التعليمات"),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  showTitleField = !showTitleField;
                });
              },
              icon: Icon(showTitleField ? TablerIcons.eye : TablerIcons.eye_closed),
            ),

            IconButton(
              onPressed:
                  () => openSheet(
                    context: context,
                    child: ChapterSaveSheet(
                      jsonContent: _controller.document.toDelta().toJson(),
                      title: text_title_controller.text.trim(),
                    ),
                  ),
              icon: const Icon(Icons.done),
            ),
          ],
        ),
        body: OverlayBoundary(
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (showTitleField) ...[
                      CustomTextFormField(
                        controller: text_title_controller,
                        hintText: "عنوان الفصل (اختياري)",
                        maxLength: 100,
                        filled: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Divider(color: Colors.grey[800]),
                      ),
                    ],

                    Expanded(
                      child: QuillEditor.basic(
                        controller: _controller,
                        scrollController: _editorScrollController,
                        focusNode: _editorFocusNode,
                        config: QuillEditorConfig(
                          onLaunchUrl: (_) {},
                          customStyleBuilder: (attribute) {
                            return TextStyle(
                              fontFamily: arabicPrimaryFont,
                              color: AppColors.whiteColor,
                            );
                          },
                          customStyles: DefaultStyles(
                            paragraph: DefaultTextBlockStyle(
                              TextStyle(fontFamily: arabicPrimaryFont, color: AppColors.whiteColor),
                              HorizontalSpacing.zero,
                              VerticalSpacing.zero,
                              VerticalSpacing.zero,
                              null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text("$count حرف", textAlign: TextAlign.end),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: QuillSimpleToolbar(
                        controller: _controller,
                        config: const QuillSimpleToolbarConfig(
                          buttonOptions: QuillSimpleToolbarButtonOptions(
                            redoHistory: QuillToolbarHistoryButtonOptions(tooltip: "إعادة"),
                            undoHistory: QuillToolbarHistoryButtonOptions(tooltip: 'تراجع'),
                            bold: QuillToolbarToggleStyleButtonOptions(tooltip: "عريض"),
                            selectHeaderStyleDropdownButton:
                                QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                                  defaultDisplayText: "طبيعي",
                                  textStyle: TextStyle(fontFamily: arabicAccentFont),
                                  attributes: [Attribute.h3, Attribute.h4, Attribute.header],
                                ),
                            fontSize: QuillToolbarFontSizeButtonOptions(
                              defaultDisplayText: "حجم الخط",
                              style: TextStyle(fontFamily: arabicAccentFont),
                              items: {
                                "صغير": "small",
                                "كبير": "large",
                                "ضخم": "huge",
                                "إزالة الحجم": "0",
                              },
                            ),
                          ),

                          showSubscript: false,
                          showFontFamily: false,
                          showSuperscript: false,
                          showClipboardCopy: false,
                          showIndent: false,
                          showClipboardCut: false,
                          showClipboardPaste: false,
                          showDirection: false,
                          showUnderLineButton: false,
                          showAlignmentButtons: false,
                          showBackgroundColorButton: false,
                          showBoldButton: true,
                          showCenterAlignment: false,
                          showClearFormat: false,
                          showCodeBlock: false,
                          showColorButton: false,
                          showFontSize: true,
                          showItalicButton: false,
                          showSmallButton: false,
                          showSearchButton: false,
                          showInlineCode: false,
                          showStrikeThrough: false,
                          showListNumbers: false,
                          showListBullets: false,
                          showListCheck: false,
                          showQuote: false,
                          showLink: false,
                          showHeaderStyle: true,
                          showUndo: false,
                          showRedo: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
