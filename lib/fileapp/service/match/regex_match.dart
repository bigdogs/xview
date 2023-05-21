import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/service/match/plain_match.dart';

Future<List<LineMatch>> regexMatch(List<String> lines, int lineStart,
    String matchWord, bool caseSensitive, bool matchWholeWord) async {
  //TODO: make regex match works
  return plainMatch(lines, lineStart, matchWord, caseSensitive, matchWholeWord);
}
