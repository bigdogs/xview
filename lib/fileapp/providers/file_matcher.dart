import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/providers/file_data_provider.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/service/match/nop_match.dart';
import 'package:xview/fileapp/service/match/plain_match.dart';
import 'package:xview/fileapp/service/match/regex_match.dart';

class FileMatchNotifer extends StateNotifier<List<LineMatch>> {
  final Ref ref;
  final String fileId;

  FileSetting? currentSetting;

  FileMatchNotifer(super.state, {required this.ref, required this.fileId});

  onSettingUpdate(FileSetting? prev, FileSetting next) {
    currentSetting = next;

    if (shouldTriggerMatch(prev, next)) {
      applyFileMatch(currentSetting, state.map((e) => e.text).toList(), 0)
          .then((value) => state = value);
    }
  }

  onNewFileData(FileData? _, FileData next) {
    assert(next.resovledContent.length >= state.length);

    applyFileMatch(currentSetting, next.resovledContent, state.length)
        .then((matched) => state = [...state, ...matched]);
  }

  static bool shouldTriggerMatch(FileSetting? prev, FileSetting next) {
    if (prev == null) {
      return true;
    }

    if (prev.filterWord == "" && next.filterWord == "") {
      return false;
    }

    return prev.filterWord != next.filterWord ||
        prev.caseSensitive != next.caseSensitive ||
        prev.matchWholeWord != next.matchWholeWord ||
        prev.useRegex != next.useRegex;
  }

  static Future<List<LineMatch>> applyFileMatch(
      FileSetting? setting, List<String> lines, int lineStart) async {
    if (setting == null || setting.filterWord == "") {
      return nopMatch(lines, lineStart);
    }

    if (setting.useRegex) {
      return await regexMatch(lines, lineStart, setting.filterWord,
          setting.caseSensitive, setting.matchWholeWord);
    }

    return await plainMatch(lines, lineStart, setting.filterWord,
        setting.caseSensitive, setting.matchWholeWord);
  }
}

final _hasFilterWordProvider =
    Provider.autoDispose.family<bool, String>((ref, fileId) {
  final filterWord = ref
      .watch(fileSettingProvider(fileId).select((value) => value.filterWord));
  return filterWord != "";
});

final allFileMatchProvider = StateNotifierProvider.autoDispose
    .family<FileMatchNotifer, List<LineMatch>, String>((ref, fileId) {
  final notifier = FileMatchNotifer([], ref: ref, fileId: fileId);

  ref.listen(fileSettingProvider(fileId), notifier.onSettingUpdate);
  ref.listen(fileDataProvider(fileId), notifier.onNewFileData);

  return notifier;
});

final filterFileMatchProvider =
    Provider.autoDispose.family<List<LineMatch>, String>((ref, fileId) {
  final hasFilterWord = ref.watch(_hasFilterWordProvider(fileId));
  final all = ref.watch(allFileMatchProvider(fileId));

  if (!hasFilterWord) {
    return [];
  }

  return all.where((element) => element.isMatch).toList();
});
