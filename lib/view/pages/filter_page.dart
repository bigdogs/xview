import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/content.dart';
import 'package:xview/view/widgets/line.dart';

class FilterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    return ListView.builder(
        itemCount: content.filterLength(),
        itemBuilder: (c, index) {
          return Line(data: content.filterLineAtIndex(index));
        });
  }
}
