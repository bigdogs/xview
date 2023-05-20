import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/filedata.dart';
import 'package:xview/provider/position.dart';
import 'package:xview/utils/icons.dart';
import 'package:xview/view/widgets/line.dart';
import 'package:xview/view/widgets/textlist.dart';

class FilterPage extends ConsumerWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(fileDataProvider);
    return ColoredBox(
        color: const Color.fromARGB(100, 230, 224, 223),
        child: Column(
          children: [
            const FilterLine(),
            Expanded(
                child: SelectionArea(
                    child: TextList.builder(
              itemTextCount: (index) =>
                  content.filterLineAtIndex(index).text.length,
              itemCount: content.filterLength(),
              itemBuilder: (c, index) {
                final data = content.filterLineAtIndex(index);
                return Line(
                  data: data,
                  onTap: () {
                    ref.read(positionProvider.notifier).jumpTo(data.lineno);
                  },
                );
              },
            )))
          ],
        ));
  }
}

class FilterLine extends ConsumerStatefulWidget {
  const FilterLine({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FilterLineState();
  }
}

class _FilterLineState extends ConsumerState<FilterLine> {
  String _filter = "";
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: SizedBox(
            height: 28,
            child: Row(
              children: [
                _SettingIcon(
                  data: XIcons.case_sensitive,
                  toolTips: "Match Case",
                ),
                _SettingIcon(
                    data: XIcons.regex, toolTips: "Use Regular Expression"),
                _SettingIcon(
                    data: XIcons.whole_word, toolTips: "Match Whole Word"),
                Expanded(
                    child: TextField(
                  maxLines: 1,
                  focusNode: focusNode,
                  onChanged: (c) {
                    _filter = c;
                  },
                  onEditingComplete: () {
                    ref.read(fileDataProvider.notifier).setFilter(_filter);
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
            )));
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
              XIcons.close_circle,
              color: Color.fromARGB(255, 124, 124, 124),
              size: 20,
            ))
      ],
    );
  }
}

class _SettingIcon extends StatefulWidget {
  final IconData data;
  final bool firstSelected;
  final String toolTips;

  const _SettingIcon(
      {required this.data, required this.toolTips, this.firstSelected = false});

  @override
  State<StatefulWidget> createState() => _SettingIconState();
}

class _SettingIconState extends State<_SettingIcon> {
  final BoxDecoration _shadow = BoxDecoration(
    borderRadius: BorderRadius.circular(2),
    color: const Color.fromARGB(180, 216, 211, 210),
  );

  late bool selected;
  BoxDecoration? _hoverDecoration;

  _SettingIconState();

  @override
  void initState() {
    selected = widget.firstSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            selected = !selected;
          });
        },
        child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: _hoverDecoration,
            child: MouseRegion(
                onEnter: (e) {
                  setState(() {
                    _hoverDecoration = _shadow;
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
