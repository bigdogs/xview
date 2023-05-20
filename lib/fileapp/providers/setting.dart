import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/service/hive.dart';

@immutable
class Setting {
  final double percentOfFilterView;

  const Setting({this.percentOfFilterView = 0.2});

  Setting copy({double? percentOfFilterView}) {
    return Setting(
      percentOfFilterView: percentOfFilterView ?? this.percentOfFilterView,
    );
  }

  Map toMap() {
    return {'percentOfFilterView': percentOfFilterView};
  }

  static Setting fromMap(Map m) {
    return Setting();
  }
}

class SettingNotifier extends StateNotifier<Setting> {
  // the `fileId` (which is usually the file path) is used as the key for the setting storage
  final String fileId;

  SettingNotifier(super._state, {required this.fileId});

  void updateFilterPercent(double Function(double) f) {
    final newPercent = f(state.percentOfFilterView);
    state = state.copy(percentOfFilterView: newPercent);
  }

  _deleteLocalSetting() async {
    FileViewBox.delete(fileId);
  }

  _onFileLoaded() async {
    final setting = await FileViewBox.get(fileId);
    if (setting != null) {
      state = Setting.fromMap(setting);
    } else {
      await FileViewBox.put(fileId, state.toMap());
    }
  }
}

final settingProvider = StateNotifierProvider.autoDispose
    .family<SettingNotifier, Setting, String>((ref, fileId) {
  print('create file: $fileId');
  final notifier = SettingNotifier(const Setting(), fileId: fileId);
  notifier._onFileLoaded();

  ref.read(fileManager).containsFile(fileId);
  ref.listen(fileManager, (_, next) {
    if (!next.containsFile(fileId)) {
      notifier._deleteLocalSetting();
    }
  });

  return notifier;
});
