import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/setting.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends ConsumerStatefulWidget {
  final LineState data;

  const Line({super.key, required this.data});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _LineState();
  }
}

class _LineState extends ConsumerState<Line> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SelectionContainer.disabled(
              child: Container(
            width: 48,
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(right: 16),
            child: Text(
              '${widget.data.lineno}',
              style: const TextStyle(color: Colors.grey),
            ),
          )),
          Expanded(
              child: Stack(children: [
            Positioned.fill(child: Builder(builder: (_) {
              final currentIndex = ref
                  .watch(settingProvider.select((value) => value.currentInex));
              Color? color;
              if (currentIndex == widget.data.lineno) {
                color = const Color.fromARGB(80, 172, 175, 179);
              }
              return Container(color: color);
            })),
            GestureDetector(
                onTap: () {
                  ref
                      .read(settingProvider.notifier)
                      .setCurrentIndex(widget.data.lineno);
                },
                child: Text.rich(widget.data.span))
          ]))
        ]));
  }
}
