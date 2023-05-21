import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xview/fileapp/models/line_match.dart';

List<LineMatch> nopMatch(List<String> lines, int lineStart) {
  return lines
      .mapIndexed((idx, e) => LineMatch(
          lineNumber: idx + lineStart,
          text: e,
          span: TextSpan(text: e),
          isMatch: false))
      .toList();
}
