import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/setting.dart';
import 'package:xview/view/states/line_state.dart';

class Line extends ConsumerWidget {
  final LineState data;

  Line({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Colors.black87;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(right: 16),
            child: Text(
              '${data.lineno}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
              child: Text.rich(
            data.span,
          ))
        ]));
  }
}
