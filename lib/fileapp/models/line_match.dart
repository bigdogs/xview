import 'package:flutter/material.dart';

@immutable
class LineMatch {
  final int lineNumber;
  final String text;
  final TextSpan span;
  final bool isMatch;

  const LineMatch(
      {required this.lineNumber,
      required this.text,
      required this.span,
      required this.isMatch});
}
