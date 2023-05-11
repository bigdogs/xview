import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Setting {
  // unused, the filter view is always open
  final bool isFilterViewOpen;
  // would it be better to add `currentIndex` to `filedata`? however, since
  // it changes frequently, I'm not sure if adding it to `filedata` would negatively impact performace
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
  late FocusNode selectFocusNode;

  @override
  Setting build() {
    selectFocusNode = FocusNode();
    state = Setting();
    return state;
  }

  void setCurrentIndex(int index) {
    state = state.copy(currentInex: index);
  }
}

final settingProvider =
    NotifierProvider<SettingProvider, Setting>(() => SettingProvider());
