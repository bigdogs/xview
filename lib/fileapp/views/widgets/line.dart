import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';

class Line extends ConsumerStatefulWidget {
  final LineMatch data;
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
              '${widget.data.lineNumber}',
              style: const TextStyle(color: Colors.grey),
            ),
          )),
          Expanded(
              child: Stack(children: [
            Positioned.fill(child: RepaintBoundary(child: Builder(builder: (_) {
              final highlignt = ref.watch(
                  fileSettingProvider(FileView.id(context)).select(
                      (value) => value.shadowIndex == widget.data.lineNumber));
              Color? color;
              if (highlignt) {
                color = const Color.fromARGB(80, 172, 175, 179);
              }
              return Container(color: color);
            }))),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }

                  ref
                      .read(fileSettingProvider(FileView.id(context)).notifier)
                      .updateSetting(
                          (p0) => p0.copy(shadowIndex: widget.data.lineNumber));
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text.rich(widget.data.span)))
          ]))
        ]));
  }
}
