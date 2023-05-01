import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setting {
  final bool isFilterViewOpen = true;
}

class SettingProvider extends Notifier<Setting> {
  @override
  Setting build() {
    state = Setting();
    return state;
  }
}

final settingProvider =
    NotifierProvider<SettingProvider, Setting>(() => SettingProvider());
