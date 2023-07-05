import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/views/menu/menu_bar_app.dart';
import 'package:xview/fileapp/views/menu/menu_bar_macos.dart';
import 'package:xview/utils/log.dart';

abstract class MenuAction {
  // `async` is not a method signature type, see:
  //
  // https://stackoverflow.com/questions/55749637/dart-async-abstract-method
  Future<void> openFileDialog();
}

// an MenuBar adaptor for macos and windows
class CustomMenuBar extends ConsumerStatefulWidget {
  final Widget child;

  const CustomMenuBar({super.key, required this.child});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MState();
  }
}

class _MState extends ConsumerState<CustomMenuBar> implements MenuAction {
  @override
  Widget build(BuildContext context) {
    Widget w = widget.child;

    if (Platform.isMacOS) {
      w = MenuBarMacos(
        action: this,
        child: w,
      );
    }

    w = MenuBarApp(
      action: this,
      child: w,
    );
    return w;
  }

  @override
  Future<void> openFileDialog() async {
    log.info("open file dialog start");
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) {
      return;
    }
    List<String> files =
        result.paths.where((e) => e != null).map((e) => e!).toList();
    if (files.isEmpty) {
      return;
    }
    ref.read(fileManager.notifier).openFiles(files);
  }
}
