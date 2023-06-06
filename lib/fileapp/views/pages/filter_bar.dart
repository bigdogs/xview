import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/providers/matcher.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/utils/consts.dart';

class FilterBar extends ConsumerStatefulWidget {
  const FilterBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FilterBarState();
  }
}

class _FilterBarState extends ConsumerState<FilterBar> {
  final FocusNode focusNode = FocusNode();
  late final TextEditingController _controller;

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() {});
    });

    _filter = ref.read(fileSettingProvider(FileView.id(context))).filterWord;
    _controller = TextEditingController(text: _filter);
    focusNode.requestFocus();
    super.initState();
  }

  String _filter = "";
  set filter(String value) {
    if ((value.isEmpty && _filter.isNotEmpty) ||
        (value.isNotEmpty && _filter.isEmpty)) {
      setState(() {});
    }
    _filter = value;
  }

  bool _showMatchNumber = false;
  set showMatchNumber(bool value) {
    if ((value && !_showMatchNumber) || (!value && _showMatchNumber)) {
      setState(() {});
    }
    _showMatchNumber = value;
  }

  @override
  Widget build(BuildContext context) {
    int matchNumber = 0;
    if (_showMatchNumber) {
      matchNumber = ref.watch(filterLineProvider(FileView.id(context))
          .select((value) => value.length));
    }

    return Container(
        color: CustomColor.filterBackground,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        height: 32,
        child: Row(
          children: [
            _SettingIcon(
              data: CustomIcon.case_sensitive,
              toolTips: "Match Case",
              selection: (p0) => p0.caseSensitive,
              updater: (p0) => p0.copy(caseSensitive: !p0.caseSensitive),
            ),
            _SettingIcon(
              data: CustomIcon.regex,
              toolTips: "Use Regular Expression",
              selection: (p0) => p0.useRegex,
              updater: (p0) => p0.copy(useRegex: !p0.useRegex),
            ),
            _SettingIcon(
              data: CustomIcon.whole_word,
              toolTips: "Match Whole Word",
              selection: (p0) => p0.matchWholeWord,
              updater: (p0) => p0.copy(matchWholeWord: !p0.matchWholeWord),
            ),
            const SizedBox(width: 4),
            Expanded(
                child: TextField(
              cursorWidth: 1.1,
              controller: _controller,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              focusNode: focusNode,
              onChanged: _onChange,
              onEditingComplete: _onEditingComplete,
              decoration: InputDecoration(
                  filled: true,
                  hoverColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.search, size: 16),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showMatchNumber)
                        Text(
                          '$matchNumber matches',
                          style: const TextStyle(fontSize: 11),
                        ),
                      if (_filter.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                                onTap: _onClearContent,
                                child: const Icon(
                                  CustomIcon.close_circle,
                                  color: Color.fromARGB(255, 124, 124, 124),
                                  size: 20,
                                )))
                    ],
                  ),
                  fillColor: (focusNode.hasFocus || _filter.isNotEmpty)
                      ? Colors.white
                      : const Color.fromARGB(255, 215, 210, 209),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(8)))),
            ))
          ],
        ));
  }

  _onClearContent() {
    _controller.clear();
    filter = "";
    showMatchNumber = false;
    focusNode.requestFocus();
  }

  _onChange(c) {
    filter = c;
    showMatchNumber = false;
  }

  _onEditingComplete() {
    _saveFilterWord();
    focusNode.requestFocus();
    if (_filter.isNotEmpty) {
      showMatchNumber = true;
    }
  }

  _saveFilterWord() {
    ref
        .read(fileSettingProvider(FileView.id(context)).notifier)
        .updateSetting((p0) => p0.copy(filterWord: _filter));
  }
}

class _SettingIcon extends ConsumerStatefulWidget {
  final IconData data;

  final String toolTips;
  final bool Function(FileSetting) selection;
  final FileSetting Function(FileSetting) updater;

  const _SettingIcon(
      {required this.data,
      required this.toolTips,
      required this.selection,
      required this.updater});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingIconState();
}

class _SettingIconState extends ConsumerState<_SettingIcon> {
  final BoxDecoration _kShadowDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(2),
    color: const Color.fromARGB(180, 216, 211, 210),
  );

  BoxDecoration? _hoverDecoration;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(
        fileSettingProvider(FileView.id(context)).select(widget.selection));
    return GestureDetector(
        onTap: () {
          ref
              .read(fileSettingProvider(FileView.id(context)).notifier)
              .updateSetting(widget.updater);
        },
        child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: _hoverDecoration,
            child: MouseRegion(
                onEnter: (e) {
                  setState(() {
                    _hoverDecoration = _kShadowDecoration;
                  });
                },
                onExit: (e) {
                  setState(() {
                    _hoverDecoration = null;
                  });
                },
                child: Tooltip(
                    waitDuration: const Duration(milliseconds: 950),
                    message: widget.toolTips,
                    child: Icon(
                      widget.data,
                      size: 18,
                      color: selected
                          ? const Color.fromARGB(255, 27, 118, 224)
                          : const Color.fromARGB(255, 103, 97, 96),
                    )))));
  }
}
