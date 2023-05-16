import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/filedata.dart';
import 'package:xview/provider/position.dart';
import 'package:xview/view/widgets/line.dart';
import 'package:xview/view/widgets/textlist.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends ConsumerState<MainPage> {
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
    final content = ref.watch(fileDataProvider);

    // "SelectionArea" seems kind of wired here
    return Scrollbar(
        interactive: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: SelectionArea(
            child: TextList.builder(
          controller: _scrollController,
          itemTextCount: (index) => content.lineAtIndex(index).text.length,
          itemCount: content.length(),
          itemBuilder: (c, index) {
            return Line(data: content.lineAtIndex(index));
          },
        )));
  }

  _fakeJumpToIndex(int index) {
    final fakeOffset = double.parse('0.10086$index');
    _scrollController.jumpTo(fakeOffset);
  }
}
