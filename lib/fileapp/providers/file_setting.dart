import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/service/hive.dart';
import 'package:xview/utils/log.dart';

@immutable
class FileSetting {
  final double percentOfFilterView;
  final bool caseSensitive;
  final bool matchWholeWord;
  final bool useRegex;
  final String filterWord;
  final int shadowIndex;
  // we use fraical part to represent click times
  final double jumpIndex;
  final String mainviewPosition;
  final String filterviewPosition;

  const FileSetting({
    this.percentOfFilterView = 0.2,
    this.caseSensitive = false,
    this.matchWholeWord = false,
    this.useRegex = false,
    this.filterWord = '',
    this.shadowIndex = -1,
    this.jumpIndex = -1,
    this.mainviewPosition = "",
    this.filterviewPosition = "",
  });

  FileSetting copy({
    double? percentOfFilterView,
    bool? caseSensitive,
    bool? matchWholeWord,
    bool? useRegex,
    String? filterWord,
    int? shadowIndex,
    double? jumpIndex,
    String? mainviewPosition,
    String? filterviewPosition,
  }) {
    return FileSetting(
        percentOfFilterView: percentOfFilterView ?? this.percentOfFilterView,
        caseSensitive: caseSensitive ?? this.caseSensitive,
        matchWholeWord: matchWholeWord ?? this.matchWholeWord,
        useRegex: useRegex ?? this.useRegex,
        filterWord: filterWord ?? this.filterWord,
        shadowIndex: shadowIndex ?? this.shadowIndex,
        jumpIndex: jumpIndex ?? this.jumpIndex,
        mainviewPosition: mainviewPosition ?? this.mainviewPosition,
        filterviewPosition: filterviewPosition ?? this.filterviewPosition);
  }

  Map toMap() {
    return {
      'percentOfFilterView': percentOfFilterView,
      'caseSensitive': caseSensitive,
      'matchWholeWord': matchWholeWord,
      'useRegex': useRegex,
      'filterWord': filterWord,
      'shadowIndex': shadowIndex,
      'mainviewPosition': mainviewPosition,
      'filterviewPosition': filterviewPosition,
    };
  }

  static FileSetting fromMap(Map m) {
    return const FileSetting().copy(
      percentOfFilterView: m['percentOfFilterView'],
      caseSensitive: m['caseSensitive'],
      matchWholeWord: m['matchWholeWord'],
      useRegex: m['useRegex'],
      filterWord: m['filterWord'],
      shadowIndex: m['shadowIndex'],
      mainviewPosition: m['mainviewPosition'],
      filterviewPosition: m['filterviewPosition'],
    );
  }

  @override
  String toString() {
    return '"$filterWord"|$percentOfFilterView';
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

  void jumpToIndex(int target) {
    double index = state.jumpIndex;
    if (index.round() != target) {
      index = target.toDouble();
    } else {
      index += 0.00000001;
    }
    state = state.copy(jumpIndex: index);
  }

  deleteLocalSetting() async {
    log.info('[$fileId] delete local setting');
    FileViewBox.delete(fileId);
  }

  loadLocalFileSetting() async {
    final setting = await FileViewBox.get(fileId);
    if (setting != null) {
      state = FileSetting.fromMap(setting);
      log.info('[$fileId] load local setting: $state');
    } else {
      log.info('[$fileId] no local setting');
      await FileViewBox.put(fileId, state.toMap());
    }
  }
}

final fileSettingProvider =
    StateNotifierProvider.family<FileSettingNotifier, FileSetting, String>(
        (ref, fileId) {
  final notifier = FileSettingNotifier(const FileSetting(), fileId: fileId);
  log.info(
      '[$fileId] +provider fileSettingProvider@${identityHashCode(notifier)}');

  return notifier;
});

final filterViewEnableProvider = StateProvider.family<bool, String>((ref, arg) {
  return true;
});
