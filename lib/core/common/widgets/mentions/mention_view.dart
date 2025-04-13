import 'dart:developer';

import 'package:atlas_app/core/common/widgets/mentions/annotation_editing_controller.dart';
import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/core/common/widgets/mentions/option_list.dart';
import 'package:atlas_app/imports.dart';
import 'package:flutter/services.dart';

// Enhanced version of FlutterMentions with per-trigger callbacks
class EnhancedFlutterMentions extends StatefulWidget {
  const EnhancedFlutterMentions({
    required this.mentions,
    super.key,
    this.defaultText,
    this.suggestionPosition = SuggestionPosition.Bottom,
    this.suggestionListHeight = 300.0,
    this.onMarkupChanged,
    this.onMentionAdd,
    this.onSearchChanged,
    this.triggerCallbacks = const {}, // New parameter for per-trigger callbacks
    this.leading = const [],
    this.trailing = const [],
    this.suggestionListDecoration,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.none,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.onTap,
    this.buildCounter,
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.appendSpaceOnAdd = true,
    this.hideSuggestionList = false,
    this.onSuggestionVisibleChanged,
  });

  final bool hideSuggestionList;
  final String? defaultText;
  final Function(bool)? onSuggestionVisibleChanged;
  final List<Mention> mentions;
  final List<Widget> leading;
  final List<Widget> trailing;
  final SuggestionPosition suggestionPosition;
  final Function(Map<String, dynamic>)? onMentionAdd;
  final double suggestionListHeight;
  final ValueChanged<String>? onMarkupChanged;
  final void Function(String trigger, String value)? onSearchChanged;

  // New parameter: Map of trigger to callback function
  final Map<String, void Function(String)> triggerCallbacks;

  final BoxDecoration? suggestionListDecoration;
  final FocusNode? focusNode;
  final bool appendSpaceOnAdd;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final int? minLines;
  final bool expands;
  final bool readOnly;
  final bool? showCursor;
  final int? maxLength;
  final MaxLengthEnforcement maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final bool? enabled;
  final double cursorWidth;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final GestureTapCallback? onTap;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Iterable<String>? autofillHints;

  @override
  EnhancedFlutterMentionsState createState() => EnhancedFlutterMentionsState();
}

class EnhancedFlutterMentionsState extends State<EnhancedFlutterMentions> {
  EnhancedAnnotationEditingController? controller;
  ValueNotifier<bool> showSuggestions = ValueNotifier(false);
  LengthMap? _selectedMention;
  String _pattern = '';

  // Track the currently active trigger
  String? _currentTrigger;

  // Track the previously processed text to avoid redundant calls

  Map<String, Annotation> mapToAnotation() {
    final data = <String, Annotation>{};

    for (var element in widget.mentions) {
      if (element.matchAll) {
        data['${element.trigger}([A-Za-z0-9])*'] = Annotation(
          data: null,
          style: element.style,
          id: null,
          display: null,
          trigger: element.trigger,
          disableMarkup: element.disableMarkup,
          markupBuilder: element.markupBuilder,
        );
      }

      for (var e in element.data) {
        data["${element.trigger}${e['display']}"] =
            e['style'] != null
                ? Annotation(
                  style: e['style'],
                  id: e['id'],
                  data: e,
                  display: e['display'],
                  trigger: element.trigger,
                  disableMarkup: element.disableMarkup,
                  markupBuilder: element.markupBuilder,
                )
                : Annotation(
                  data: e,
                  style: element.style,
                  id: e['id'],
                  display: e['display'],
                  trigger: element.trigger,
                  disableMarkup: element.disableMarkup,
                  markupBuilder: element.markupBuilder,
                );
      }
    }

    return data;
  }

  void addMention(Map<String, dynamic> value, [Mention? list]) {
    final selectedMention = _selectedMention!;

    setState(() {
      _selectedMention = null;
    });

    final _list = widget.mentions.firstWhere(
      (element) => selectedMention.str.contains(element.trigger),
    );

    controller!.text = controller!.value.text.replaceRange(
      selectedMention.start,
      selectedMention.end,
      "${_list.trigger}${value['display']}${widget.appendSpaceOnAdd ? ' ' : ''}",
    );

    if (widget.onMentionAdd != null) widget.onMentionAdd!(value);

    // Log the markdown after adding mention
    if (_list.trigger == '/') {
      log("Added slash mention. Markdown: ${controller!.markupText}");
    }

    var nextCursorPosition = selectedMention.start + 1 + value['display']?.length as int? ?? 0;
    if (widget.appendSpaceOnAdd) nextCursorPosition++;
    controller!.selection = TextSelection.fromPosition(TextPosition(offset: nextCursorPosition));
  }

  void suggestionListerner() {
    final cursorPos = controller!.selection.baseOffset;
    final text = controller!.text;

    if (cursorPos < 0) return;

    final mentionTriggers = widget.mentions.map((e) => e.trigger).toList();
    final slashMention = widget.mentions.firstWhere(
      (e) => e.trigger == '/',
      orElse: () => Mention(trigger: '/', data: []), // ✅ FIXED: return dummy Mention, not null
    );

    // Handle slash trigger with space support
    if (slashMention.trigger == '/') {
      int start = cursorPos - 1;
      while (start >= 0 && text[start] != '\n') {
        if (text[start] == '/') {
          break;
        }
        start--;
      }

      if (start >= 0 && text[start] == '/') {
        final substring = text.substring(start, cursorPos);
        final mention = LengthMap(str: substring, start: start, end: cursorPos);

        setState(() {
          _selectedMention = mention;
          _currentTrigger = '/';
        });

        final query = substring.substring(1); // Remove the slash
        widget.triggerCallbacks['/']?.call(query);

        showSuggestions.value = true;
        widget.onSuggestionVisibleChanged?.call(true);
        return;
      }
    }

    // Fallback to original logic for other triggers
    var _pos = 0;
    final lengthMap = <LengthMap>[];

    controller!.value.text.split(RegExp(r'(\s)')).forEach((element) {
      lengthMap.add(LengthMap(str: element, start: _pos, end: _pos + element.length));
      _pos = _pos + element.length + 1;
    });

    final val = lengthMap.indexWhere((element) {
      _pattern = widget.mentions.map((e) => e.trigger).join('|');
      return element.end == cursorPos && mentionTriggers.any((t) => element.str.startsWith(t));
    });

    if (val != -1) {
      final mention = lengthMap[val];

      setState(() {
        _selectedMention = mention;
        _currentTrigger = mentionTriggers.firstWhere((t) => mention.str.startsWith(t));
      });

      final query = mention.str.substring(1); // remove the trigger
      widget.triggerCallbacks[_currentTrigger!]?.call(query);

      showSuggestions.value = true;
      widget.onSuggestionVisibleChanged?.call(true);
    } else {
      setState(() {
        _selectedMention = null;
        _currentTrigger = null;
      });

      showSuggestions.value = false;
      widget.onSuggestionVisibleChanged?.call(false);
    }
  }

  void inputListeners() {
    if (widget.onChanged != null) {
      widget.onChanged!(controller!.text);
    }

    if (widget.onMarkupChanged != null) {
      widget.onMarkupChanged!(controller!.markupText);
    }

    if (widget.onSearchChanged != null && _selectedMention?.str != null) {
      final str = _selectedMention!.str.toLowerCase();
      widget.onSearchChanged!(str[0], str.substring(1));
    }
  }

  @override
  void initState() {
    final data = mapToAnotation();
    controller = EnhancedAnnotationEditingController(data);

    if (widget.defaultText != null) {
      controller!.text = widget.defaultText!;
    }

    controller!.addListener(suggestionListerner);
    controller!.addListener(inputListeners);

    super.initState();
  }

  @override
  void dispose() {
    controller!.removeListener(suggestionListerner);
    controller!.removeListener(inputListeners);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller!.mapping = mapToAnotation();
  }

  @override
  Widget build(BuildContext context) {
    final list =
        _selectedMention != null
            ? widget.mentions.firstWhere(
              (element) => _selectedMention!.str.contains(element.trigger),
              orElse: () => widget.mentions[0],
            )
            : widget.mentions[0];

    return PortalEntry(
      portalAnchor:
          widget.suggestionPosition == SuggestionPosition.Bottom
              ? Alignment.topCenter
              : Alignment.bottomCenter,
      childAnchor:
          widget.suggestionPosition == SuggestionPosition.Bottom
              ? Alignment.bottomCenter
              : Alignment.topCenter,
      portal: ValueListenableBuilder(
        valueListenable: showSuggestions,
        builder: (BuildContext context, bool show, Widget? child) {
          return show && !widget.hideSuggestionList
              ? Container(
                constraints: BoxConstraints(maxHeight: widget.suggestionListHeight),
                child: OptionList(
                  suggestionListHeight: widget.suggestionListHeight,
                  suggestionBuilder: list.suggestionBuilder,
                  suggestionListDecoration: widget.suggestionListDecoration,
                  data:
                      list.data.where((element) {
                        final ele = element['display'].toLowerCase();
                        final str = _selectedMention!.str.toLowerCase().replaceAll(
                          RegExp(_pattern),
                          '',
                        );
                        return ele == str ? false : ele.contains(str);
                      }).toList(),
                  onTap: (value) {
                    addMention(value, list);
                    showSuggestions.value = false;
                  },
                ),
              )
              : const SizedBox.shrink();
        },
      ),
      child: Row(
        children: [
          ...widget.leading,
          Expanded(
            child: TextField(
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              keyboardAppearance: widget.keyboardAppearance,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              style: widget.style,
              textAlign: widget.textAlign,
              textDirection: widget.textDirection,
              readOnly: widget.readOnly,
              showCursor: widget.showCursor,
              autofocus: widget.autofocus,
              autocorrect: widget.autocorrect,
              maxLengthEnforcement: widget.maxLengthEnforcement,
              cursorColor: widget.cursorColor,
              cursorRadius: widget.cursorRadius,
              cursorWidth: widget.cursorWidth,
              buildCounter: widget.buildCounter,
              autofillHints: widget.autofillHints,
              decoration: widget.decoration,
              expands: widget.expands,
              onEditingComplete: widget.onEditingComplete,
              onTap: widget.onTap,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              enableSuggestions: widget.enableSuggestions,
              scrollController: widget.scrollController,
              scrollPadding: widget.scrollPadding,
              scrollPhysics: widget.scrollPhysics,
              controller: controller,
            ),
          ),
          ...widget.trailing,
        ],
      ),
    );
  }
}
