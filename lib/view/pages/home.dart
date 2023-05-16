import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/provider/filedata.dart';
import 'package:xview/view/pages/filter_page.dart';
import 'package:xview/view/pages/main_page.dart';
import 'package:xview/view/widgets/drag_file.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends ConsumerState<Home> {
  double percent = 0.2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragFile(onOpenFiles: (files) {
      ref.read(fileDataProvider.notifier).openFiles(files);
    }, child: LayoutBuilder(builder: (context, constrinat) {
      return Column(
        children: [
          const Expanded(child: MainPage()),
          MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) =>
                    _changeViewFilterHeight(details, constrinat.maxHeight),
                child: const Divider(height: 4)),
          ),
          SizedBox(height: percent * constrinat.maxHeight, child: FilterPage()),
        ],
      );
    }));
  }

  void _changeViewFilterHeight(DragUpdateDetails details, double totalHeight) {
    double p = (percent * totalHeight - details.delta.dy) / totalHeight;
    p = p.clamp(0.1, 0.9);

    setState(() {
      percent = p;
    });
  }
}
