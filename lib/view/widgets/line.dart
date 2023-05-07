import 'package:flutter/material.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends StatelessWidget {
  final LineState data;

  Line({required this.data});

  @override
  Widget build(BuildContext context) {
    Colors.black87;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        child: Text.rich(data.span, style: TextStyle(fontWeight: FontWeight.w400, color: Color.fromARGB(188, 0, 0, 0)),));
  }
}
