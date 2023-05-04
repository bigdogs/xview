import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/content.dart';
import 'package:xview/view/widgets/line.dart';

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
    // https://github.com/flutter/flutter/issues/75399
    //
    // TODO: drag the scroll bar may hang app
    final content = ref.watch(contentProvider);
    return SelectionArea(
        child: Scrollbar(
            interactive: true,
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: content.length(),
              itemBuilder: (c, index) {
                return Line(data: content.lineAtIndex(index));
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  height: 1,
                );
              },
            )));
  }
}
