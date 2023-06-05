import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/utils/consts.dart';

Future<List<LineMatch>> regexMatch(List<String> lines, int lineStart,
    String word, bool caseSensitive, bool matchWholeWord) async {
  String pattern = word;
  if (matchWholeWord) {
    pattern = r'\b' + word + r'\b';
  }
  RegExp regExp = RegExp(pattern, caseSensitive: caseSensitive);

  return lines.mapIndexed((idx, text) {
    final (span, isMatch) = regexMatchLine(text, regExp);
    return LineMatch(
        lineNumber: idx + lineStart, text: text, span: span, isMatch: isMatch);
  }).toList();
}

(TextSpan, bool) regexMatchLine(String text, RegExp regExp) {
  List<Match> matches = regExp.allMatches(text).toList();
  if (matches.isEmpty) {
    return (TextSpan(text: text), false);
  }

  matches.sort((a, b) => a.start.compareTo(b.start));
  List<TextSpan> spans = [];
  int lastIndex = 0;
  for (Match match in matches) {
    final nonMatched = TextSpan(text: text.substring(lastIndex, match.start));
    final matched =
        TextSpan(text: match.group(0)!, style: CustomColor.textHighlightStyle);
    spans.add(nonMatched);
    spans.add(matched);
    lastIndex = match.end;
  }
  if (lastIndex < text.length) {
    String nonMatchedText = text.substring(lastIndex);
    spans.add(TextSpan(text: nonMatchedText));
  }
  return (TextSpan(children: spans), true);
}
