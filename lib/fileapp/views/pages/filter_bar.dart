import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
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
  String _filter = "";
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

  @override
  Widget build(BuildContext context) {
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
            Expanded(
                child: TextField(
              cursorWidth: 1.1,
              controller: _controller,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              focusNode: focusNode,
              onChanged: (c) {
                _filter = c;
              },
              onEditingComplete: () {
                ref
                    .read(fileSettingProvider(FileView.id(context)).notifier)
                    .updateSetting((p0) => p0.copy(filterWord: _filter));
                focusNode.requestFocus();
              },
              decoration: InputDecoration(
                  filled: true,
                  hoverColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(Icons.search, size: 16),
                  suffix: _MatchCount(),
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
}

class _MatchCount extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MatchCountState();
  }
}

class _MatchCountState extends ConsumerState<_MatchCount> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '0 matches',
          style: TextStyle(fontSize: 11),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              CustomIcon.close_circle,
              color: Color.fromARGB(255, 124, 124, 124),
              size: 20,
            ))
      ],
    );
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
