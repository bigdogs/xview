import 'package:flutter/material.dart';

class DragableDivider extends StatelessWidget {
  final void Function(DragUpdateDetails details) onDrag;

  const DragableDivider({super.key, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: onDrag,
          child: const Divider(height: 4)),
    );
  }
}
