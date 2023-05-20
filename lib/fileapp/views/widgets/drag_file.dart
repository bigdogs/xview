import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:xview/utils/log.dart';

class DragFile extends StatefulWidget {
  final Widget child;

  final Function(List<String>) onOpenFiles;

  const DragFile({super.key, required this.child, required this.onOpenFiles});

  @override
  State<DragFile> createState() => _DragFileState();
}

class _DragFileState extends State<DragFile> {
  @override
  Widget build(BuildContext context) {
    // if we need to display something on dragging,
    // then we should implement `onDragEnter` and `onDragExit` callback
    return DropTarget(
      onDragDone: (detail) {
        final files = detail.files.map((f) => f.path).toList();
        log.info('Drag done: files: $files');
        widget.onOpenFiles(files);
      },
      child: widget.child,
    );
  }
}
