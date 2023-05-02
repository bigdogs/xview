// TODO: make hightlight works
class LineState {
  final int lineNumber;
  final String rawText;
  // track if current line is match filter word,
  final bool match;
  final List<LinePart>? parts;

  LineState(
      {required this.lineNumber,
      required this.rawText,
      this.match = false,
      this.parts});
}

class LinePart {}
