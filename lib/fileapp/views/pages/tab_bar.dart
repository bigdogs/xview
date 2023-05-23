import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_manager.dart';
import 'package:xview/utils/consts.dart';

import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

class FileTabBar extends ConsumerWidget {
  final List<String> files;
  final TabController controller;

  const FileTabBar({super.key, required this.files, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          child: Row(
              children: files
                  .mapIndexed((index, element) =>
                      _Tab(index: index, controller: controller, path: element))
                  .toList()),
        ),
        const Divider(
          height: 0,
          indent: 0,
          thickness: 1,
        )
      ],
    );
  }
}

class _Tab extends ConsumerStatefulWidget {
  final int index;
  final String path;
  final TabController controller;

  const _Tab(
      {required this.index, required this.controller, required this.path});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TabState();
  }
}

class _TabState extends ConsumerState<_Tab> {
  @override
  Widget build(BuildContext context) {
    final activeIndex =
        ref.watch(fileManager.select((value) => value.activeIndex));

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(fileManager.notifier).setActiveIndex(widget.index);
        },
        child: Container(
            color: (activeIndex == widget.index
                ? const Color.fromARGB(255, 210, 231, 255)
                : null),
            height: 30,
            padding: const EdgeInsets.only(left: 2, right: 16),
            child: Row(children: [
              Container(
                width: 1,
                height: 30 * 0.6,
                color: const Color.fromARGB(255, 230, 230, 230),
              ),
              GestureDetector(
                onTap: _closeTap,
                child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      CustomIcon.close,
                      size: 16,
                    )),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    CustomIcon.file,
                    size: 14,
                    color: Color.fromARGB(255, 95, 114, 127),
                  )),
              Text(
                p.basename(widget.path),
                style: const TextStyle(
                    color: Color.fromARGB(255, 12, 118, 247),
                    fontWeight: FontWeight.w500),
              ),
            ])));
  }

  _closeTap() async {
    ref.read(fileManager.notifier).closeFile(widget.path);
  }
}
