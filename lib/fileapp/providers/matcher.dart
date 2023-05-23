import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/providers/file_data_provider.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/service/match/nop_match.dart';
import 'package:xview/fileapp/service/match/plain_match.dart';
import 'package:xview/fileapp/service/match/regex_match.dart';

class FileMatchNotifer extends StateNotifier<List<LineMatch>> {
  final String fileId;

  FileSetting? currentSetting;
  FileData? currentFileData;

  FileMatchNotifer(super.state, {required this.fileId, this.currentSetting});

  onSettingUpdate(FileSetting? prev, FileSetting next) {
    currentSetting = next;
    if (shouldTriggerMatch(prev, next)) {
      matchAll();
    }
  }

  onNewFileData(FileData? _, FileData next) {
    assert(next.resovledContent.length >= state.length);
    final len = state.length;
    applyFileMatch(
            currentSetting, next.resovledContent.sublist(len), state.length)
        .then((increment) {
      assert(state.length == len);
      state = [...state, ...increment];
    });

    currentFileData = next;
  }

  matchAll() async {
    state = await applyFileMatch(
        currentSetting, currentFileData?.resovledContent ?? [], 0);
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

final hasFilterWordProvider = Provider.family<bool, String>((ref, fileId) {
  final filterWord = ref
      .watch(fileSettingProvider(fileId).select((value) => value.filterWord));
  return filterWord != "";
});

final allLineProvider =
    StateNotifierProvider.family<FileMatchNotifer, List<LineMatch>, String>(
        (ref, fileId) {
  final notifier = FileMatchNotifer([],
      fileId: fileId, currentSetting: ref.read(fileSettingProvider(fileId)));

  ref.listen(fileSettingProvider(fileId), notifier.onSettingUpdate);
  ref.listen(fileDataProvider(fileId), notifier.onNewFileData);

  return notifier;
});

final filterLineProvider =
    Provider.family<List<LineMatch>, String>((ref, fileId) {
  final hasFilterWord = ref.watch(hasFilterWordProvider(fileId));
  final all = ref.watch(allLineProvider(fileId));

  if (!hasFilterWord) {
    return [];
  }

  return all.where((element) => element.isMatch).toList();
});
