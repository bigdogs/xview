import 'package:flutter/material.dart';

class DragableDivider extends StatelessWidget {
  final Color color;
  final void Function(DragUpdateDetails details) onDrag;

  const DragableDivider({super.key, required this.onDrag, required this.color});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onDrag,
          child: Divider(
            thickness: 6,
            height: 6,
            color: color,
          )),
    );
  }
}
