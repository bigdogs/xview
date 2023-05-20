import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/providers/setting.dart';
import 'package:xview/fileapp/views/pages/filter_bar.dart';
import 'package:xview/fileapp/views/widgets/dragable_divider.dart';

class FileView extends ConsumerStatefulWidget {
  final String fileId;

  const FileView({super.key, required this.fileId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FileViewState();
  }

  static String id(BuildContext context) {
    return (context.getElementForInheritedWidgetOfExactType<_FileId>()!.widget
            as _FileId)
        .id;
  }
}

class _FileViewState extends ConsumerState<FileView> {
  @override
  Widget build(BuildContext context) {
    return _FileId(
        id: widget.fileId,
        child: LayoutBuilder(
          builder: (context, constrinat) {
            final percent = ref.watch(settingProvider(FileView.id(context))
                .select((value) => value.percentOfFilterView));

            return Column(
              children: [
                Text(widget.fileId),
                Expanded(child: _MainView()),
                DragableDivider(onDrag: (details) {
                  _onDrag(context, details, constrinat.maxHeight);
                }),
                const FilterBar(),
                SizedBox(
                    height: percent * constrinat.maxHeight,
                    child: _FilterView()),
              ],
            );
          },
        ));
  }

  _onDrag(BuildContext context, DragUpdateDetails details, double height) {
    ref
        .read(settingProvider(FileView.id(context)).notifier)
        .updateFilterPercent((old) {
      double p = (old * height - details.delta.dy) / height;
      return p.clamp(0.1, 0.8);
    });
  }
}

class _MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _FilterView extends StatelessWidget {
  @override
  Widget build(Object context) {
    return Container();
  }
}

class _FileId extends InheritedWidget {
  final String id;

  const _FileId({required this.id, required super.child});

  @override
  bool updateShouldNotify(covariant _FileId oldWidget) {
    return id == oldWidget.id;
  }
}
