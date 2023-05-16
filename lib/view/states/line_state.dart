import 'package:flutter/material.dart';

class _Line {
  final int lineNumber;
  final String text;
  _Line({required this.lineNumber, required this.text});

  LineState applyFilter(String filter) {
    final s = LineState();
    s._line = this;

    List<TextSpan> spans = [];
    if (filter == "" || !text.contains(filter)) {
      s.match = false;
      spans.add(TextSpan(text: text));
    } else {
      s.match = true;
      TextStyle highlight = TextStyle(backgroundColor: Colors.yellow[200]);
      var pos = 0;
      var index = text.indexOf(filter, pos);
      while (index != -1) {
        // normal
        spans.add(TextSpan(text: text.substring(pos, index)));
        // highlight
        spans.add(TextSpan(
            text: text.substring(index, index + filter.length),
            style: highlight));
        pos = index + filter.length;
        index = text.indexOf(filter, pos);
      }
      if (pos < text.length) {
        spans.add(TextSpan(text: text.substring(pos)));
      }
    }

    s.span = TextSpan(children: spans);
    return s;
  }
}

class LineState {
  late final _Line _line;
  late final TextSpan span;
  late final bool match;

  int get lineno => _line.lineNumber;
  String get text => _line.text;

  static LineState create(int lineNumber, String text, String filter) {
    final line = _Line(lineNumber: lineNumber, text: text);
    return line.applyFilter(filter);
  }

  LineState applyFilter(String filter) {
    return _line.applyFilter(filter);
  }
}

class LinePart {}
