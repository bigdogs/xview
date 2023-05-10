import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setting {
  // unused, the filter view is always open
  final bool isFilterViewOpen;
  final int currentInex;

  Setting({this.isFilterViewOpen = true, this.currentInex = -1});

  Setting copy({bool? isFilterViewOpen, int? currentInex}) {
    return Setting(
      isFilterViewOpen: isFilterViewOpen ?? this.isFilterViewOpen,
      currentInex: currentInex ?? this.currentInex,
    );
  }
}

class SettingProvider extends Notifier<Setting> {
  @override
  Setting build() {
    state = Setting();
    return state;
  }

  void setCurrentIndex(int index) {
    state = state.copy(currentInex: index);
  }
}

final settingProvider =
    NotifierProvider<SettingProvider, Setting>(() => SettingProvider());
