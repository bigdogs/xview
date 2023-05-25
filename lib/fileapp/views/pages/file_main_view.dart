import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/providers/matcher.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/fileapp/views/widgets/line.dart';
import 'package:xview/fileapp/views/widgets/textlist.dart';
import 'package:xview/utils/log.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends ConsumerState<MainView> {
  final ScrollController _scrollController = NoJumpBallisticController();
  String? initPosition;
  bool initPositionRestored = false;

  @override
  void initState() {
    final position =
        ref.read(fileSettingProvider(FileView.id(context))).mainviewPosition;
    if (position != "") {
      initPosition = position;
      log.info('[${FileView.id(context)}] load init position: $initPosition');
    }

    super.initState();
  }

  _scheduleRestoreInitPosition() {
    if (!initPositionRestored && initPosition != null) {
      // wait file be loaded to memory...
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!context.mounted) {
          return;
        }

        double encodedOffset = double.parse(initPosition!);
        (double, int, double)? p = decodeRestorePosition(encodedOffset);
        if (p != null) {
          final fileCount =
              ref.read(allLineProvider(FileView.id(context))).length;
          if (p.$2 >= fileCount) {
            // file might not be fully loaded
            log.info(
                '[${FileView.id(context)}] file might not fully loaded (or modified?). saved index: ${p.$2}, file len: $fileCount');
          } else {
            log.info(
                '[${FileView.id(context)}] restore location. layoutOffset: ${p.$1}, firstIndex: ${p.$2}, firstChildOffset: ${p.$3}');
            _scrollController.jumpTo(encodedOffset);
          }
        }
      });
    }
    initPositionRestored = true;
  }

  // ScrollController get scrollController {
  //   if (_scrollController == null) {
  //     double initOffset = 0;
  //     final position =
  //         ref.read(fileSettingProvider(FileView.id(context))).mainviewPosition;
  //     if (position != "") {
  //       final fileCount =
  //           ref.read(allLineProvider(FileView.id(context))).length;
  //       double o = double.parse(position);
  //       (double, int, double)? p = decodeRestorePosition(o);
  //       if (p != null) {
  //         if (p.$2 < fileCount) {
  //           log.info(
  //               '[${FileView.id(context)}] mainview resotre location: layoutOffset: ${p.$1}, firstChildIndex: ${p.$2}, firstChildOffset: ${p.$3}');
  //           initOffset = o;
  //         } else {
  //           log.warning(
  //               'mainview store location failed. index: ${p.$2}, file length: $fileCount');
  //         }
  //       }
  //     }

  //     _scrollController =
  //         NoJumpBallisticController(initialScrollOffset: initOffset);
  //   }
  //   return _scrollController!;
  // }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        fileSettingProvider(FileView.id(context))
            .select((value) => value.jumpIndex), (previous, next) {
      if (next > 0) {
        _scrollController.jumpTo(encodeVisiableIndex(next.round()));
      }
    });
    final lines = ref.watch(allLineProvider(FileView.id(context)));
    _scheduleRestoreInitPosition();

    //  refactor "SelectionArea" if double/trip click is supported
    return Scrollbar(
        interactive: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: SelectionArea(
            child: TextList.builder(
          controller: _scrollController,
          itemTextCount: (index) => lines[index].text.length,
          itemCount: lines.length,
          layoutNotifier: (position) {
            ref
                .read(fileSettingProvider(FileView.id(context)).notifier)
                .updateSetting((p0) => p0.copy(mainviewPosition: position));
          },
          itemBuilder: (c, index) {
            return Line(data: lines[index]);
          },
        )));
  }
}
