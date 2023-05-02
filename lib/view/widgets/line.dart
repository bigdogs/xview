import 'package:flutter/material.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends StatelessWidget {
  final LineState data;

  Line({required this.data});

  @override
  Widget build(BuildContext context) {
    return Text('${data.lineNumber}: ${data.rawText}');
  }
}
