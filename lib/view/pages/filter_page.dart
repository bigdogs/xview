import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/filedata.dart';
import 'package:xview/utils/icons.dart';
import 'package:xview/view/widgets/line.dart';
import 'package:xview/view/widgets/listview.dart';

class FilterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(fileDataProvider);
    return ColoredBox(
        color: const Color.fromARGB(100, 230, 224, 223),
        child: Column(
          children: [
            FilterLine(),
            Expanded(
                child: SelectionArea(
                    child: ListViewExt.builder(
              itemCount: content.filterLength(),
              itemBuilder: (c, index) {
                return Line(data: content.filterLineAtIndex(index));
              },
            )))
          ],
        ));
  }
}

class FilterLine extends ConsumerStatefulWidget {
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
                _SettingIcon(data: XIcons.case_sensitive),
                _SettingIcon(data: XIcons.regex),
                _SettingIcon(data: XIcons.whole_word),
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

class _SettingIcon extends StatefulWidget {
  final IconData data;
  final bool firstSelected;

  const _SettingIcon({required this.data, this.firstSelected = false});

  @override
  State<StatefulWidget> createState() => _SettingIconState();
}

class _SettingIconState extends State<_SettingIcon> {
  late bool selected;

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
        child: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  widget.data,
                  size: 18,
                  color: selected
                      ? const Color.fromARGB(255, 27, 118, 224)
                      : const Color.fromARGB(255, 103, 97, 96),
                ))));
  }
}
