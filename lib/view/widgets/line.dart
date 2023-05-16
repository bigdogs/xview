import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/position.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends ConsumerStatefulWidget {
  final LineState data;
  // the parent widget isn't responding to the click event, and I'm clueless on how to fix it.
  final void Function()? onTap;

  const Line({super.key, required this.data, this.onTap});

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
              final currentIndex = ref.watch(
                  positionProvider.select((value) => value.clickedIndex));
              Color? color;
              if (currentIndex == widget.data.lineno) {
                color = const Color.fromARGB(80, 172, 175, 179);
              }
              return Container(color: color);
            })),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }

                  ref
                      .read(positionProvider.notifier)
                      .clickIndex(widget.data.lineno);
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text.rich(widget.data.span)))
          ]))
        ]));
  }
}
