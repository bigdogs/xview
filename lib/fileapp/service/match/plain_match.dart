import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xview/fileapp/models/line_match.dart';

Future<List<LineMatch>> plainMatch(List<String> lines, int lineStart,
    String matchWord, bool caseSensitive, bool matchWholeWord) async {
  return [];
}

//TODO: ...
(TextSpan, bool) plainMatchLine(
    String text, String matchWord, bool caseSensitive, bool matchWholeWord) {
  if (!text.contains(matchWord)) {
    return (TextSpan(text: text), false);
  }

  List<TextSpan> spans = [];
  TextStyle highlight = TextStyle(backgroundColor: Colors.yellow[200]);
  var pos = 0;
  var index = text.indexOf(matchWord, pos);
  while (index != -1) {
    // normal
    spans.add(TextSpan(text: text.substring(pos, index)));
    // highlight
    spans.add(TextSpan(
        text: text.substring(index, index + matchWord.length),
        style: highlight));
    pos = index + matchWord.length;
    index = text.indexOf(matchWord, pos);
  }

  if (pos < text.length) {
    spans.add(TextSpan(text: text.substring(pos)));
  }
  return (TextSpan(children: spans), true);
}
