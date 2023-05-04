import 'package:flutter/material.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends StatelessWidget {
  final LineState data;

  Line({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Text.rich(data.span));
  }
}
