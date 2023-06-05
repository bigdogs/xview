import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/service/match/regex_match.dart';
import 'package:xview/utils/consts.dart';

Future<List<LineMatch>> plainMatch(List<String> lines, int lineStart,
    String word, bool caseSensitive, bool matchWholeWord) async {
  if (!caseSensitive && !matchWholeWord) {
    return lines.mapIndexed((idx, text) {
      final (span, isMatch) = plainMatchLine(text, word);
      return LineMatch(
          lineNumber: idx + lineStart,
          text: text,
          span: span,
          isMatch: isMatch);
    }).toList();
  }

  String pattern = RegExp.escape(word);
  if (matchWholeWord) {
    pattern = '\\b$pattern\\b';
  }
  RegExp regExp = RegExp(pattern, caseSensitive: caseSensitive);

  return lines.mapIndexed((idx, text) {
    final (span, isMatch) = regexMatchLine(text, regExp);
    return LineMatch(
        lineNumber: idx + lineStart, text: text, span: span, isMatch: isMatch);
  }).toList();
}

(TextSpan, bool) plainMatchLine(
  String text,
  String word,
) {
  List<TextSpan> spans = [];
  var pos = 0;
  var index = text.indexOf(word, pos);
  while (index != -1) {
    // normal
    spans.add(TextSpan(text: text.substring(pos, index)));
    // highlight
    spans.add(TextSpan(
        text: text.substring(index, index + word.length),
        style: CustomColor.textHighlightStyle));
    pos = index + word.length;
    index = text.indexOf(word, pos);
  }

  if (pos < text.length) {
    spans.add(TextSpan(text: text.substring(pos)));
  }
  return (TextSpan(children: spans), pos != 0);
}
