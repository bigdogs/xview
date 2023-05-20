import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/utils/log.dart';

@immutable
class FileData {
  final bool loading;
  final String path;
  final List<String> resovledContent;

  const FileData(
      {required this.path,
      required this.resovledContent,
      required this.loading});

  FileData copy({bool? loading, String? path, List<String>? resovledContent}) {
    return FileData(
        path: path ?? this.path,
        resovledContent: resovledContent ?? this.resovledContent,
        loading: loading ?? this.loading);
  }
}

class FileDataNotifier extends StateNotifier<FileData> {
  final Stream<List<String>> fileStream;

  FileDataNotifier(super._state, {required this.fileStream}) {
    _listenFileStream();
  }

  // this method must be called only once
  _listenFileStream() {
    fileStream.listen((chunk) {
      state = state.copy(resovledContent: [...state.resovledContent, ...chunk]);
    }, onDone: () {
      log.info('${state.path} is fully loaded');
      state = state.copy(loading: false);
    }, onError: (e) {
      log.severe('${state.path} load error: e');
    });
  }
}

final fileDataProvider = StateNotifierProvider.autoDispose
    .family<FileDataNotifier, FileData, String>((ref, fileId) {
  final manager = ref.watch(fileManager);
  // exception will be throwed here if `fileId` is not found
  final fileMeta =
      manager.files.firstWhere((element) => element.path == fileId);
  return FileDataNotifier(
      FileData(path: fileId, resovledContent: const [], loading: true),
      fileStream: fileMeta.stream);
});
