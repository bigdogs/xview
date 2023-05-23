import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/file_setting.dart';
import 'package:xview/fileapp/providers/matcher.dart';
import 'package:xview/fileapp/views/pages/file_view.dart';
import 'package:xview/fileapp/views/widgets/line.dart';
import 'package:xview/fileapp/views/widgets/textlist.dart';
import 'package:xview/utils/consts.dart';

class FilterView extends ConsumerWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(filterLineProvider(FileView.id(context)));
    final controller = ScrollController();
    return ColoredBox(
        color: CustomColor.filterBackground,
        child: Scrollbar(
            interactive: true,
            thumbVisibility: true,
            controller: controller,
            child: SelectionArea(
                child: TextList.builder(
              controller: controller,
              itemTextCount: (index) => lines[index].text.length,
              itemCount: lines.length,
              itemBuilder: (c, index) {
                final data = lines[index];
                return Line(
                    data: data,
                    onTap: () => ref
                        .read(
                            fileSettingProvider(FileView.id(context)).notifier)
                        .jumpToIndex(data.lineNumber));
              },
            ))));
  }
}
