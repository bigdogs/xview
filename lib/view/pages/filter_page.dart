import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/content.dart';
import 'package:xview/view/widgets/line.dart';

class FilterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    return Column(
      children: [
        FilterLine(),
        Expanded(
            child: SelectionArea(
                child: ListView.separated(
          itemCount: content.filterLength(),
          itemBuilder: (c, index) {
            return Line(data: content.filterLineAtIndex(index));
          },
          separatorBuilder: (c, index) {
            return const Divider(height: 1);
          },
        )))
      ],
    );
  }
}

class FilterLine extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FilterLineState();
  }
}

class _FilterLineState extends ConsumerState<FilterLine> {
  String _filter = "";
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: SizedBox(
            height: 28,
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  maxLines: 1,
                  focusNode: focusNode,
                  onChanged: (c) {
                    _filter = c;
                  },
                  onEditingComplete: () {
                    ref.read(contentProvider.notifier).setFilter(_filter);
                    focusNode.requestFocus();
                  },
                  decoration: const InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: Icon(Icons.search, size: 16),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(4)))),
                ))
              ],
            )));
  }
}
