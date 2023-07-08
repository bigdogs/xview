import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/views/pages/tab_bar.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/fileapp/views/pages/no_file.dart';
import 'package:xview/fileapp/views/widgets/drag_file.dart';

import 'dart:io';

import 'package:xview/utils/log.dart';

class FileApp extends ConsumerStatefulWidget {
  const FileApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FileState();
  }
}

class _FileState extends ConsumerState<FileApp> with TickerProviderStateMixin {
  @override
  void initState() {
    _firstLoadFiles();
    super.initState();
  }

  _firstLoadFiles() async {
    // load previously uncoded file
    final fm = ref.read(fileManager.notifier);
    final unclosedFiles = await fm.unclosedFiles();
    final argFiles = Platform.executableArguments;
    log.info("unclosed files: $unclosedFiles, argument files: $argFiles");

    final files = [...unclosedFiles, ...argFiles];
    await fm.openFiles(files);
    // load all settings to memory, we don't need lazy loading
    for (final f in files) {
      ref.read(fileSettingProvider(f).notifier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragFile(onOpenFiles: _onOpenFiles, child: _buildAppBody(context));
  }

  // https://stackoverflow.com/questions/63314082/flutter-how-to-make-a-custom-tabbar

  Widget _buildAppBody(BuildContext context) {
    final files = ref.watch(fileManager.select((value) => value.files));
    Widget widget;

    if (files.isEmpty) {
      widget = const NoFile();
    } else {
      widget = _buildFileApp(files);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: widget,
    );
  }

  Widget _buildFileApp(List<FileMeta> files) {
    // whenever we create a new tabview, we must also create a new
    // controller
    //
    TabController controller = TabController(
        animationDuration: const Duration(milliseconds: 400),
        length: files.length,
        vsync: this,
        // The documentation states that we should not use `ref.read` in the build method
        // because it will not trigger a rebuild when changes occur. however, in our specific use case,
        // we only need to read the value once, so it should be acceptable
        initialIndex: ref.read(fileManager).activeIndex);

    ref.listen(fileManager.select((value) => value.activeIndex), (prev, next) {
      // 1) Upon closing the last file, a notification will be sent indicating that the `next` value is -1
      // 2) when adding a new file, the `next` value can be larger than the total number of files because the rebuild
      // has not yet occurred
      if (next >= 0 && next < files.length && next != prev) {
        controller.index = next;
      }
    });

    return Column(
      children: [
        FileTabBar(
            files: files.map((e) => e.path).toList(), controller: controller),
        Expanded(
            //TODO: The default tab animation looks not very good...
            child: TabBarView(
          controller: controller,
          children: files.map((e) => FileView(fileId: e.path)).toList(),
        ))
      ],
    );
  }

  _onOpenFiles(List<String> files) {
    ref.read(fileManager.notifier).openFiles(files);
  }
}
