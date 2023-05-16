import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xview/utils/log.dart';
import 'package:xview/view/states/line_state.dart';
import 'dart:io';

class FileData {
  /// raw content of file, it will not modified after it was loaded,
  /// but highlight strategy can be modified.
  ///
  /// * we are load all file data into memory, be careful of memory issue
  /// * for now are support only one file, multiple files/tabs will be supported in the future
  final String path;
  final List<LineState> content;
  final List<LineState> filterContent;
  final String filterWord;

  FileData(
      {required this.path,
      required this.content,
      this.filterWord = "",
      required this.filterContent});

  FileData copy({
    List<LineState>? content,
    List<LineState>? filterContent,
    String? filterWord,
  }) {
    return FileData(
        // seems like we don't need to change file path
        path: path,
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

class _LoadMsg {
  final String path;
  final String filterWord;
  _LoadMsg({required this.path, required this.filterWord});
}

class FileDataProvider extends Notifier<FileData> {
  @override
  FileData build() {
    state = FileData(content: [], filterContent: [], path: "");
    return state;
  }

  // we are currently support only one file,
  //
  // multifiles will be supported on tab feature finish
  void openFiles(List<String> files) {
    if (files.isEmpty) {
      log.info("no file to open");
      return;
    }
    if (files.length > 1) {
      log.warning("open multifiles, only the first file is loaded");
    }
    loadNewFile(files[0]);
  }

  // Typically, when we load a new file, we would scroll the index to 0.
  // However, since we plan to support multiple files in the future, this solution
  // is merely a stopgap measure. therefore, for the time being, we'll overlook it
  Future<void> loadNewFile(String path, {bool savePath = true}) async {
    log.info('load file: $path');
    try {
      if (path == state.path) {
        log.info("ignore the same path");
        return;
      }

      // Is that necessary to load file in isolate thread?
      //
      // FileData content =  await compute(_loadFile, _LoadMsg(path: path, filterWord: ""));

      FileData content = await _loadFile(_LoadMsg(path: path, filterWord: ""));

      state = content;
      saveLastOpenPath(path);
    } catch (e) {
      log.severe("load file $path error: $e");
    }
  }

  // do this in isolate thread
  //
  static Future<FileData> _loadFile(_LoadMsg msg) async {
    // load file content into memory
    List<String> lines = await File(msg.path).readAsLines();
    String filter = msg.filterWord;
    List<LineState> content = [];
    List<LineState> filterContent = [];

    for (int i = 0; i < lines.length; i += 1) {
      final line = lines[i];
      final lineState = LineState.create(i, line, filter);
      content.add(lineState);
      if (lineState.match) {
        filterContent.add(lineState);
      }
    }

    return Future.value(FileData(
        content: content,
        filterContent: filterContent,
        filterWord: filter,
        path: msg.path));
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

  void saveLastOpenPath(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenPath', path);
  }

  void _loadLastOpenPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('lastOpenPath');
    if (path != null) {
      loadNewFile(path, savePath: false);
    }
  }
}

final fileDataProvider = NotifierProvider<FileDataProvider, FileData>(() {
  final p = FileDataProvider();
  p._loadLastOpenPath();
  return p;
});
