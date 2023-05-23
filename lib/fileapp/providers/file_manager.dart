import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_data_provider.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/providers/matcher.dart';
import 'package:xview/fileapp/service/hive.dart';
import 'package:xview/utils/log.dart';

// we might want to add more meta infos in the future
@immutable
class FileMeta {
  static FileMeta invalid = const FileMeta(path: "");

  final String path;
  const FileMeta({required this.path});
}

@immutable
class FileManager {
  final List<FileMeta> files;
  final int activeIndex;

  const FileManager({required this.files, this.activeIndex = -1});

  FileManager _setActiveIndex(int index) =>
      FileManager(files: files, activeIndex: index);

  bool containsFile(String path) => files.any((f) => f.path == path);

  // the file is automatically added once it was added
  //
  // note that caller must ensure that `path` does not already exists in the list
  FileManager _addFile(
    String path,
  ) {
    final m = FileMeta(
      path: path,
    );
    final files = [...this.files, m];
    return FileManager(
      files: files,
      activeIndex: files.length - 1,
    );
  }

  FileManager? _deleteFile(String path) {
    final index = this.files.indexWhere((f) => f.path == path);
    if (index == -1) {
      // keep current state if path does not alreay exists in the list
      return null;
    }

    // we should make a copy before removing any element
    var files = [...this.files]..removeAt(index);
    assert(activeIndex != -1);

    return FileManager(
        files: files, activeIndex: min(files.length - 1, activeIndex));
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
    final newState = state._deleteFile(file);
    if (newState == null) {
      return;
    }

    state = newState;

    ref.read(fileSettingProvider(file).notifier).deleteLocalSetting();

    // invalidating all family providers, Despite the fact that the provider
    // will be created, it may still be necessary to do this in order to reduce
    // memory pressue
    ref.invalidate(fileSettingProvider(file));
    ref.invalidate(fileDataProvider(file));
    ref.invalidate(allLineProvider(file));
    ref.invalidate(filterLineProvider(file));
    ref.invalidate(hasFilterWordProvider(file));
  }

  Future<List<String>> loadHistoryFiles() async {
    final files = await FileViewBox.allKeys();
    log.info("history files: $files");
    if (files.isEmpty) {
      return [];
    }
    openFiles(files);
    return files;
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
    if (state.containsFile(file)) {
      log.info('active file $file');
      setActiveFile(file);
      return;
    }

    // open a new file
    log.info('openFile "$file"');
    ref.read(fileSettingProvider(file).notifier).loadLocalFileSetting();
    state = state._addFile(file);
  }
}

final fileManager = NotifierProvider<FileManagerNotifier, FileManager>(() {
  log.info('+provider fileManager');
  return FileManagerNotifier();
});
