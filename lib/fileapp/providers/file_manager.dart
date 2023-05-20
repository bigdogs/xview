import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/service/file.dart';
import 'package:xview/fileapp/service/hive.dart';
import 'package:xview/utils/log.dart';

@immutable
class FileMeta {
  final String path;
  final Stream<List<String>> stream;
  const FileMeta({required this.path, required this.stream});
}

@immutable
class FileManager {
  final List<FileMeta> files;
  final String? error;
  final int activeIndex;

  const FileManager({required this.files, this.error, this.activeIndex = -1});

  FileManager _clearError() =>
      FileManager(files: files, error: null, activeIndex: activeIndex);

  FileManager _setError(String e) =>
      FileManager(files: files, error: e, activeIndex: activeIndex);

  FileManager _setActiveIndex(int index) =>
      FileManager(files: files, error: error, activeIndex: index);

  bool containsFile(String path) => files.any((f) => f.path == path);

  // the file is automatically added once it was added
  //
  // note that caller must ensure that `path` does not already exists in the list
  FileManager _addFile(String path, Stream<List<String>> stream) {
    final m = FileMeta(path: path, stream: stream);
    return FileManager(
        files: [...files, m], activeIndex: files.length - 1, error: error);
  }

  FileManager _deleteFile(String path) {
    final index = this.files.indexWhere((f) => f.path == path);
    if (index == -1) {
      // keep current state if path does not alreay exists in the list
      return this;
    }

    // we should make a copy before removing any element
    var files = [...this.files]..removeAt(index);
    assert(activeIndex != -1);

    return FileManager(
        files: files,
        activeIndex: min(files.length - 1, activeIndex),
        error: error);
  }
}

class FileManagerNotifier extends Notifier<FileManager> {
  @override
  FileManager build() {
    return const FileManager(files: []);
  }

  setActiveIndex(int index) {
    assert(index < state.files.length);
    state = state._setActiveIndex(index);
  }

  setActiveFile(String path) {
    int index = state.files.indexWhere((element) => element.path == path);
    if (index != -1) {
      state = state._setActiveIndex(index);
    }
  }

  closeFile(String file) async {
    state = state._deleteFile(file);
  }

  loadHistoryFiles() async {
    final files = await FileViewBox.allKeys();
    log.info("history files: $files");
    if (files.isEmpty) {
      return;
    }
    await openFiles(files);
  }

  openFiles(List<String> files) async {
    log.info('openFiles: $files');

    for (final file in files) {
      try {
        await openFile(file);
      } catch (e) {
        log.severe('open file $file failed: $e');
      }
    }
  }

  openFile(String file) async {
    log.info('openFile "$file"');
    if (state.containsFile(file)) {
      setActiveFile(file);
      return;
    }
    // open a new file
    final fileStream = readFileAsStream(file);
    state = state._addFile(file, fileStream);
  }

  resetError() {
    state = state._clearError();
  }

  _onError(String e) {
    state = state._setError(e);
  }
}

final fileManager = NotifierProvider<FileManagerNotifier, FileManager>(
    () => FileManagerNotifier());
