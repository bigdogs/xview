import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/utils/log.dart';
import 'package:xview/view/states/line_state.dart';
import 'dart:io';

class Content {
  /// raw content of file, it will not modified after it was loaded,
  /// but highlight strategy can be modified.
  ///
  /// (for now, all file contents are loaded in memory, so big file may crash program!)
  final List<LineState> content;
  final List<LineState> filterContent;
  final String filterWord;

  Content(
      {required this.content,
      this.filterWord = "",
      required this.filterContent});

  Content copy({
    List<LineState>? content,
    List<LineState>? filterContent,
    String? filterWord,
  }) {
    return Content(
        content: content ?? this.content,
        filterContent: filterContent ?? this.filterContent,
        filterWord: filterWord ?? this.filterWord);
  }

  LineState lineAtIndex(int index) {
    return content[index];
  }

  int length() {
    return content.length;
  }

  // filtered content
  LineState filterLineAtIndex(int index) {
    return filterContent[index];
  }

  int filterLength() {
    return filterContent.length;
  }
}

class ContentProvider extends Notifier<Content> {
  @override
  Content build() {
    state = Content(content: [], filterContent: []);
    return state;
  }

  Future<void> loadFile(String path) async {
    log.info('load file: $path');
    try {
      Content content = await compute(_loadFile, path);
      state = content;
    } catch (e) {
      log.severe("load file $path error: $e");
    }
  }

  // do this in isolate thread
  //
  // we access `state` in main thread & this isolate thread, is that ok?
  Future<Content> _loadFile(String path) async {
    // load file content into memory
    List<String> lines = await File(path).readAsLines();
    String filter = "";
    List<LineState> content = [];
    List<LineState> filterContent = [];

    try {
      // state may not init..
      filter = state.filterWord;
    } catch (_) {}

    for (int i = 0; i < lines.length; i += 1) {
      final line = lines[i];
      final lineState = LineState.create(i, line, filter);
      content.add(lineState);
      if (lineState.match) {
        filterContent.add(lineState);
      }
    }

    return Future.value(Content(
        content: content, filterContent: filterContent, filterWord: filter));
  }

  void setFilter(String filter) async {
    log.info("set filter: $filter");
    if (filter == state.filterWord) {
      return;
    }
    final content = state.content;
    List<LineState> newContent = [];
    List<LineState> newFilterContent = [];
    for (final line in content) {
      final r = line.applyFilter(filter);
      newContent.add(r);
      if (r.match) {
        newFilterContent.add(r);
      }
    }
    state = state.copy(
        content: newContent,
        filterContent: newFilterContent,
        filterWord: filter);
  }
}

final contentProvider = NotifierProvider<ContentProvider, Content>(() {
  final p = ContentProvider();
  // TODO: remove fake files
  // p.loadFile(r"C:\Users\xyanj\Downloads\vmware.log");
  p.loadFile("/tmp/a.log");
  return p;
});
