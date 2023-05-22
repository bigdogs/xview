import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/service/hive.dart';

@immutable
class FileSetting {
  final double percentOfFilterView;
  final bool caseSensitive;
  final bool matchWholeWord;
  final bool useRegex;
  final String filterWord;

  const FileSetting(
      {this.percentOfFilterView = 0.2,
      this.caseSensitive = true,
      this.matchWholeWord = false,
      this.useRegex = false,
      this.filterWord = ''});

  FileSetting copy(
      {double? percentOfFilterView,
      bool? caseSensitive,
      bool? matchWholeWord,
      bool? useRegex,
      String? filterWord}) {
    return FileSetting(
      percentOfFilterView: percentOfFilterView ?? this.percentOfFilterView,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      matchWholeWord: matchWholeWord ?? this.matchWholeWord,
      useRegex: useRegex ?? this.useRegex,
      filterWord: filterWord ?? this.filterWord,
    );
  }

  Map toMap() {
    return {
      'percentOfFilterView': percentOfFilterView,
      'caseSensitive': caseSensitive,
      'matchWholeWord': matchWholeWord,
      'useRegex': useRegex,
      'filterWord': filterWord
    };
  }

  static FileSetting fromMap(Map m) {
    return const FileSetting().copy(
        percentOfFilterView: m['percentOfFilterView'],
        caseSensitive: m['caseSensitive'],
        matchWholeWord: m['matchWholeWord'],
        useRegex: m['useRegex'],
        filterWord: m['filterWord']);
  }
}

class FileSettingNotifier extends StateNotifier<FileSetting> {
  // the `fileId` (which is usually the file path) is used as the key for the setting storage
  final String fileId;

  FileSettingNotifier(super._state, {required this.fileId});

  void updateSetting(FileSetting Function(FileSetting) f) {
    state = f(state);
    FileViewBox.put(fileId, state.toMap());
  }

  _deleteLocalSetting() async {
    FileViewBox.delete(fileId);
  }

  _loadLocalFileSetting() async {
    final setting = await FileViewBox.get(fileId);
    if (setting != null) {
      state = FileSetting.fromMap(setting);
    } else {
      await FileViewBox.put(fileId, state.toMap());
    }
    print('--- LocalFileSetting is loaded');
  }
}

final fileSettingProvider =
    StateNotifierProvider.family<FileSettingNotifier, FileSetting, String>(
        (ref, fileId) {
  final notifier = FileSettingNotifier(const FileSetting(), fileId: fileId);
  notifier._loadLocalFileSetting();

  ref.read(fileManager).containsFile(fileId);
  ref.listen(fileManager, (_, next) {
    if (!next.containsFile(fileId)) {
      notifier._deleteLocalSetting();
    }
  });

  return notifier;
});
