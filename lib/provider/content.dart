import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/view/states/line_state.dart';

class Content {
  /// raw content of file, it will not modified after it was loaded,
  /// but highlight strategy can be modified.
  ///
  /// (for now, all file contents are loaded in memory, so big file may crash program!)
  final List<String> content;
  final String filterWord;
  final Map<int, LineState>? filters = null;

  Content({required this.content, this.filterWord = ""});

  Content copy({
    List<String>? content,
    String? filterWord,
  }) {
    return Content(
        content: content ?? this.content,
        filterWord: filterWord ?? this.filterWord);
  }

  // content of whole file
  LineState lineAtIndex(int index) {
    // could query background service...
    return LineState(rawText: "hello, world", lineNumber: 1);
  }

  int length() {
    return 10;
  }

  // filtered content
  LineState filterLineAtIndex(int index) {
    return LineState(rawText: "hello, world", lineNumber: 1);
  }

  int filterLength() {
    return 10;
  }
}

class ContentProvider extends Notifier<Content> {
  @override
  Content build() {
    state = Content(content: []);
    return state;
  }

  Future<void> loadFile(String path) async {}

  void setFilter(String filter) {}
}

final contentProvider =
    NotifierProvider<ContentProvider, Content>(() => ContentProvider());
