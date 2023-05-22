import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_matcher.dart';
import 'package:xview/fileapp/providers/position.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/fileapp/views/widgets/line.dart';
import 'package:xview/fileapp/views/widgets/textlist.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends ConsumerState<MainView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(positionProvider, (previous, next) {
      if (next.jumpTargetIndex != -1 && next.jumpCount != previous?.jumpCount) {
        _fakeJumpToIndex(next.jumpTargetIndex);
      }
    });
    // final content = ref.watch(fileDataProvider);
    final lines = ref.watch(allFileMatchProvider(FileView.id(context)));

    // TODO: refactor "SelectionArea" if double/trip click is supported
    return Scrollbar(
        interactive: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: SelectionArea(
            child: TextList.builder(
          controller: _scrollController,
          itemTextCount: (index) => lines[index].text.length,
          itemCount: lines.length,
          itemBuilder: (c, index) {
            return Line(data: lines[index]);
          },
        )));
  }

  _fakeJumpToIndex(int index) {
    final fakeOffset =
        double.parse('0.1987${index.toString().padLeft(7, '0')}6');
    _scrollController.jumpTo(fakeOffset);
  }
}
