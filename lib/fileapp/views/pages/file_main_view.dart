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
  ScrollController? _scrollController;

  ScrollController get scrollController {
    if (_scrollController == null) {
      double initOffset = 0;
      final position =
          ref.read(fileSettingProvider(FileView.id(context))).mainviewPosition;
      if (position != "") {
        final fileCount =
            ref.read(allLineProvider(FileView.id(context))).length;
        double o = double.parse(position);
        (double, int, double)? p = decodeRestorePosition(o);
        if (p != null) {
          if (p.$2 < fileCount) {
            log.info(
                'mainview resotre location: layoutOffset: ${p.$1}, firstChildIndex: ${p.$2}, firstChildOffset: ${p.$3}');
            initOffset = o;
          } else {
            log.warning(
                'mainview store location failed. index: ${p.$2}, file length: $fileCount');
          }
        }
      }

      _scrollController =
          NoJumpBallisticController(initialScrollOffset: initOffset);
    }
    return _scrollController!;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        fileSettingProvider(FileView.id(context))
            .select((value) => value.jumpIndex), (previous, next) {
      if (next > 0) {
        scrollController.jumpTo(encodeVisiableIndex(next.round()));
      }
    });
    final lines = ref.watch(allLineProvider(FileView.id(context)));

    //  refactor "SelectionArea" if double/trip click is supported
    return Scrollbar(
        interactive: true,
        thumbVisibility: true,
        controller: scrollController,
        child: SelectionArea(
            child: TextList.builder(
          controller: scrollController,
          itemTextCount: (index) => lines[index].text.length,
          itemCount: lines.length,
          cacheExtent: 0,
          layoutNotifier: (position) {
            print('mainview Layout. $position');
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
