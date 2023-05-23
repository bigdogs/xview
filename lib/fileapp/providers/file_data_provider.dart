import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/service/file.dart';
import 'package:xview/utils/log.dart';

// we might want to add `error` handling
@immutable
class FileData {
  final String path;
  final List<String> resovledContent;
  final Stream<List<String>>? fileStream;

  const FileData(
      {required this.path,
      required this.resovledContent,
      required this.fileStream});

  static FileData invalid() {
    return const FileData(path: "", resovledContent: [], fileStream: null);
  }

  FileData finish() {
    return FileData(
        path: path, resovledContent: resovledContent, fileStream: null);
  }

  FileData onNewData(List<String> data) {
    return FileData(
        path: path,
        resovledContent: [...resovledContent, ...data],
        fileStream: fileStream);
  }
}

class FileDataNotifier extends StateNotifier<FileData> {
  FileDataNotifier(super._state) {
    _listenFileStream();
  }

  // this method must be called only once
  _listenFileStream() {
    state.fileStream?.listen((chunk) {
      state = state.onNewData(chunk);
    }, onDone: () {
      state = state.finish();
    }, onError: (e) {
      log.severe('${state.path} load error: e');
    });
  }
}

final fileDataProvider =
    StateNotifierProvider.family<FileDataNotifier, FileData, String>(
        (ref, fileId) {
  FileData fileData = FileData.invalid();
  try {
    FileMeta fileMeta = ref.watch(fileManager.select((value) => value.files
        .firstWhere((element) => element.path == fileId,
            orElse: () => FileMeta.invalid)));

    if (fileMeta != FileMeta.invalid) {
      final s = readFileAsStream(fileMeta.path);
      fileData = FileData(
          path: fileMeta.path, resovledContent: const [], fileStream: s);
    }
  } catch (e) {
    // handle error
    log.severe('fileDataProvider error: $e');
  }

  log.info(
      '[$fileId] +provider fileDataProvider@${fileData == FileData.invalid() ? -1 : identityHashCode(fileData)}');
  return FileDataNotifier(fileData);
});
