import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/content.dart';
import 'package:xview/view/widgets/line.dart';

class MainPage extends ConsumerWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // https://github.com/flutter/flutter/issues/75399
    //
    final content = ref.watch(contentProvider);
    return Scrollbar(
        interactive: true,
        controller: _scrollController,
        child: ListView.builder(
            controller: _scrollController,
            itemExtent: 50,
            itemCount: content.length(),
            itemBuilder: (c, index) {
              return Line(data: content.lineAtIndex(index));
            }));
  }
}
