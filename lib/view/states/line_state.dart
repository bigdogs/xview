class LineState {
  final int lineNumber;
  final String rawText;
  // TODO: make hightlight works
  final List<LinePart>? parts;

  LineState({required this.lineNumber, required this.rawText, this.parts});
}

class LinePart {}
