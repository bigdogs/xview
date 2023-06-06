import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/models/line_match.dart';
import 'package:xview/fileapp/providers/file_data_provider.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/service/match/nop_match.dart';
import 'package:xview/fileapp/service/match/plain_match.dart';
import 'package:xview/fileapp/service/match/regex_match.dart';
import 'package:xview/utils/log.dart';

class FileMatchNotifer extends StateNotifier<List<LineMatch>> {
  final String fileId;

  FileSetting? currentSetting;
  FileData? currentFileData;

  FileMatchNotifer(super.state, {required this.fileId, this.currentSetting});

  onSettingUpdate(FileSetting? prev, FileSetting next, Ref ref) {
    currentSetting = next;
    if (shouldTriggerMatch(prev, next)) {
      () async {
        ref.read(filterViewEnableProvider(fileId).notifier).state = false;
        await matchAll();
        ref.read(filterViewEnableProvider(fileId).notifier).state = true;
      }();
    }
  }

  onNewFileData(FileData? _, FileData next) {
    assert(next.resovledContent.length >= state.length);
    final len = state.length;
    applyFileMatch(
            currentSetting, next.resovledContent.sublist(len), state.length)
        .then((increment) {
      assert(state.length == len);
      _update(increment, append: true);
    });

    currentFileData = next;
  }

  matchAll() async {
    final lines = await applyFileMatch(
        currentSetting, currentFileData?.resovledContent ?? [], 0);
    _update(lines);
  }

  _update(List<LineMatch> lines, {bool append = false}) {
    if (append) {
      state = [...state, ...lines];
    } else {
      state = lines;
    }
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
    log.fine(
        'match..  "${setting.filterWord}", caseSensitive: ${setting.caseSensitive}, matchWord: ${setting.matchWholeWord}, useRegex: ${setting.useRegex}');

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

  ref.listen(fileSettingProvider(fileId), (prev, next) {
    notifier.onSettingUpdate(prev, next, ref);
  });
  ref.listen(fileDataProvider(fileId), notifier.onNewFileData);

  return notifier;
});

final filterLineProvider =
    Provider.family<List<LineMatch>, String>((ref, fileId) {
  final hasFilterWord = ref.watch(hasFilterWordProvider(fileId));
  final all = ref.watch(allLineProvider(fileId));
  final enable = ref.watch(filterViewEnableProvider(fileId));

  if (!hasFilterWord || !enable) {
    return [];
  }

  return all.where((element) => element.isMatch).toList();
});
