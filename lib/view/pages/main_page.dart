import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/filedata.dart';
import 'package:xview/view/widgets/line.dart';
import 'package:xview/view/widgets/listview.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends ConsumerState<MainPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(fileDataProvider);

    // "SelectionArea" seems kind of wired here
    return Scrollbar(
        interactive: true,
        thumbVisibility: true,
        controller: _scrollController,
        child: SelectionArea(
            child: ListViewExt.builder(
          controller: _scrollController,
          itemCount: content.length(),
          itemBuilder: (c, index) {
            return Line(data: content.lineAtIndex(index));
          },
        )));
  }
}
