import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/fileapp/views/pages/file_tab_bar.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/fileapp/views/pages/no_file.dart';
import 'package:xview/fileapp/views/widgets/drag_file.dart';

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
    ref.read(fileManager.notifier).loadHistoryFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragFile(onOpenFiles: _onOpenFiles, child: _buildAppBody(context));
  }

  // https://stackoverflow.com/questions/63314082/flutter-how-to-make-a-custom-tabbar

  Widget _buildAppBody(BuildContext context) {
    final files = ref.watch(fileManager.select((value) => value.files));
    if (files.isEmpty) {
      return const NoFile();
    }

    print('----rebuilt-----');

    // whenever we create a new tabview, we must also create a new
    // controller
    //
    // set animation duration to zero to disable animation
    TabController controller = TabController(
        length: files.length,
        vsync: this,
        animationDuration: Duration.zero,
        // The documentation states that we should not use `ref.read` in the build method
        // because it will not trigger a rebuild when changes occur. however, in our specific use case,
        // we only need to read the value once, so it should be acceptable
        initialIndex: ref.read(fileManager).activeIndex);

    ref.listen(fileManager.select((value) => value.activeIndex), (prev, next) {
      // Upon closing the last file, a notification will be sent indicating that the `next` value is -1
      if (next != -1) {
        controller.index = next;
      }
    });

    return Column(
      children: [
        FileTabBar(
            files: files.map((e) => e.path).toList(), controller: controller),
        Expanded(
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
